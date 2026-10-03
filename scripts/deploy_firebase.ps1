param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectId
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
  throw "No se encontró Firebase CLI. Instálelo con: npm install -g firebase-tools"
}

Push-Location $projectRoot
try {
  & firebase use $ProjectId
  if ($LASTEXITCODE -ne 0) { throw "No se pudo seleccionar el proyecto Firebase." }
  & firebase deploy --only firestore:rules,firestore:indexes
  if ($LASTEXITCODE -ne 0) { throw "Falló el despliegue de Firestore." }
} finally {
  Pop-Location
}
