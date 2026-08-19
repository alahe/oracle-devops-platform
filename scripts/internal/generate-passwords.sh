#!/usr/bin/env bash
# ============================================================================
# Environment Password Generator for Oracle Free DB in Prod
# Initializes .env and randomizes all system passwords with secure values.
# ============================================================================

set -e

_LOCAL_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$_LOCAL_SCRIPT_DIR/../.." && pwd)"
ENV_PATH="$WORKSPACE_DIR/.env"

FORCE=false
for arg in "$@"; do
  if [ "$arg" = "--force" ] || [ "$arg" = "-y" ]; then
    FORCE=true
  fi
done

# Värvide seadistamine (ainult siis kui terminal seda toetab)
if [ -t 0 ] || { [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; }; then
  GREEN='\033[1;32m'
  YELLOW='\033[0;33m'
  NC='\033[0m'
else
  GREEN=''
  YELLOW=''
  NC=''
fi

# Parooli genereerimise abifunktsioon
# Tagab 100% vastavuse Oracle ADB paroolipoliitikale: 12-30 tähemärki, min 1 suurtäht, min 1 väiketäht, min 1 number (puhtalt alfanumeeriline)
gen_random_password() {
  local uppers=$(LC_ALL=C tr -dc 'A-Z' < /dev/urandom | head -c 4 2>/dev/null || echo "KWMX")
  local lowers=$(LC_ALL=C tr -dc 'a-z' < /dev/urandom | head -c 8 2>/dev/null || echo "abcdefgh")
  local nums=$(LC_ALL=C tr -dc '0-9' < /dev/urandom | head -c 4 2>/dev/null || echo "4829")
  local suffix=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 4 2>/dev/null || echo "xyz5")
  echo "${uppers}${lowers}${nums}${suffix}"
}

generate_all_passwords() {
  # Kui .env on olemas ja force pole määratud, küsime üle
  if [ -f "$ENV_PATH" ] && [ "$FORCE" = "false" ]; then
    echo "⚠️  Fail .env on juba olemas."
    read -p "❓ Kas soovid kõik paroolid uute juhuslike väärtustega asendada? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
      echo "ℹ️  Tegevus tühistatud. Olemasolevat .env faili ei muudetud."
      exit 0
    fi
  fi

  # Kui faili pole, kopeerime näidisest
  if [ ! -f "$ENV_PATH" ]; then
    echo "   ℹ️  Loome uue .env faili näidise (.env.example) põhjal..."
    cp "$WORKSPACE_DIR/.env.example" "$ENV_PATH"
  fi

  # Laeme keskkonnamuutujad, et saada kätte ADDITIONAL_DATABASES
  if [ -f "$ENV_PATH" ]; then
    set -a
    source "$ENV_PATH"
    set +a
  fi

  # Genereerime juhuslikud tugevad paroolid
  PUB_SYS_PWD=$(gen_random_password)
  APEX_SYS_PWD=$(gen_random_password)
  APEX_ADMIN_PWD=$(gen_random_password)
  APEX_LIST_PWD=$(gen_random_password)
  APEX_SCH_PWD=$(gen_random_password)
  TEST_DEV_PWD=$(gen_random_password)
  TEST_WEB_PWD=$(gen_random_password)

  create_podman_secret() {
    local name="$1"
    local val="$2"
    podman secret rm "$name" >/dev/null 2>&1 || true
    echo -n "$val" | podman secret create "$name" - >/dev/null 2>&1
  }

  create_podman_secret "publisher_db_sys_password" "$PUB_SYS_PWD"
  create_podman_secret "apex_db_sys_password" "$APEX_SYS_PWD"
  create_podman_secret "apex_admin_password" "$APEX_ADMIN_PWD"
  create_podman_secret "ords_listener_password" "$APEX_LIST_PWD"
  create_podman_secret "apex_schema_password" "$APEX_SCH_PWD"
  create_podman_secret "test_dev_password" "$TEST_DEV_PWD"
  create_podman_secret "test_web_password" "$TEST_WEB_PWD"

  if [ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ]; then
    source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"
    for secret in $(get_required_secret_names 2>/dev/null); do
      if ! podman secret exists "$secret" 2>/dev/null; then
        DB_PWD=$(gen_random_password)
        create_podman_secret "$secret" "$DB_PWD"
      fi
    done
  fi

  echo -e "${GREEN}✅ PAROOLID ON EDUKALT SALVESTATUD PODMAN SECRETS TEENUSESSE!${NC}"
  echo "   Ükski plaintext parool ei ole kirjutatud kettale failina."
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  echo -e "${YELLOW}🔐 SÜSTEEMSETE PAROOLIDE GENEREERIMISE UTILIIT${NC}"
  echo "   Registreerin uued saladused Podman Secrets teenusesse..."
  generate_all_passwords "$@"
fi
