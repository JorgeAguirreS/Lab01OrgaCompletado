# Compila solo dentro de este simulacro. Requiere g++ de MinGW-w64 en PATH.
$ErrorActionPreference = 'Stop'
Push-Location -LiteralPath $PSScriptRoot
$code = 1
try {
    New-Item -ItemType Directory -Force -Path '.build' | Out-Null
    # Nunca ejecutar una biblioteca anterior si la compilacion actual falla.
    foreach ($name in @('soporte.dll', 'examen.dll')) {
        $p = Join-Path $PSScriptRoot ('.build\' + $name)
        if (Test-Path -LiteralPath $p) { Remove-Item -LiteralPath $p }
    }
    if (-not (Get-Command g++ -ErrorAction SilentlyContinue)) {
        throw 'No se encuentra g++ (MinGW-w64) en PATH.'
    }
    $common = @('-std=c++17', '-O2', '-Wall', '-Wextra', '-shared', '-static-libgcc', '-static-libstdc++', '-Iinclude', '-Iplugin')
    & g++ @common '-DEXAM_ONLY_PROVIDED' '-o' '.build/soporte.dll' 'plugin/runtime.cpp'
    $support = $LASTEXITCODE
    & g++ @common '-o' '.build/examen.dll' 'plugin/runtime.cpp' 'plugin/ejercicios.cpp'
    $student = $LASTEXITCODE
    if ($support -eq 0 -and $student -eq 0) {
        Write-Host '[BUILD] Compilacion correcta.' -ForegroundColor Green
        $code = 0
    } else {
        Write-Host '[BUILD] Error de compilacion. Revise los mensajes anteriores.' -ForegroundColor Red
        if ($student -ne 0 -and (Test-Path -LiteralPath '.build/examen.dll')) { Remove-Item -LiteralPath '.build/examen.dll' }
        if ($support -ne 0 -and (Test-Path -LiteralPath '.build/soporte.dll')) { Remove-Item -LiteralPath '.build/soporte.dll' }
    }
} catch { Write-Host ('[BUILD] ' + $_.Exception.Message) -ForegroundColor Red }
finally { Pop-Location }
exit $code
