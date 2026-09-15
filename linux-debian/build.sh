#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ARCH="${1:-amd64}"
FLAVOR="${2:-debian}"
case "$ARCH" in amd64|arm64) ;; *) echo 'Uso: ./build.sh [amd64|arm64] [debian|pve]' >&2; exit 2;; esac
if [[ "$FLAVOR" == pve ]]; then SRC='GSM2Sip-Gateway-V1.0.3-PVE-Host-pve2-Source.zip'; else SRC='GSM2Sip-Gateway-V1.0.3-Voice-Core-Linux-Debian-Source.zip'; fi
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
unzip -q "$HERE/source/$SRC" -d "$TMP"
ROOT="$(find "$TMP" -mindepth 1 -maxdepth 1 -type d | head -n1)"
mkdir -p "$HERE/dist"
cd "$ROOT/app"
CGO_ENABLED=0 GOOS=linux GOARCH="$ARCH" go build -trimpath -ldflags '-s -w' -o "$HERE/dist/gsm2sip-gateway-linux-${ARCH}-${FLAVOR}" .
echo "Build criada em $HERE/dist"
