# build.ps1 - compila el plugin del Lab 01 en Windows -> plugin\lab01_plugin.dll
#   .\build.ps1
# Necesita UNO de:  g++ de MinGW-w64 (MSYS2)   o   cl de Visual Studio ("Developer PowerShell").
Set-Location -LiteralPath $PSScriptRoot
$src = 'plugin\lab01_plugin.cpp'
$out = 'plugin\lab01_plugin.dll'

if (Get-Command g++ -ErrorAction SilentlyContinue) {
    & g++ -std=c++17 -O2 -Wall -Wextra -shared -static-libgcc -static-libstdc++ -I include -o $out $src
}
elseif (Get-Command cl -ErrorAction SilentlyContinue) {
    & cl /nologo /EHsc /std:c++17 /LD /I include $src "/Fe:$out" "/Fo:plugin\"
}
else {
    Write-Host 'No encuentro un compilador de C++: instale MinGW-w64 (g++) o abra una Developer PowerShell de Visual Studio (cl).' -ForegroundColor Red
    exit 1
}
if ($LASTEXITCODE -ne 0) {
    Write-Host 'ERROR: el plugin no compila. Corrija los errores de plugin\lab01_plugin.cpp y reintente.' -ForegroundColor Red
    exit 1
}
Write-Host "Plugin compilado: $out" -ForegroundColor Green
exit 0
