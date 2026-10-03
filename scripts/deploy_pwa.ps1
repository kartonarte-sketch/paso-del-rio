param(
  [string]$ProjectId = "paso-del-rio-hotel"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$flutter = "D:\AppsMoviles\flutter\bin\flutter.bat"

if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
  throw "No se encontró Firebase CLI. Instálelo con: npm install -g firebase-tools"
}

Set-Location $projectRoot
& $flutter pub get
if ($LASTEXITCODE -ne 0) { throw "flutter pub get falló." }
& $flutter build web --release
if ($LASTEXITCODE -ne 0) { throw "flutter build web falló." }

& firebase use $ProjectId
if ($LASTEXITCODE -ne 0) { throw "No se pudo seleccionar el proyecto Firebase." }
& firebase deploy --only hosting
if ($LASTEXITCODE -ne 0) { throw "Falló el despliegue de Hosting." }

Write-Host "PWA publicada exitosamente." -ForegroundColor Green
Write-Host "Abre: https://$ProjectId.web.app" -ForegroundColor Cyan
Write-Host "Procesos:" -ForegroundColor Yellow
Write-Host " - Dashboard:   https://$ProjectId.web.app/#/dashboard"
Write-Host " - Recepción:   https://$ProjectId.web.app/#/recepcion"
Write-Host " - Reservas:    https://$ProjectId.web.app/#/reservas"
Write-Host " - Eventos:     https://$ProjectId.web.app/#/eventos"
Write-Host " - Mesas:       https://$ProjectId.web.app/#/mesas"
Write-Host " - Comandas:    https://$ProjectId.web.app/#/comandas"
Write-Host " - Producción:  https://$ProjectId.web.app/#/produccion"
Write-Host " - Caja:        https://$ProjectId.web.app/#/caja"
Write-Host " - Barra:       https://$ProjectId.web.app/#/barra"
Write-Host " - Admin:       https://$ProjectId.web.app/#/admin"
