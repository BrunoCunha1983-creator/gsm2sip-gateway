#!/usr/bin/env bash
set -euo pipefail
if [[ ${EUID} -ne 0 ]]; then echo 'ERRO: execute como root.' >&2; exit 1; fi
systemctl disable --now gsm2sip-gateway 2>/dev/null || true
rm -f /etc/systemd/system/gsm2sip-gateway.service
rm -f /usr/local/sbin/gsm2sip-pve-check
rm -rf /opt/gsm2sip
systemctl daemon-reload
echo 'GSM2Sip Gateway removido.'
echo 'Configuração preservada em /etc/gsm2sip e dados em /var/lib/gsm2sip.'
echo 'usb-modeswitch foi mantido para não afetar outros dispositivos USB.'
