# =============================================================================
#  check.ps1 - autoverificacion del Lab 01 (Windows PowerShell 5.1 o PowerShell 7).
#
#    .\check.ps1          ejecuta todas las pruebas
#    .\check.ps1 a        solo las pruebas cuyo id empieza con "a"  (a_main, a_div0, ...)
#    .\check.ps1 c_fib    solo las que empiezan con "c_fib"
#
#  Necesita EasyMIPS.exe: se busca en esta carpeta, en .\tools, en el PATH o en la
#  variable de entorno EASYMIPS. Compila el plugin (build.ps1) antes de empezar.
#  Si PowerShell rechaza el script:  Set-ExecutionPolicy -Scope Process Bypass
# =============================================================================
param([string]$Filter = '')
Set-Location -LiteralPath $PSScriptRoot

$easy = $env:EASYMIPS
if (-not $easy) {
    foreach ($c in @('.\EasyMIPS.exe', '.\tools\EasyMIPS.exe')) {
        if (Test-Path -LiteralPath $c) { $easy = (Resolve-Path -LiteralPath $c).Path; break }
    }
}
if (-not $easy) {
    $cmd = Get-Command EasyMIPS -ErrorAction SilentlyContinue
    if ($cmd) { $easy = $cmd.Source }
}
if (-not $easy) {
    Write-Host 'No encuentro EasyMIPS.exe. Copielo a esta carpeta o defina $env:EASYMIPS.' -ForegroundColor Red
    exit 2
}

& "$PSScriptRoot\build.ps1"
if ($LASTEXITCODE -ne 0) { exit 2 }
$plugin = 'plugin\lab01_plugin.dll'

function Invoke-Easy([string[]]$ArgList, [int]$TimeoutSec) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $easy
    $quoted = foreach ($a in $ArgList) { if ($a -match '\s') { '"' + $a + '"' } else { $a } }
    $psi.Arguments = ($quoted -join ' ')
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    $p.StandardInput.Close()
    $so = $p.StandardOutput.ReadToEndAsync()
    $se = $p.StandardError.ReadToEndAsync()
    if (-not $p.WaitForExit($TimeoutSec * 1000)) {
        try { $p.Kill() } catch { }
        return [pscustomobject]@{ Code = 124; Out = ''; Err = ''; Timeout = $true }
    }
    $p.WaitForExit()
    return [pscustomobject]@{ Code = $p.ExitCode; Out = $so.Result; Err = $se.Result; Timeout = $false }
}

$pass = 0
$fail = 0
foreach ($line in (Get-Content -LiteralPath 'tests\tests.txt')) {
    if ($line.Trim() -eq '' -or $line.StartsWith('#')) { continue }
    $f = $line.Split('|')
    $id = $f[0]
    if ($Filter -and -not $id.StartsWith($Filter)) { continue }
    $files = $f[1].Trim().Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
    $expectedFile = $f[2]
    $wantExit = [int]$f[3]
    $minIc = $f[4]
    $maxIc = $f[5]

    $argList = @('--run', 'asm\crt.asm')
    foreach ($x in $files) { $argList += ('asm\' + ($x -replace '/', '\')) }
    $argList += @('--sc-handler', $plugin, '--stk-size', '16384', '--inst-count')

    $r = Invoke-Easy $argList 30
    $out = $r.Out -replace "`r", ''
    $ic = $null
    if ($out -match '(?m)^Number of instructions: *(\d+)') { $ic = [long]$Matches[1] }
    $actualLines = @($out -split "`n" | Where-Object { $_ -notmatch '^Number of instructions:' })
    $actual = $actualLines -join "`n"
    $exp = (Get-Content -LiteralPath ('tests\expected\' + $expectedFile) -Raw) -replace "`r", ''

    $why = ''
    if ($r.Timeout) { $why = 'tiempo agotado (30 s): lazo infinito o recursion sin fin?' }
    elseif ($r.Code -ne $wantExit) { $why = "codigo de salida $($r.Code) (se esperaba $wantExit)" }
    elseif ($actual -cne $exp) { $why = 'la salida no coincide con la esperada' }
    elseif ($wantExit -eq 0 -and $null -eq $ic) { $why = 'no se pudo leer el numero de instrucciones' }
    elseif ($minIc -ne '-' -and $null -ne $ic -and $ic -lt [long]$minIc) { $why = "solo $ic instrucciones (minimo $minIc): esta version NO debe usar la syscall" }
    elseif ($maxIc -ne '-' -and $null -ne $ic -and $ic -gt [long]$maxIc) { $why = "$ic instrucciones (maximo $maxIc): no esta aprovechando la syscall / la memoria" }

    if ($why -eq '') {
        $pass++
        if ($null -ne $ic) { Write-Host ('[ OK  ] {0,-16} {1} instrucciones' -f $id, $ic) -ForegroundColor Green }
        else { Write-Host ('[ OK  ] {0}' -f $id) -ForegroundColor Green }
    }
    else {
        $fail++
        Write-Host ('[FALLA] {0,-16} {1}' -f $id, $why) -ForegroundColor Red
        Write-Host '         (diferencias:  < esperado   > obtenido)'
        $d = Compare-Object ($exp -split "`n") ($actual -split "`n") | Select-Object -First 12
        foreach ($x in $d) {
            $mark = if ($x.SideIndicator -eq '<=') { '< ' } else { '> ' }
            Write-Host ('         ' + $mark + $x.InputObject)
        }
        $errLines = @(($r.Err -replace "`r", '') -split "`n" | Where-Object { $_ -ne '' } | Select-Object -First 3)
        foreach ($e in $errLines) { Write-Host ('         stderr: ' + $e) }
    }
}

Write-Host ''
Write-Host "Resultado: $pass pruebas correctas, $fail con fallas."
if ($fail -eq 0) { exit 0 } else { exit 1 }
