$ErrorActionPreference = 'Stop'
$Repo = 'BrunoCunha1983-creator/gsm2sip-gateway'
$GoVersion = '1.23.12'
$SourceName = 'GSM2Sip-Gateway-V1.0.3-Voice-Core-Source.zip'
$Work = Join-Path $env:TEMP ('gsm2sip-build-' + [Guid]::NewGuid().ToString('N'))
$Zip = Join-Path $Work $SourceName
$Extract = Join-Path $Work 'source'
New-Item -ItemType Directory -Path $Work -Force | Out-Null

function Get-GoExe {
    $existing = Get-Command go -ErrorAction SilentlyContinue
    if ($existing) { return $existing.Source }
    Write-Host "Go não encontrado. A descarregar Go $GoVersion temporariamente..." -ForegroundColor Yellow
    $goZip = Join-Path $Work 'go.zip'
    Invoke-WebRequest -Uri "https://go.dev/dl/go$GoVersion.windows-amd64.zip" -OutFile $goZip -UseBasicParsing
    Expand-Archive -Path $goZip -DestinationPath $Work -Force
    return (Join-Path $Work 'go\bin\go.exe')
}

try {
    Write-Host 'GSM2Sip Gateway — Windows installer' -ForegroundColor Cyan
    $srcUrl = "https://raw.githubusercontent.com/$Repo/main/windows/source/$SourceName"
    Invoke-WebRequest -Uri $srcUrl -OutFile $Zip -UseBasicParsing
    Expand-Archive -Path $Zip -DestinationPath $Extract -Force
    $Root = Get-ChildItem -Path $Extract -Directory | Select-Object -First 1
    if (-not $Root) { throw 'Não foi possível localizar o código extraído.' }

    $GoExe = Get-GoExe
    $AppDir = Join-Path $Root.FullName 'app'
    $InstallerDir = Join-Path $Root.FullName 'installer'
    $AssetsDir = Join-Path $InstallerDir 'assets'
    $AppExe = Join-Path $AssetsDir 'GSM2SipGateway.exe'
    $SetupExe = Join-Path $Work 'GSM2Sip-Gateway-Setup.exe'

    Push-Location $AppDir
    & $GoExe build -trimpath -ldflags '-s -w -H=windowsgui' -o $AppExe .
    if ($LASTEXITCODE -ne 0) { throw 'Falha a compilar a aplicação.' }
    Pop-Location

    Push-Location $InstallerDir
    & $GoExe build -trimpath -ldflags '-s -w -H=windowsgui' -o $SetupExe .
    if ($LASTEXITCODE -ne 0) { throw 'Falha a compilar o instalador.' }
    Pop-Location

    Write-Host 'Compilação concluída. A iniciar o instalador...' -ForegroundColor Green
    Start-Process -FilePath $SetupExe -Wait
}
finally {
    Pop-Location -ErrorAction SilentlyContinue
    if (Test-Path $Work) { Remove-Item $Work -Recurse -Force -ErrorAction SilentlyContinue }
}
