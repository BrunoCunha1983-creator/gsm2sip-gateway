# GSM2Sip Gateway

Gateway GSM USB ↔ SIP para Windows, Debian/Linux e Proxmox VE.

O objetivo é transformar modems USB GSM compatíveis com voz em trunks SIP normais para PBXs como Asterisk, FreePBX, Issabel e 3CX.

## Estrutura

- `windows/` — aplicação e instalador Windows.
- `linux-debian/` — Debian/Linux e variante para instalação direta no host Proxmox VE.

As duas versões partilham o mesmo conceito funcional, mas os instaladores e a camada de hardware estão separados.

## Estado atual

Versão de desenvolvimento V1.0.3 Voice Core:

- deteção USB e portas série;
- agrupamento das várias interfaces do mesmo modem físico;
- identificação AT;
- suporte inicial Huawei Legacy/CVOICE;
- SIP com porta configurável e escuta apenas em endereços privados;
- conta por modem (`gsm01`, `gsm02`, ...);
- preparação de áudio PCM 8 kHz para RTP/G.711.

O bridge RTP↔PCM e chamadas GSM completas ainda estão em desenvolvimento.

## Instalação rápida

### Proxmox VE / Debian

Na raiz do Proxmox:

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoCunha1983-creator/gsm2sip-gateway/main/linux-debian/install.sh | bash
```

O script deteta Proxmox VE e escolhe automaticamente o pacote PVE Host. `usb-modeswitch` e `usb-modeswitch-data` são instalados como dependências.

### Windows PowerShell

Abrir PowerShell e executar:

```powershell
irm https://raw.githubusercontent.com/BrunoCunha1983-creator/gsm2sip-gateway/main/windows/install.ps1 | iex
```

O script descarrega o instalador Windows desta versão e executa-o.

## Segurança de rede

- SIP usa uma porta configurável.
- `0.0.0.0` e endereços públicos são bloqueados pela aplicação.
- A interface Web de administração escuta apenas em `127.0.0.1:8790` nesta fase.
- O instalador Linux não altera bridges, `/etc/network/interfaces`, `pve-firewall`, VMs ou CTs.

## Licença / desenvolvimento

Projeto em desenvolvimento. Antes de produção, validar interoperabilidade SIP, RTP, áudio USB/serial e comportamento do modem com a operadora usada.
