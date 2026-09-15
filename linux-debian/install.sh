#!/usr/bin/env bash
set -euo pipefail
REPO='BrunoCunha1983-creator/gsm2sip-gateway'
GO_VERSION='1.23.12'
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [[ ${EUID} -ne 0 ]]; then echo 'ERRO: execute como root.' >&2; exit 1; fi
if ! command -v apt-get >/dev/null 2>&1; then echo 'ERRO: requer Debian/Proxmox com apt.' >&2; exit 1; fi

ARCH="$(dpkg --print-architecture)"
case "$ARCH" in amd64) GOARCH='amd64';; arm64) GOARCH='arm64';; *) echo "Arquitetura não suportada: $ARCH" >&2; exit 2;; esac
IS_PVE=0
if [[ -d /etc/pve ]] || command -v pveversion >/dev/null 2>&1; then IS_PVE=1; fi

if [[ $IS_PVE -eq 1 ]]; then
  SOURCE_NAME='GSM2Sip-Gateway-V1.0.3-PVE-Host-pve2-Source.zip'
else
  SOURCE_NAME='GSM2Sip-Gateway-V1.0.3-Voice-Core-Linux-Debian-Source.zip'
fi
SOURCE_URL="https://raw.githubusercontent.com/${REPO}/main/linux-debian/source/${SOURCE_NAME}"

echo '== GSM2Sip Gateway Linux/Debian/PVE =='
echo "Arquitetura: $ARCH"
[[ $IS_PVE -eq 1 ]] && echo 'Ambiente: Proxmox VE host' || echo 'Ambiente: Debian/Linux'

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl unzip usb-modeswitch usb-modeswitch-data udev iproute2

if command -v go >/dev/null 2>&1; then
  GO_BIN="$(command -v go)"
else
  echo "Go não encontrado. A usar Go ${GO_VERSION} temporariamente..."
  curl -fL "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz" -o "$TMP/go.tar.gz"
  tar -C "$TMP" -xzf "$TMP/go.tar.gz"
  GO_BIN="$TMP/go/bin/go"
fi

curl -fL "$SOURCE_URL" -o "$TMP/source.zip"
unzip -q "$TMP/source.zip" -d "$TMP/source"
ROOT="$(find "$TMP/source" -mindepth 1 -maxdepth 1 -type d | head -n1)"
APP="$ROOT/app"

mkdir -p /opt/gsm2sip /etc/gsm2sip /var/lib/gsm2sip
(
  cd "$APP"
  CGO_ENABLED=0 GOOS=linux GOARCH="$GOARCH" "$GO_BIN" build -trimpath -ldflags '-s -w' -o /opt/gsm2sip/gsm2sip-gateway .
)
chmod 0755 /opt/gsm2sip/gsm2sip-gateway

if [[ ! -f /etc/gsm2sip/gsm2sip.json ]]; then
  if [[ -f "$ROOT/default-gsm2sip.json" ]]; then
    install -m 0600 "$ROOT/default-gsm2sip.json" /etc/gsm2sip/gsm2sip.json
  elif [[ -f "$APP/GSM2Sip Gateway/gsm2sip.json" ]]; then
    install -m 0600 "$APP/GSM2Sip Gateway/gsm2sip.json" /etc/gsm2sip/gsm2sip.json
  fi
fi

if [[ $IS_PVE -eq 1 ]]; then
  install -m 0644 "$ROOT/gsm2sip-gateway.service" /etc/systemd/system/gsm2sip-gateway.service
  install -m 0755 "$ROOT/gsm2sip-pve-check" /usr/local/sbin/gsm2sip-pve-check
else
  cat >/etc/systemd/system/gsm2sip-gateway.service <<'UNIT'
[Unit]
Description=GSM2Sip Gateway - Debian USB GSM to SIP Gateway
After=network-online.target systemd-udevd.service
Wants=network-online.target
[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/var/lib/gsm2sip
Environment=GSM2SIP_CONFIG=/etc/gsm2sip/gsm2sip.json
ExecStart=/opt/gsm2sip/gsm2sip-gateway --service
Restart=on-failure
RestartSec=3
UMask=0077
PrivateTmp=true
ProtectHome=true
ProtectSystem=full
ReadWritePaths=/etc/gsm2sip /var/lib/gsm2sip
[Install]
WantedBy=multi-user.target
UNIT
fi

systemctl daemon-reload
systemctl enable --now gsm2sip-gateway

echo 'Instalação concluída.'
systemctl --no-pager --full status gsm2sip-gateway || true
[[ $IS_PVE -eq 1 ]] && command -v gsm2sip-pve-check >/dev/null 2>&1 && gsm2sip-pve-check || true
