param(
  [string]$Settings = "config/android.settings.json"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$settingsPath = Join-Path $projectRoot $Settings

if (-not (Test-Path -LiteralPath $settingsPath)) {
  throw "Falta $settingsPath. Copie config/android.settings.example.json y complete HUB_URL y HUB_SECRET."
}

Push-Location $projectRoot
try {
  & "D:\AppsMoviles\flutter\bin\flutter.bat" build apk --release "--dart-define-from-file=$settingsPath"
} finally {
  Pop-Location
}
