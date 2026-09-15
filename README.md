# GSM2Sip Gateway

Gateway GSM USB ↔ SIP para Windows, Debian/Linux e Proxmox VE.

O projeto transforma modems USB GSM compatíveis com voz em trunks SIP normais para PBXs como Asterisk, FreePBX, Issabel e 3CX.

## Plataformas separadas

```text
windows/       → Windows
linux-debian/  → Debian / Linux / Proxmox VE Host
```

Cada plataforma tem código de hardware, script de instalação, build e documentação próprios.

## Instalação Proxmox VE / Debian

Como `root`:

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoCunha1983-creator/gsm2sip-gateway/main/linux-debian/install.sh | bash
```

O instalador integra `usb-modeswitch` e `usb-modeswitch-data`, deteta automaticamente Proxmox VE e instala o serviço `systemd` adequado.

## Instalação Windows

PowerShell:

```powershell
irm https://raw.githubusercontent.com/BrunoCunha1983-creator/gsm2sip-gateway/main/windows/install.ps1 | iex
```

## Estado atual — V1.0.3 Voice Core

- deteção USB e interfaces série;
- modo modem/ZeroCD no Linux através de `usb-modeswitch`;
- agrupamento das interfaces do mesmo modem físico;
- sonda AT;
- Huawei Legacy/CVOICE;
- uma conta SIP por modem (`gsm01`, `gsm02`, ...);
- um IP privado + uma porta SIP configurável;
- preparação PCM 8 kHz/16-bit/20 ms para RTP G.711.

O media bridge RTP↔PCM e a chamada GSM completa continuam em desenvolvimento.

## Segurança

- a aplicação recusa `0.0.0.0` e IPs públicos para SIP;
- a porta SIP é programável;
- interface administrativa atual: `127.0.0.1:8790`;
- o instalador PVE não modifica bridges, firewall do Proxmox, VMs ou CTs.

## Código

- `windows/source/` — source package completo da edição Windows;
- `linux-debian/source/` — source packages Linux/Debian e PVE Host.
