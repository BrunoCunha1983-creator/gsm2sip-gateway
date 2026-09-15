$ErrorActionPreference = 'Stop'
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Work = Join-Path $env:TEMP ('gsm2sip-local-build-' + [Guid]::NewGuid().ToString('N'))
$Extract = Join-Path $Work 'source'
$SourceZip = Join-Path $Work 'source.zip'
$Dist = Join-Path $Here 'dist'
$ChunkDir = Join-Path $Here 'source\chunks'
New-Item -ItemType Directory -Path $Extract,$Dist -Force | Out-Null
try {
    $builder = New-Object System.Text.StringBuilder
    Get-ChildItem $ChunkDir -Filter 'part*.b64' | Sort-Object Name | ForEach-Object {
        [void]$builder.Append(([IO.File]::ReadAllText($_.FullName)).Trim())
    }
    [IO.File]::WriteAllBytes($SourceZip, [Convert]::FromBase64String($builder.ToString()))
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
