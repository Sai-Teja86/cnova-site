# Vaultgate connector installer for Windows. Run in PowerShell as administrator:
#   & ([scriptblock]::Create((irm https://cnova.in/connector/install.ps1))) -Code 'vgc1...'
# Downloads the connector program, checks its SHA-256 against the value below, installs it as the
# "Vaultgate Connector" service and enrolls it with the code. Nothing else is changed on this machine.
param([string]$Code)
$ErrorActionPreference = 'Stop'
$Version = '0.2.0'
$Sha256 = 'd7cbbaf18ac71959f79b9f08c97943a79bdc738272103f539a32e196bf66ec08'
$Url = "https://cnova.in/connector/vaultgate-connector-$Version.exe"

$me = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $me.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Run this in PowerShell opened as administrator (right-click PowerShell, Run as administrator).' -ForegroundColor Red
    return
}
if (-not $Code) { $Code = Read-Host 'Paste the connector code from Vaultgate (Configuration > Connectors)' }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$exe = Join-Path $env:TEMP "vaultgate-connector-$Version.exe"
Write-Host "Downloading the Vaultgate connector $Version ..."
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $Url -OutFile $exe -UseBasicParsing
$got = (Get-FileHash -Algorithm SHA256 $exe).Hash.ToLower()
if ($got -ne $Sha256) {
    Remove-Item $exe -Force
    Write-Host "The download doesn't match its published SHA-256 ($got): not installed." -ForegroundColor Red
    return
}
& $exe install --code $Code
$rc = $LASTEXITCODE
Remove-Item $exe -Force -ErrorAction SilentlyContinue
if ($rc -ne 0) { Write-Host 'The connector was not installed (see the message above).' -ForegroundColor Red }
