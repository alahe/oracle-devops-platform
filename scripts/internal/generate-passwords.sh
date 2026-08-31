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
  # Kui .env on olemas ja force pole määratud, küsime üle ainult interaktiivses terminalis
  if [ -f "$ENV_PATH" ] && [ "$FORCE" = "false" ] && [ -t 0 ]; then
    echo "⚠️  Fail .env on juba olemas."
    read -t 15 -p "❓ Kas soovid kõik paroolid uute juhuslike väärtustega asendada? (y/N): " CONFIRM || CONFIRM="n"
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
      echo "ℹ️  Olemasolevaid paroole ei kirjutata üle. Täiendan ainult puuduvaid saladusi..."
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

  # Laeme profiilimootori ja aktiivsed andmebaasid
  if [ -f "$WORKSPACE_DIR/scripts/internal/load-profile.sh" ]; then
    source "$WORKSPACE_DIR/scripts/internal/load-profile.sh"
  fi

  create_podman_secret() {
    local name="$1"
    local val="$2"
    if [ "$FORCE" = "true" ] || ! podman secret exists "$name" 2>/dev/null; then
      podman secret rm "$name" >/dev/null 2>&1 || true
      echo -n "$val" | podman secret create "$name" - >/dev/null 2>&1
    fi
  }

  # 1. Genereerime iga aktiivse andmebaasi instantsi kohta täieliku rollide maatriksi
  local primary_dev_pwd=""
  local primary_viewer_pwd=""
  local primary_app_pwd=""
  local primary_dba_pwd=""
  local is_first=true

  if declare -f get_active_db_instances >/dev/null 2>&1; then
    while IFS='|' read -r c_name prof env_key; do
      [ -z "$c_name" ] && continue
      local c_short=$(echo "$c_name" | sed 's/^db-//' | tr '-' '_' | tr '[:upper:]' '[:lower:]')
      
      local sys_pwd=$(gen_random_password)
      local dba_pwd=$(gen_random_password)
      local dev_pwd=$(gen_random_password)
      local viewer_pwd=$(gen_random_password)
      local app_pwd=$(gen_random_password)
      local sch_pwd=$(gen_random_password)

      create_podman_secret "${c_short}_db_sys_password" "$sys_pwd"
      create_podman_secret "${c_short}_sys_password" "$sys_pwd"
      create_podman_secret "${c_short}_dba_admin_password" "$dba_pwd"
      create_podman_secret "${c_short}_dev_password" "$dev_pwd"
      create_podman_secret "${c_short}_viewer_password" "$viewer_pwd"
      create_podman_secret "${c_short}_app_password" "$app_pwd"
      create_podman_secret "${c_short}_schema_password" "$sch_pwd"

      if [ "$is_first" = "true" ]; then
        primary_dev_pwd="$dev_pwd"
        primary_viewer_pwd="$viewer_pwd"
        primary_app_pwd="$app_pwd"
        primary_dba_pwd="$dba_pwd"
        is_first=false
      fi
    done < <(get_active_db_instances 2>/dev/null)
  fi

  # 2. Ühised teenuste ja middleware administraatorite saladused
  create_podman_secret "apex_admin_password" "$(gen_random_password)"
  create_podman_secret "ords_listener_password" "$(gen_random_password)"
  create_podman_secret "publisher_admin_password" "$(gen_random_password)"
  create_podman_secret "forms_admin_password" "$(gen_random_password)"

  # 3. Tagasiühilduvuse ühised aliased primaarse baasi järgi
  create_podman_secret "dba_admin_password" "${primary_dba_pwd:-$(gen_random_password)}"
  create_podman_secret "user_developer_password" "${primary_dev_pwd:-$(gen_random_password)}"
  create_podman_secret "user_viewer_password" "${primary_viewer_pwd:-$(gen_random_password)}"
  create_podman_secret "user_app_password" "${primary_app_pwd:-$(gen_random_password)}"
  create_podman_secret "test_dev_password" "${primary_dev_pwd:-$(gen_random_password)}"
  create_podman_secret "test_viewer_password" "${primary_viewer_pwd:-$(gen_random_password)}"
  create_podman_secret "apex_schema_password" "$(gen_random_password)"

  if [ -f "$WORKSPACE_DIR/scripts/internal/i18n.sh" ]; then
    # shellcheck source=/dev/null
    source "$WORKSPACE_DIR/scripts/internal/i18n.sh"
  fi

  echo -e "${GREEN}$(msg_str "PASSWORDS_SAVED")${NC}"
  echo "$(msg_str "PASSWORDS_NO_PLAINTEXT")"
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
  if [ -f "$_LOCAL_SCRIPT_DIR/i18n.sh" ]; then
    # shellcheck source=/dev/null
    source "$_LOCAL_SCRIPT_DIR/i18n.sh"
  fi
  echo -e "${YELLOW}$(msg_str "PASSWORDS_TITLE")${NC}"
  echo "   Registering secrets into Podman Secrets..."
  generate_all_passwords "$@"
fi
