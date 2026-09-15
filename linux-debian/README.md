# GSM2Sip Gateway — Linux / Debian / Proxmox VE

Versão Linux/Debian totalmente separada da edição Windows.

## Instalação

Como `root`:

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoCunha1983-creator/gsm2sip-gateway/main/linux-debian/install.sh | bash
```

O script deteta automaticamente **Proxmox VE**. Em PVE usa o source package PVE Host; em Debian normal usa o source package Linux/Debian. Instala sempre `usb-modeswitch` e `usb-modeswitch-data`.

## Desinstalar

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoCunha1983-creator/gsm2sip-gateway/main/linux-debian/uninstall.sh | bash
```

## Build manual

```bash
./build.sh amd64 pve
./build.sh amd64 debian
./build.sh arm64 debian
```
