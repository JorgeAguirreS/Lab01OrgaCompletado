#!/bin/sh
# =============================================================================
#  check.sh - autoverificacion del Lab 01 (Linux / macOS / Git Bash).
#
#    ./check.sh            ejecuta todas las pruebas
#    ./check.sh a          solo las pruebas cuyo id empieza con "a"  (a_main, a_div0, ...)
#    ./check.sh c_fib      solo las que empiezan con "c_fib"
#
#  Necesita el ejecutable de EasyMIPS: se busca en ./EasyMIPS, ./tools/EasyMIPS, en el
#  PATH, o en la variable de entorno EASYMIPS (EASYMIPS=/ruta/a/EasyMIPS ./check.sh).
#  Compila el plugin con "make plugin" antes de empezar.
# =============================================================================
cd "$(dirname "$0")" || exit 2
FILTER="$1"

EASYMIPS=${EASYMIPS:-}
if [ -z "$EASYMIPS" ]; then
    for c in ./EasyMIPS ./tools/EasyMIPS ./EasyMIPS.exe ./tools/EasyMIPS.exe "$(command -v EasyMIPS 2>/dev/null)"; do
        if [ -n "$c" ] && [ -x "$c" ]; then EASYMIPS=$c; break; fi
    done
fi
if [ -z "$EASYMIPS" ] || [ ! -x "$EASYMIPS" ]; then
    echo "No encuentro EasyMIPS. Copie el ejecutable a esta carpeta o defina EASYMIPS=/ruta/a/EasyMIPS" >&2
    exit 2
fi

if ! make -s plugin; then
    echo "ERROR: el plugin no compila. Corrija los errores de plugin/lab01_plugin.cpp y reintente." >&2
    exit 2
fi
case "$(uname -s 2>/dev/null)" in
    Darwin) EXT=dylib ;;
    MINGW*|MSYS*|CYGWIN*) EXT=dll ;;
    *) EXT=so ;;
esac
PLUGIN=plugin/lab01_plugin.$EXT

TMP=$(mktemp -d 2>/dev/null || echo ".check_tmp")
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT

run_with_timeout() {   # run_with_timeout <segundos> <comando...>
    secs=$1; shift
    if command -v timeout >/dev/null 2>&1; then timeout "$secs" "$@"; else "$@"; fi
}

pass=0; fail=0
while IFS='|' read -r id files expected want_exit min_ic max_ic; do
    case "$id" in ''|'#'*) continue ;; esac
    case "$FILTER" in ''|"$id"*) ;; *) continue ;; esac

    args=""
    for f in $files; do args="$args asm/$f"; done
    run_with_timeout 30 "$EASYMIPS" --run asm/crt.asm $args --sc-handler "$PLUGIN" \
        --stk-size 16384 --inst-count >"$TMP/out" 2>"$TMP/err" </dev/null
    code=$?
    tr -d '\r' <"$TMP/out" >"$TMP/out2"
    ic=$(sed -n 's/^Number of instructions: *//p' "$TMP/out2" | tr -d ' ')
    grep -v '^Number of instructions:' "$TMP/out2" >"$TMP/actual"
    [ -n "$CHECK_SAVE" ] && cp "$TMP/actual" "$CHECK_SAVE/$expected"
    tr -d '\r' <"tests/expected/$expected" >"$TMP/expected"

    why=""
    if [ "$code" = 124 ]; then
        why="tiempo agotado (30 s): lazo infinito o recursion sin fin?"
    elif [ "$code" != "$want_exit" ]; then
        why="codigo de salida $code (se esperaba $want_exit)"
    elif ! cmp -s "$TMP/actual" "$TMP/expected"; then
        why="la salida no coincide con la esperada"
    elif [ "$want_exit" = 0 ] && [ -z "$ic" ]; then
        why="no se pudo leer el numero de instrucciones"
    elif [ "$min_ic" != "-" ] && [ -n "$ic" ] && [ "$ic" -lt "$min_ic" ]; then
        why="solo $ic instrucciones (minimo $min_ic): esta version NO debe usar la syscall"
    elif [ "$max_ic" != "-" ] && [ -n "$ic" ] && [ "$ic" -gt "$max_ic" ]; then
        why="$ic instrucciones (maximo $max_ic): no esta aprovechando la syscall / la memoria"
    fi

    if [ -z "$why" ]; then
        pass=$((pass + 1))
        if [ -n "$ic" ]; then printf '[ OK  ] %-16s %s instrucciones\n' "$id" "$ic"
        else printf '[ OK  ] %s\n' "$id"; fi
    else
        fail=$((fail + 1))
        printf '[FALLA] %-16s %s\n' "$id" "$why"
        echo "         (diferencias:  < esperado   > obtenido)"
        diff "$TMP/expected" "$TMP/actual" | head -12 | sed 's/^/         /'
        [ -s "$TMP/err" ] && head -3 "$TMP/err" | sed 's/^/         stderr: /'
    fi
done < tests/tests.txt

echo
echo "Resultado: $pass pruebas correctas, $fail con fallas."
[ "$fail" = 0 ]
