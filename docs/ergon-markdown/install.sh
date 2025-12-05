#!/bin/bash
set -e

# ergon-markdown 설치 스크립트
# 사용법: curl -fsSL https://genobj.github.io/download-center/ergon-markdown/install.sh | bash
# 또는:  curl -fsSL https://genobj.github.io/download-center/ergon-markdown/install.sh | bash -s -- beta

# 옵션
CHANNEL="${1:-stable}"  # stable 또는 beta
INSTALL_DIR="${2:-/usr/local/bin}"

BASE_URL="https://genobj.github.io/download-center"

if [ "$CHANNEL" = "beta" ]; then
  JSON_URL="$BASE_URL/ergon-markdown-beta/latest.json"
else
  JSON_URL="$BASE_URL/ergon-markdown/latest.json"
fi

# OS 감지
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS" in
  linux)
    PLATFORM="linux-x86_64"
    ;;
  darwin)
    if [ "$ARCH" = "arm64" ]; then
      PLATFORM="darwin-aarch64"
    else
      PLATFORM="darwin-x86_64"
    fi
    ;;
  *)
    echo "Unsupported OS: $OS"
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
echo "Downloading ergon-markdown from $DOWNLOAD_URL..."
if [[ "$DOWNLOAD_URL" == *.deb ]]; then
  # .deb 파일
  TMP_DEB=$(mktemp)
  curl -L -o "$TMP_DEB" "$DOWNLOAD_URL"
  sudo dpkg -i "$TMP_DEB"
  rm "$TMP_DEB"
else
  # 바이너리
  sudo curl -L -o "$INSTALL_DIR/ergon-markdown" "$DOWNLOAD_URL"
  sudo chmod +x "$INSTALL_DIR/ergon-markdown"
fi

echo "ergon-markdown installed successfully!"
ergon-markdown --version

