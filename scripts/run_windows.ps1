param(
  [string]$Settings = "config/windows.settings.json"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$settingsPath = Join-Path $projectRoot $Settings

if (-not (Test-Path -LiteralPath $settingsPath)) {
  throw "Falta $settingsPath. Copie config/windows.settings.example.json y complete los valores."
}

Push-Location $projectRoot
try {
  & "D:\AppsMoviles\flutter\bin\flutter.bat" run -d windows "--dart-define-from-file=$settingsPath"
} finally {
  Pop-Location
}
