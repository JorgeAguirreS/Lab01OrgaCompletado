param([switch]$SoloTerminal)
Set-Location -LiteralPath $PSScriptRoot

if (-not $SoloTerminal) {
    $editor = Get-Command code -ErrorAction SilentlyContinue
    $editorPath = if ($editor) { $editor.Source } else { Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd' }
    if (Test-Path -LiteralPath $editorPath) {
        & $editorPath --new-window $PSScriptRoot (Join-Path $PSScriptRoot 'EXAMEN.md')
    } else {
        Write-Host 'Abra esta carpeta en su editor para modificar los archivos de estudiante.'
    }
}

Write-Host ''
Write-Host 'SIMULACRO DE ORGANIZACION - TERMINAL DE PRACTICA' -ForegroundColor Cyan
Write-Host "Carpeta: $PSScriptRoot"
Write-Host ''
Write-Host '1. Lea EXAMEN.md en el editor.'
Write-Host '2. Complete los TODO EXAMEN en plugin/ejercicios.cpp y los archivos asm/ej*.asm.'
Write-Host '3. Guarde sus cambios y ejecute: .\check.ps1'
Write-Host ''
Write-Host 'Comandos disponibles:'
Write-Host '  .\build.ps1                Compilar C++'
Write-Host '  .\check.ps1                Ejecutar las pruebas visibles'
Write-Host '  .\check.ps1 -Ejercicio 3   Probar solo el ejercicio 3'
Write-Host '  .\evaluar.ps1              Evaluacion final, solo al terminar'
Write-Host ''
Write-Host 'Los ejercicios se entregan sin resolver: los fallos iniciales son esperados.' -ForegroundColor Yellow
Write-Host 'En VS Code: Ctrl+Shift+B ejecuta las pruebas visibles en la terminal integrada.'
Write-Host ''
