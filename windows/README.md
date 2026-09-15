# GSM2Sip Gateway — Windows

Versão Windows totalmente separada da edição Linux/Debian.

## Instalação

```powershell
irm https://raw.githubusercontent.com/BrunoCunha1983-creator/gsm2sip-gateway/main/windows/install.ps1 | iex
```

O script descarrega `windows/source/GSM2Sip-Gateway-V1.0.3-Voice-Core-Source.zip`, usa Go instalado ou uma toolchain Go temporária, compila a app e o setup e inicia o instalador.

## Build manual

```powershell
.\build.ps1
```

Requer Go 1.23+ e cria `windows/dist/` localmente.
