param([ValidateRange(0,7)][int]$Ejercicio = 0)
& (Join-Path $PSScriptRoot 'infra/verificar.ps1') -Modo Final -Ejercicio $Ejercicio
exit $LASTEXITCODE
