param(
  [int]$Port = 59420
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$flutter = "D:\AppsMoviles\flutter\bin\flutter.bat"

Set-Location $projectRoot
& $flutter pub get
if ($LASTEXITCODE -ne 0) { throw "flutter pub get falló." }

Write-Host "PWA local: http://localhost:$Port"
Write-Host "Procesos:  http://localhost:$Port/#/dashboard  (recepcion, reservas, eventos, mesas, comandas, produccion, caja, barra, admin)"
& $flutter run -d web-server --web-hostname 0.0.0.0 --web-port=$Port
