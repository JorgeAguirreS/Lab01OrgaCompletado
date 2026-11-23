param([switch]$Confirmar)
$ErrorActionPreference = 'Stop'
if (-not $Confirmar) {
    Write-Host 'Restaura SOLO los 6 archivos de estudiante y respalda su contenido actual.'
    Write-Host 'Para hacerlo: .\reiniciar.ps1 -Confirmar'
    exit 1
}
$root = [IO.Path]::GetFullPath($PSScriptRoot)
$prefix = $root.TrimEnd('\') + '\'
$manifest = Get-Content -LiteralPath (Join-Path $root '.inicial/archivos.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss_ffff'
$backup = Join-Path $root ('respaldos/' + $stamp)
$files = @()
foreach ($entry in $manifest.PSObject.Properties) {
    $relative = $entry.Name
    $target = [IO.Path]::GetFullPath((Join-Path $root $relative))
    $source = [IO.Path]::GetFullPath((Join-Path $root ('.inicial/' + $relative)))
    if (-not $target.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase) -or -not $source.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'Ruta fuera del simulacro.' }
    # No atravesar enlaces en las rutas de restauracion.
    foreach ($path in @($target,$source)) {
        $node = $path
        while ($node -and $node.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) {
            if (Test-Path -LiteralPath $node) {
                if ((Get-Item -LiteralPath $node -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Enlace no permitido: $node" }
            }
            $node = Split-Path -Parent $node
        }
    }
    if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -ne $entry.Value) { throw "Plantilla inicial alterada: $relative" }
    $files += [pscustomobject]@{Relative=$relative; Source=$source; Target=$target}
}
foreach ($file in $files) {
    $saved = Join-Path $backup $file.Relative
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $saved) | Out-Null
    if (Test-Path -LiteralPath $file.Target) { Copy-Item -LiteralPath $file.Target -Destination $saved }
}
foreach ($file in $files) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $file.Target) | Out-Null
    Copy-Item -LiteralPath $file.Source -Destination $file.Target -Force
}
Write-Host "Restaurados $($files.Count) archivos. Respaldo: $backup"
Write-Host 'Ejecute .\check.ps1 para recompilar y empezar de nuevo.'
