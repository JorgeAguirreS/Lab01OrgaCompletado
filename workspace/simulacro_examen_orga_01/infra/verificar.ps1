param([ValidateSet('Practica','Final')][string]$Modo, [ValidateRange(0,7)][int]$Ejercicio = 0)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $root
$exitCode = 2
try {
    Write-Host "EXAMEN PRACTICO - ORGANIZACION | $Modo"
    $shellExe = (Get-Process -Id $PID).Path
    & $shellExe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'build.ps1')
    if ($LASTEXITCODE -ne 0) { Write-Host 'Se continuara con los ejercicios cuya biblioteca este disponible.' }
    if (-not (Test-Path -LiteralPath (Join-Path $root 'EasyMIPS.exe'))) { throw 'Falta la copia local de EasyMIPS.exe.' }
    $allExercises = Get-Content -LiteralPath 'infra/ejercicios.json' -Raw -Encoding UTF8 | ConvertFrom-Json
    $selected = @($allExercises | Where-Object { $Ejercicio -eq 0 -or $_.id -eq $Ejercicio })
    # La practica NO abre ni ejecuta los manifiestos de evaluacion adicional.
    $tests = Get-Content -LiteralPath 'tests/practica/manifest.json' -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($Modo -eq 'Final') {
        $tests += (Get-Content -LiteralPath 'evaluacion/manifest.json' -Raw -Encoding UTF8 | ConvertFrom-Json)
    }
    $tests = @($tests | Where-Object { $Ejercicio -eq 0 -or $_.ejercicio -eq $Ejercicio })
    $logDir = Join-Path $root ('resultados/' + $Modo.ToLower())
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $results = @()
    foreach ($test in $tests) {
        $why = ''
        $out = ''
        $err = ''
        $ic = $null
        $dll = if ($test.ejercicio -in @(1,5)) { '.build/examen.dll' } else { '.build/soporte.dll' }
        if (-not (Test-Path -LiteralPath $dll)) {
            $why = 'biblioteca no disponible por error de compilacion'
        } else {
            $argList = @('--run','infra/crt.asm','infra/testlib.asm','infra/servicios.asm',$test.arnes)
            if ($test.alumno) { $argList += $test.alumno }
            $argList += @('--sc-handler',$dll,'--stk-size','16384','--inst-count')
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = Join-Path $root 'EasyMIPS.exe'
            $psi.WorkingDirectory = $root
            $psi.Arguments = (($argList | ForEach-Object { '"' + $_ + '"' }) -join ' ')
            $psi.UseShellExecute = $false
            $psi.CreateNoWindow = $true
            $psi.RedirectStandardInput = $true
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $p = [System.Diagnostics.Process]::Start($psi)
            $p.StandardInput.Close()
            $so = $p.StandardOutput.ReadToEndAsync()
            $se = $p.StandardError.ReadToEndAsync()
            if (-not $p.WaitForExit(5000)) {
                try { $p.Kill() } catch { }
                $p.WaitForExit()
                $why = 'tiempo agotado (5 s): revise terminacion, recursion y $ra'
            }
            $p.WaitForExit()
            $out = $so.Result -replace "`r", ''
            $err = $se.Result -replace "`r", ''
            if (-not $why -and $p.ExitCode -ne 0) { $why = "EasyMIPS termino con codigo $($p.ExitCode)" }
            $p.Dispose()
            if ($out -match '(?m)^Number of instructions: *(\d+)') { $ic = [long]$Matches[1] }
            $actual = ($out -replace '(?m)^Number of instructions:.*\n?', '').TrimEnd([char[]]"`n")
            $expected = ((Get-Content -LiteralPath $test.esperado -Raw -Encoding UTF8) -replace "`r", '').TrimEnd([char[]]"`n")
            if (-not $why -and $actual -cne $expected) { $why = 'resultado o convencion de registros incorrectos' }
            if (-not $why -and $null -eq $ic) { $why = 'no se recibio el conteo de instrucciones' }
            if (-not $why -and $err.Trim()) { $why = 'salida inesperada en stderr (retire la depuracion)' }
            if (-not $why -and $test.max_inst -gt 0 -and $ic -gt $test.max_inst) {
                $why = "costo excesivo: $ic instrucciones; limite $($test.max_inst)"
            }
        }
        # Requisitos de construccion publicados en EXAMEN.md: revision complementaria.
        if ($Modo -eq 'Final' -and $test.alumno) {
            $lines = @(Get-Content -LiteralPath $test.alumno -Encoding UTF8 | ForEach-Object { ($_ -split ';',2)[0] })
            $code = $lines -join "`n"
            $required = switch ([int]$test.ejercicio) {
                2 { @('(?m)^\s*syscall\s*$') }
                3 { @('(?m)^\s*jal\s+popcount\s*$') }
                4 { @('(?m)^\s*jal\s+divmod\s*$') }
                6 { @('(?m)^\s*jal\s+power_u32\s*$','(?m)^\s*multu\s+','(?m)^\s*mflo\s+') }
                7 { @('(?m)^\s*jal\s+ways\s*$','(?m)^\s*jal\s+memo_get\s*$','(?m)^\s*jal\s+memo_put\s*$') }
            }
            foreach ($pattern in $required) {
                if ($code -notmatch $pattern -and -not $why) { $why = 'falta una llamada/instruccion requerida en el enunciado' }
            }
            $forbidden = switch ([int]$test.ejercicio) {
                3 { '(?m)^\s*syscall\s*$' }
                4 { '(?m)^\s*(div|divu|syscall)\b' }
                6 { '(?m)^\s*syscall\s*$' }
                7 { '(?m)^\s*(syscall|jal\s+(memo_clear|stats_clear))\b' }
                default { '(?!)' }
            }
            if ($code -match $forbidden -and -not $why) { $why = 'se usa una instruccion/servicio prohibido para este ejercicio' }
            $allowed = @('li','move','add','addu','addi','addiu','sub','subu','and','andi','or','ori','xor','xori','nor','slt','sltu','slti','sltiu','sll','srl','sra','sllv','srlv','srav','lui','mult','multu','div','divu','mfhi','mflo','mthi','mtlo','lw','sw','lb','lbu','lh','lhu','sb','sh','beq','bne','bgez','bgtz','blez','bltz','j','jal','jr','jalr','syscall','break')
            foreach ($line in $lines) {
                $instruction = ($line -replace '^\s*[.\w]+:\s*','').Trim()
                if ($instruction -and -not $instruction.StartsWith('.')) {
                    $op = ($instruction -split '\s+')[0]
                    if ($op -notin $allowed -and -not $why) { $why = "instruccion no permitida: $op" }
                }
            }
        }
        $ok = $why -eq ''
        $tag = if ($ok) { 'PASS' } else { 'FAIL' }
        $detail = if ($ok) { "$ic instrucciones" } else { $why }
        Write-Host ("[$tag] E{0} {1}: {2}" -f $test.ejercicio,$test.nombre,$detail) -ForegroundColor $(if ($ok) { 'Green' } else { 'Red' })
        if (-not $ok) {
            $diagnostics = @($out -split "`n" | Where-Object { $_ -match 'FALLA' } | Select-Object -First 4)
            $diagnostics += @($err -split "`n" | Where-Object { $_ } | Select-Object -First 4)
            foreach ($line in $diagnostics) { Write-Host ('    ' + $line) }
        }
        [IO.File]::WriteAllText((Join-Path $logDir ($test.id + '.stdout.txt')), $out, $utf8)
        [IO.File]::WriteAllText((Join-Path $logDir ($test.id + '.stderr.txt')), $err, $utf8)
        $results += [pscustomobject]@{id=$test.id; ejercicio=$test.ejercicio; nivel=$test.nivel; ok=$ok; instrucciones=$ic; motivo=$why}
    }
    $score = 0.0
    $maxScore = 0
    Write-Host ''
    foreach ($ex in $selected) {
        $visible = @($results | Where-Object { $_.ejercicio -eq $ex.id -and $_.nivel -eq 'practica' })
        $visiblePass = @($visible | Where-Object { $_.ok }).Count
        $fraction = $visiblePass / [double]$visible.Count
        if ($Modo -eq 'Final') {
            $extra = @($results | Where-Object { $_.ejercicio -eq $ex.id -and $_.nivel -eq 'adicional' })
            $extraPass = @($extra | Where-Object { $_.ok }).Count
            $fraction = 0.4*$fraction + 0.6*($extraPass / [double]$extra.Count)
        }
        $points = [double]$ex.puntos * $fraction
        $score += $points
        $maxScore += $ex.puntos
        Write-Host ('E{0}: {1:N2}/{2} puntos - {3}' -f $ex.id,$points,$ex.puntos,$ex.nombre)
    }
    $passed = @($results | Where-Object { $_.ok }).Count
    Write-Host ("Pruebas aprobadas: $passed/$($results.Count)")
    Write-Host ('Puntuacion orientativa: {0:N2}/{1}' -f $score,$maxScore)
    if ($Modo -eq 'Practica') { Write-Host 'Solo practica. No se ejecutaron las pruebas adicionales.' }
    $summary = [pscustomobject]@{modo=$Modo; puntos=$score; maximo=$maxScore; aprobadas=$passed; total=$results.Count; pruebas=$results}
    [IO.File]::WriteAllText((Join-Path $logDir 'resumen.json'), ($summary | ConvertTo-Json -Depth 6), $utf8)
    $exitCode = if ($passed -eq $results.Count) { 0 } else { 1 }
} catch { Write-Host ('[INFRA] ' + $_.Exception.Message) -ForegroundColor Red }
finally { Pop-Location }
exit $exitCode
