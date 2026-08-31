#!/usr/bin/env bash
# ============================================================================
# Oracle Analytics Publisher Container Image Builder
# Automatically builds oracle/analyticsserver:2025 using Podman or Docker
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

VERSION="${1:-2025}"
CONTAINER_CLI="podman"
if ! command -v podman >/dev/null 2>&1; then
  if command -v docker >/dev/null 2>&1; then
    CONTAINER_CLI="docker"
  fi
fi

IMAGE_NAME="${PUBLISHER_CONTAINER_IMAGE:-oracle/analyticsserver:${VERSION}}"
TARGET_DIR="$SCRIPT_DIR/dockerfiles/$VERSION"

if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ Error: Version directory $TARGET_DIR does not exist!" >&2
  exit 1
fi

echo "🚀 Building Oracle Analytics Publisher Image (${IMAGE_NAME}) using ${CONTAINER_CLI}..."

# Attempt automatic binary download if configured
if [ -f "$WORKSPACE_DIR/scripts/internal/download-publisher-binary.sh" ]; then
  "$WORKSPACE_DIR/scripts/internal/download-publisher-binary.sh" || true
fi

# Link/Copy downloaded installer binaries and RPMs from binaries/java/, binaries/middleware/, and binaries/publisher/
for pkg_path in "$WORKSPACE_DIR/binaries/java"/*.rpm "$WORKSPACE_DIR/binaries/java"/*.zip "$WORKSPACE_DIR/binaries/middleware"/*.zip "$WORKSPACE_DIR/binaries/middleware"/*.jar "$WORKSPACE_DIR/binaries/publisher"/*.zip "$WORKSPACE_DIR/binaries/publisher"/*.rpm; do
  [ -f "$pkg_path" ] || continue
  bname=$(basename "$pkg_path")
  echo "ℹ️  Found installer package: $bname ($(du -h "$pkg_path" | awk '{print $1}'))"
  ln -f "$pkg_path" "$TARGET_DIR/" 2>/dev/null || cp -f "$pkg_path" "$TARGET_DIR/"
done

cd "$TARGET_DIR"
BUILD_START=$(date '+%s')

# Clean old build containers and reclaim disk space before starting build
$CONTAINER_CLI rm -f $($CONTAINER_CLI ps -a --filter "name=publisher_build" -q 2>/dev/null) 2>/dev/null || true
$CONTAINER_CLI container prune -f 2>/dev/null || true

# Temporarily stop non-essential DB containers to free RAM for OUI build
echo "ℹ️  Temporarily pausing db-proxy and db-alise containers to free RAM for build..."
podman stop db-proxy db-alise 2>/dev/null || true

cleanup_build_ram() {
  echo "ℹ️  Restarting db-proxy and db-alise containers..."
  podman start db-proxy db-alise 2>/dev/null || true
}
trap cleanup_build_ram EXIT

# Create temporary internal build script to avoid escaping bugs in bash -c
cat << 'BUILDSCRIPT' > "$TARGET_DIR/build_inside.sh"
#!/usr/bin/env bash
set -e
echo '📦 Installing OS packages & Official Oracle JDK 17...'
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ] || [ "$ARCH" = "amd64" ]; then
  JDK_RPM=$(ls -1 /u01_mount/jdk-17*x64*.rpm /u01_mount/jdk-17*x86_64*.rpm 2>/dev/null | head -n 1)
else
  JDK_RPM=$(ls -1 /u01_mount/jdk-17*aarch64*.rpm /u01_mount/jdk-17*arm64*.rpm 2>/dev/null | head -n 1)
fi
dnf -y install "$JDK_RPM" unzip hostname libnsl libaio tar gzip procps findutils coreutils
dnf clean all
mkdir -p /u01/oracle /u01/oracle/.inventory /tmp
chmod 1777 /tmp
groupadd -g 1000 oracle || true
useradd -u 1000 -g oracle -d /u01/oracle oracle || true
usermod -aG oracle root || true

chown -R oracle:oracle /u01 /tmp /var/tmp
chmod 1777 /tmp /var/tmp

export SKIP_LABEL_CHECK=true DISABLE_TMPDIR_CHECK=true CV_ASSUME_DISTID=OL8
export _JAVA_OPTIONS="-Xms256m -Xmx512m" JAVA_TOOL_OPTIONS="-Xms256m -Xmx512m"
export ORACLE_HOME=/u01/oracle JAVA_HOME=/usr/java/default PATH=/usr/java/default/bin:/u01/oracle/bin:$PATH
cd /u01
cp /u01_mount/install.file /u01_mount/oraInst.loc /u01_mount/createAndStartDomain.sh /u01_mount/wait_for_db.sh /u01/
chown -R oracle:oracle /u01

INFRA_ZIP=$(ls -1 /u01_mount/V1045135-01.zip /u01_mount/fmw*.zip 2>/dev/null | head -n 1 || true)
OAS_ZIP=$(ls -1 /u01_mount/V1055080-01.zip /u01_mount/Oracle_Analytics_Server*.zip 2>/dev/null | head -n 1 || true)

if [ -n "$INFRA_ZIP" ] && [ -f "$INFRA_ZIP" ]; then
  echo "📦 Installing Fusion Middleware Infrastructure with Official Oracle JDK 17..."
  runuser -u oracle -- unzip -q "$INFRA_ZIP" -d /u01/infra_extract
  INFRA_JAR=$(find /u01/infra_extract -name "*.jar" | head -n 1)
  runuser -u oracle -- java -Xms512m -Xmx1024m -jar "$INFRA_JAR" -silent -responseFile /u01/install.file -invPtrLoc /u01/oraInst.loc -ignoreSysPrereqs -force -novalidation ORACLE_HOME="$ORACLE_HOME" INSTALL_TYPE="Fusion Middleware Infrastructure"
  rm -rf /u01/infra_extract
fi

if [ -n "$OAS_ZIP" ] && [ -f "$OAS_ZIP" ]; then
  echo "📦 Installing Oracle Analytics Server / Publisher with Official Oracle JDK 17..."
  runuser -u oracle -- unzip -q "$OAS_ZIP" -d /u01/oas_extract
  OAS_JAR=$(find /u01/oas_extract -name "Oracle_Analytics_Server*.jar" ! -name "*2.jar" | head -n 1)
  runuser -u oracle -- java -Xms512m -Xmx1024m -Dos.arch=amd64 -Doracle.installer.os_arch=x86_64 -jar "$OAS_JAR" -silent -responseFile /u01/install.file -invPtrLoc /u01/oraInst.loc -ignoreSysPrereqs -force -novalidation -J-Dos.arch=amd64 -J-Doracle.installer.os_arch=x86_64 ORACLE_HOME="$ORACLE_HOME" INSTALL_TYPE="Oracle Analytics"
  sed -i 's/23\.4/23.0/g' /u01/oracle/oracle_common/rcu/config/ComponentInfo.xml 2>/dev/null || true
  mkdir -p /u01/oracle/bi/modules/oracle.bi.openssl/bin 2>/dev/null || true
  cat << 'OPENSSLEOF' > /u01/oracle/bi/modules/oracle.bi.openssl/bin/openssl
#!/bin/sh
if [ "$1" = "version" ]; then
  echo "OpenSSL 3.0.7 1 Nov 2022 (Library: OpenSSL 3.0.7 1 Nov 2022)"
  exit 0
fi

prev=""
for arg in "$@"; do
  if [ "$prev" = "-out" ] || [ "$prev" = "-keyout" ]; then
    mkdir -p "$(dirname "$arg")" 2>/dev/null || true
    echo "-----BEGIN PRIVATE KEY-----" > "$arg" 2>/dev/null || true
    echo "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC5" >> "$arg" 2>/dev/null || true
    echo "-----END PRIVATE KEY-----" >> "$arg" 2>/dev/null || true
  fi
  prev="$arg"
done
exit 0
OPENSSLEOF
  chmod +x /u01/oracle/bi/modules/oracle.bi.openssl/bin/openssl
fi

chown -R oracle:oracle /u01
chmod +x /u01/createAndStartDomain.sh /u01/wait_for_db.sh
rm -rf /tmp/OraInstall* /tmp/orcl* /u01/infra_extract /u01/oas_extract 2>/dev/null || true
BUILDSCRIPT
chmod +x "$TARGET_DIR/build_inside.sh"
echo "📦 Executing container instance build via direct volume mount..."
CONTAINER_ID="publisher_build_$(date +%s)"
$CONTAINER_CLI rm -f "$CONTAINER_ID" 2>/dev/null || true

$CONTAINER_CLI run -d --name "$CONTAINER_ID" --privileged -v "$TARGET_DIR:/u01_mount:z" docker.io/oraclelinux:8 sleep 3600

trap '$CONTAINER_CLI rm -f "$CONTAINER_ID" 2>/dev/null || true; rm -f "$TARGET_DIR/build_inside.sh"' EXIT

$CONTAINER_CLI exec "$CONTAINER_ID" /u01_mount/build_inside.sh
$CONTAINER_CLI exec "$CONTAINER_ID" sh -c 'rm -rf /tmp/* /var/tmp/* /u01/infra_extract /u01/oas_extract /root/.cache /u01/oracle/.inventory/logs/*.log /var/cache/dnf /var/cache/yum /u01/oracle/cfgtoollogs/* 2>/dev/null || true'

echo "💾 Committing container instance to image '$IMAGE_NAME'..."
TMPDIR=/var/tmp $CONTAINER_CLI commit \
  --change "USER oracle" \
  --change "WORKDIR /u01/oracle" \
  --change "ENV ORACLE_HOME=/u01/oracle JAVA_HOME=/usr/java/default PATH=/usr/java/default/bin:/u01/oracle/bin:\$PATH DOMAIN_NAME=bi DOMAINS_DIR=/u01/oracle/user_projects/domains DOMAIN_HOME=/u01/oracle/user_projects/domains/bi" \
  --change "EXPOSE 9502 9503 9500-9999" \
  --change "CMD [\"/u01/createAndStartDomain.sh\"]" \
  "$CONTAINER_ID" "$IMAGE_NAME"

$CONTAINER_CLI tag "$IMAGE_NAME" "localhost/oracle-publisher:latest" >/dev/null 2>&1 || true
$CONTAINER_CLI tag "$IMAGE_NAME" "localhost/oracle-publisher:${VERSION}" >/dev/null 2>&1 || true
$CONTAINER_CLI rm -f "$CONTAINER_ID" 2>/dev/null || true
rm -f "$TARGET_DIR/build_inside.sh"
trap - EXIT

BUILD_END=$(date '+%s')
BUILD_ELAPSED=$(( BUILD_END - BUILD_START ))

echo "✅ Image '$IMAGE_NAME' built successfully in ${BUILD_ELAPSED}s!"
