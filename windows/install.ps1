$ErrorActionPreference = 'Stop'

$Repo = 'BrunoCunha1983-creator/gsm2sip-gateway'
$GoVersion = '1.23.12'
$Work = Join-Path $env:TEMP ('gsm2sip-install-' + [Guid]::NewGuid().ToString('N'))
$Zip = Join-Path $Work 'source.zip'
$Extract = Join-Path $Work 'source'

New-Item -ItemType Directory -Path $Work,$Extract -Force | Out-Null

try {
    Write-Host '== GSM2Sip Gateway Windows =='
    $chunkBase = "https://raw.githubusercontent.com/$Repo/main/windows/source/chunks"
    $builder = New-Object System.Text.StringBuilder
    foreach ($part in @('part00.b64','part01.b64','part02.b64')) {
        Write-Host "A descarregar $part..."
        $txt = (Invoke-WebRequest -UseBasicParsing "$chunkBase/$part").Content.Trim()
        [void]$builder.Append($txt)
    }
    [IO.File]::WriteAllBytes($Zip, [Convert]::FromBase64String($builder.ToString()))
    Expand-Archive $Zip $Extract -Force

    $Root = Get-ChildItem $Extract -Directory | Select-Object -First 1
    if (-not $Root) { throw 'Pacote source inválido.' }
    $AppDir = Join-Path $Root.FullName 'app'
    $InstallerDir = Join-Path $Root.FullName 'installer'

    $go = Get-Command go -ErrorAction SilentlyContinue
    if ($go) {
        $GoExe = $go.Source
    } else {
        Write-Host "Go não encontrado. A usar Go $GoVersion temporariamente..."
        if (-not [Environment]::Is64BitOperatingSystem) { throw 'Windows 32-bit não suportado.' }
        $goZip = Join-Path $Work 'go.zip'
        Invoke-WebRequest -UseBasicParsing "https://go.dev/dl/go$GoVersion.windows-amd64.zip" -OutFile $goZip
        Expand-Archive $goZip $Work -Force
        $GoExe = Join-Path $Work 'go\bin\go.exe'
    }

    $AppExe = Join-Path $InstallerDir 'assets\GSM2SipGateway.exe'
    Push-Location $AppDir
    & $GoExe build -trimpath -ldflags '-s -w -H=windowsgui' -o $AppExe .
    if ($LASTEXITCODE -ne 0) { throw 'Falhou a compilação da aplicação.' }
    Pop-Location

    $Setup = Join-Path $Work 'GSM2Sip-Gateway-Setup.exe'
    Push-Location $InstallerDir
    & $GoExe build -trimpath -ldflags '-s -w -H=windowsgui' -o $Setup .
    if ($LASTEXITCODE -ne 0) { throw 'Falhou a compilação do instalador.' }
    Pop-Location

    Write-Host 'A iniciar o instalador GSM2Sip Gateway...'
    Start-Process -FilePath $Setup -Wait
}
finally {
    Pop-Location -ErrorAction SilentlyContinue
    Remove-Item $Work -Recurse -Force -ErrorAction SilentlyContinue
}
