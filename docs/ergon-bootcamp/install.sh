#!/bin/bash
set -e

# ergon-bootcamp 설치 스크립트
# 사용법: curl -fsSL https://genobj.github.io/download-center/ergon-bootcamp/install.sh | sudo bash
# 또는:  curl -fsSL https://genobj.github.io/download-center/ergon-bootcamp/install.sh | sudo bash -s -- beta

# 옵션
CHANNEL="${1:-stable}"  # stable 또는 beta

BASE_URL="https://genobj.github.io/download-center"

if [ "$CHANNEL" = "beta" ]; then
  JSON_URL="$BASE_URL/ergon-bootcamp-beta/latest.json"
else
  JSON_URL="$BASE_URL/ergon-bootcamp/latest.json"
fi

# OS 감지
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

case "$OS" in
  linux)
    PLATFORM="linux-x86_64"
    ;;
  *)
    echo "Unsupported OS: $OS (only Linux is supported)"
    exit 1
    ;;
esac

# latest.json 파싱 (순수 bash - jq/python 불필요)
DOWNLOAD_URL=$(curl -s "$JSON_URL" | tr -d '\n\r ' | sed -n "s/.*\"${PLATFORM}\":{\"url\":\"\([^\"]*\)\".*/\1/p")

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Failed to get download URL for $PLATFORM"
  echo "JSON URL: $JSON_URL"
  exit 1
fi

# 다운로드 및 설치
echo "Downloading ergon-bootcamp from $DOWNLOAD_URL..."
TMP_DEB=$(mktemp)
curl -L -o "$TMP_DEB" "$DOWNLOAD_URL"
dpkg -i "$TMP_DEB"
rm "$TMP_DEB"

echo "ergon-bootcamp installed successfully!"
