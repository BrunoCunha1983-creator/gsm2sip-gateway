#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ARCH="${1:-amd64}"
FLAVOR="${2:-debian}"
case "$ARCH" in amd64|arm64) ;; *) echo 'Uso: ./build.sh [amd64|arm64] [debian|pve]' >&2; exit 2;; esac
case "$FLAVOR" in debian|pve) ;; *) echo 'Uso: ./build.sh [amd64|arm64] [debian|pve]' >&2; exit 2;; esac
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
: > "$TMP/source.b64"
for PART in "$HERE"/source/chunks/part*.b64; do cat "$PART" >> "$TMP/source.b64"; done
base64 -d "$TMP/source.b64" > "$TMP/source.zip"
unzip -q "$TMP/source.zip" -d "$TMP/source"
ROOT="$(find "$TMP/source" -mindepth 1 -maxdepth 1 -type d | head -n1)"
mkdir -p "$HERE/dist"
cd "$ROOT/app"
CGO_ENABLED=0 GOOS=linux GOARCH="$ARCH" go build -trimpath -ldflags '-s -w' -o "$HERE/dist/gsm2sip-gateway-linux-${ARCH}-${FLAVOR}" .
echo "Build criada em $HERE/dist"
