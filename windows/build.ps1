$ErrorActionPreference = 'Stop'
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceZip = Join-Path $Here 'source\GSM2Sip-Gateway-V1.0.3-Voice-Core-Source.zip'
$Work = Join-Path $env:TEMP ('gsm2sip-local-build-' + [Guid]::NewGuid().ToString('N'))
$Extract = Join-Path $Work 'source'
$Dist = Join-Path $Here 'dist'
New-Item -ItemType Directory -Path $Extract,$Dist -Force | Out-Null
try {
    Expand-Archive $SourceZip $Extract -Force
    $Root = Get-ChildItem $Extract -Directory | Select-Object -First 1
    $AppDir = Join-Path $Root.FullName 'app'
    $InstallerDir = Join-Path $Root.FullName 'installer'
    $AppExe = Join-Path $InstallerDir 'assets\GSM2SipGateway.exe'
    Push-Location $AppDir
    go build -trimpath -ldflags '-s -w -H=windowsgui' -o $AppExe .
    Pop-Location
    Push-Location $InstallerDir
    go build -trimpath -ldflags '-s -w -H=windowsgui' -o (Join-Path $Dist 'GSM2Sip-Gateway-Setup.exe') .
    Pop-Location
    Copy-Item $AppExe (Join-Path $Dist 'GSM2SipGateway.exe') -Force
    Write-Host "Build criada em $Dist"
}
finally {
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item $Work -Recurse -Force -ErrorAction SilentlyContinue
}
