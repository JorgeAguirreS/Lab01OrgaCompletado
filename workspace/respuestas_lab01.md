# Lab 01 — Respuestas y mediciones

Nombre: Jorge Aguirre

Mediciones realizadas el 14 de noviembre de 2026 en Windows, con el EasyMIPS del equipo y el plugin compilado por `build.ps1` en C++17. Se usó una pila de 16384 bytes. Las cifras corresponden a las implementaciones que acompañan este archivo; cambiar sus instrucciones puede cambiar los conteos.

**Verificación oficial: 13 pruebas correctas y 0 con fallas.** El plugin compiló sin advertencias con `-Wall -Wextra`. Las salidas de las mediciones están conservadas en [mediciones_lab01.json](mediciones_lab01.json).

Los ciclos y speedups se calculan con el modelo de la guía: no son tiempos de reloj medidos en la computadora. El código C++ que ejecuta el simulador no se cuenta como instrucciones MIPS.

## Preparación y experimento 0

Se copió `EasyMIPS.exe` desde Descargas a la carpeta del kit. Sin `--sc-handler`, la prueba de hardware se detiene con `Syscall number 20 is not implemented`. Al cargar `plugin/lab01_plugin.dll`, `b_test_hw` pasa con 1972 instrucciones.

Para compilar y verificar desde PowerShell, en esta carpeta:

```powershell
.\build.ps1
.\check.ps1
```

Si la política local impide ejecutar scripts, puede usarse una instancia de PowerShell con la política aplicada únicamente a ese proceso:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\check.ps1
```

## Parte A — Preguntas de C++ y MIPS32

1. **¿Qué ocurre al desplazar un `uint32_t` 32 o más posiciones? ¿Cómo lo evita `rotl`?**

   En los tipos de 32 bits usados por este kit, un desplazamiento con cantidad igual o mayor que 32 tiene comportamiento indefinido en C++. No equivale a rotar ni garantiza devolver cero. Primero reduzco `n` con `n & 31u`. Si queda cero, devuelvo `x` directamente; de otro modo calculo `(x << n) | (x >> (32u - n))`. En esa segunda rama ambas cantidades están entre 1 y 31. Así también funcionan rotaciones de 32, 64 o cualquier múltiplo de 32.

2. **¿Por qué puede desbordarse `r * r`? ¿Qué tipo lo evita?**

   Un `uint32_t` solo representa de 0 a 4294967295. Por ejemplo, `65536² = 4294967296`: si se multiplica en 32 bits sin signo, el resultado se reduce módulo 2³² y queda cero, arruinando la comparación. Uso `static_cast<uint64_t>(mid) * mid`, que convierte un operando **antes** de multiplicar. Convertir el resultado después sería demasiado tarde.

   `isqrt` hace búsqueda binaria con `low = 0` y límite exclusivo `high = 65536`. Mantiene `low² <= x < high²` y termina cuando los límites son consecutivos, devolviendo `low`. Para `0xFFFFFFFF`, el resultado es 65535.

3. **¿Por qué `INT_MIN / -1` no cabe? ¿Qué ocurre al devolver un error?**

   El mínimo con signo de 32 bits es −2147483648 y el máximo es 2147483647. Dividir el mínimo por −1 produciría +2147483648, fuera del rango. Compruebo ese caso y el divisor cero antes de ejecutar `/` o `%`. El plugin devuelve `Overflow` o `DivisionByZero`, respectivamente. EasyMIPS detiene la ejecución y muestra el error. Los arneses `a_div0` y `a_ovf` verifican esas detenciones y pasan con el código de salida esperado, 2.

   Los argumentos se convierten a `int32_t`. La división trunca hacia cero y el residuo tiene el signo del dividendo, salvo cuando es cero: `-17 / 5 = -3`, `-17 % 5 = -2`, y `-17 = (-3)*5 + (-2)`. Los resultados se escriben como `uint32_t` en los registros.

4. **¿Por qué los wrappers no necesitan guardar `$ra` ni crear un marco?**

   Solo ejecutan `li $v0, número`, `syscall` y `jr $ra`. No hacen `jal`, y `syscall` no cambia `$ra`. Tampoco modifican registros `$s` ni requieren variables locales en la pila. En cambio, los cuatro procedimientos que llaman a esos wrappers sí guardan y restauran `$ra`.

### Procedimientos de A

| Procedimiento | Operación | Marco de pila |
|---|---|---|
| `parity` | Llama a `popcount` y conserva el bit menos significativo del resultado con `andi ..., 1`. | 4 bytes: `$ra`. |
| `rotr` | Usa `rotl(x, -n mod 32)`. Para `n = 0`, no cambia `x`. | 4 bytes: `$ra`. |
| `is_square` | Conserva `n` en `$s0`, llama a `isqrt`, calcula el cuadrado con `multu`/`mflo` y compara. | 8 bytes: `$ra`, `$s0`. |
| `digit_sum` | Conserva el número pendiente en `$s0` y la suma en `$s1`; llama repetidamente a `divmod(n, 10)`. Para cero devuelve cero. | 12 bytes: `$ra`, `$s0`, `$s1`. |

`isqrt(n) <= 65535`, así que su cuadrado cabe en 32 bits sin signo y se puede comparar usando la parte baja del producto. El dominio de `digit_sum` es el entero no negativo con signo usado por `divmod`, de 0 a 2147483647.

## Parte B — Hardware contra software

### B.1 Implementación en software

`popcount_sw.asm` inicializa el resultado en cero y, mientras el argumento no sea cero, extrae un bit con `andi`, lo suma y desplaza la palabra con `srl`. El desplazamiento es lógico: introduce ceros incluso si estaba encendido el bit 31. No usa ninguna syscall.

`b_test_sw` pasa con 2664 instrucciones y `b_main_sw` con 8899.

### B.2 Costo de un caso

Se ejecutó `b_one.asm` para cada valor y cada implementación con `--inst-count`. Solo se cambió la palabra `valor` durante las mediciones; al terminar se restauró el archivo original, con `0x0000FFFF`.

```text
instrucciones de popcount = total con la implementación − total con el stub + 1
```

| Valor de `x` | Total con `popcount_sw` | Total con `popcount_hw` | Total con `popcount_stub` | Instrucciones de `popcount_sw` | Instrucciones de `popcount_hw` |
|---|---:|---:|---:|---:|---:|
| `0x00000000` | 32 | 32 | 30 | 3 | 3 |
| `0x00000001` | 36 | 32 | 30 | 7 | 3 |
| `0x0000FFFF` | 96 | 32 | 30 | 67 | 3 |
| `0x80000000` | 160 | 32 | 30 | 131 | 3 |
| `0xFFFFFFFF` | 160 | 32 | 30 | 131 | 3 |
| `0x12345678` | 148 | 32 | 30 | 119 | 3 |

Sea `k` la posición del bit más alto encendido más uno, numerando los bits de 0 a 31; para cero, `k = 0`. Para `x > 0`, `k = floor(log2(x)) + 1`.

**Fórmula de esta implementación: `I_sw(x) = 4k + 3`.**

- Hay tres instrucciones fijas: `move` inicial, `beq` inicial y `jr` final.
- Cada iteración ejecuta cuatro: `andi`, `addu`, `srl` y `bne`, incluso en la última iteración, cuyo salto no se toma.
- Los valores de `k` en la tabla son 0, 1, 16, 32, 32 y 29.

El wrapper de hardware siempre tiene 3 instrucciones, pero cuesta **12 ciclos** cuando la syscall cuesta 10: `1 + 10 + 1`. Tener el mismo número de instrucciones para `x = 0` no implica el mismo número de ciclos.

Ejemplo de comando de medición en Windows, todo en una línea:

```powershell
.\EasyMIPS.exe --run asm/crt.asm asm/testlib.asm asm/parte_b/b_one.asm asm/parte_b/popcount_sw.asm --sc-handler plugin/lab01_plugin.dll --stk-size 16384 --inst-count
```

Para las otras versiones se cambia únicamente el último archivo `.asm` por `popcount_hw.asm` o `popcount_stub.asm`. El stub solo sirve para medir la parte común: no calcula el resultado correcto. Para medir el programa completo se reemplaza `b_one.asm` por `b_main.asm`.

### B.3 Programa completo y ley de Amdahl

Modelo: cada instrucción cuesta 1 ciclo, salvo la syscall 20, que cuesta 10 ciclos. Se usa el mismo período de reloj para comparar.

| Medición | Valor |
|---|---:|
| Instrucciones con `popcount_sw` | 8899 |
| Instrucciones con `popcount_hw` | 927 |
| Instrucciones con `popcount_stub` | 799 |
| Cantidad de syscalls 20 ejecutadas en la versión HW | 64 |
| `ciclos_sw` | 8899 |
| `ciclos_hw = 927 + 9 × 64` | 1503 |
| **Speedup medido**, `8899 / 1503` | **5.920825×** |
| Fracción `f` del tiempo original en `popcount` | `8164 / 8899 = 0.917406450` (91.740645 %) |
| Speedup `S` de esa parte | `8164 / 768 = 10.630208333×` |
| **Speedup por Amdahl** | **5.920825×** |
| Speedup máximo si todo el cuerpo de `popcount` costara 0 ciclos | `8899 / 735 = 12.107483×` |
| Speedup si la syscall costara 40 ciclos | `8899 / 3423 = 2.599766×` |
| Costo por syscall a partir del cual el hardware deja de convenir | Empate en **125.5625 ciclos**; con costos enteros, deja de convenir desde **126 ciclos**. |

El total del stub incluye 64 retornos `jr $ra`. Como el cuerpo que comparamos incluye el retorno, hay que descontarlos para aislar la parte común:

```text
C_común   = 799 − 64 = 735
C_sw_pop  = 8899 − 799 + 64 = 8164
C_hw_pop  = 64 × (1 + 10 + 1) = 768

f = 8164 / 8899
S = 8164 / 768

1 / ((1 − f) + f / S)
= 1 / (735/8899 + 768/8899)
= 8899 / 1503
= 5.920825×
```

Coinciden porque Amdahl divide exactamente el mismo tiempo original entre una parte que permanece en 735 ciclos y otra que pasa de 8164 a 768. Las diferencias que pudieran aparecer usando decimales redondeados serían solo de redondeo.

Si `c` es el costo de la syscall, el tiempo total de hardware es:

```text
C_hw(c) = 735 + 64 × (c + 2)
```

Con `c = 40`, da 3423 ciclos. Para hallar el empate con software:

```text
735 + 64 × (c + 2) = 8899
c = (8899 − 735)/64 − 2 = 125.5625
```

Por debajo de ese costo gana el hardware; en ese costo empatan; por encima gana el software. Si todo el cuerpo de `popcount` fuera gratuito, quedarían los 735 ciclos comunes. Eso es distinto de hacer gratuita solo la syscall: los `li` y `jr` todavía costarían 128 ciclos entre todas las llamadas.

**Una sola llamada:** el software gana cuando `4k + 3 < 12`, es decir, `k <= 2`. Por tanto, gana para **`x = 0, 1, 2, 3`**, con 3, 7, 11 y 11 ciclos respectivamente. Para cualquier `x >= 4`, interpretado sin signo, gana el hardware en este modelo. No hay empate exacto a 12 ciclos.

Como referencia de CPI: el software tiene CPI 1; el programa de hardware tiene CPI promedio `1503/927 = 1.621359`. Aunque su CPI es mayor, ejecuta muchas menos instrucciones y termina antes.

### B.4 Reto opcional: Kernighan

Implementado en [asm/parte_b/popcount_kernighan.asm](asm/parte_b/popcount_kernighan.asm), sin sustituir la versión bit a bit requerida en B.1. Se carga en lugar de otra implementación de `popcount`.

| Medición | Valor |
|---|---:|
| Instrucciones de `b_main` con Kernighan | 5171 |
| Ciclos de `b_main` con Kernighan | 5171 |
| Costo de su cuerpo en las 64 llamadas | `5171 − 799 + 64 = 4436` ciclos |
| Costo de syscall con el que el hardware empata | `4436/64 − 2 = 67.3125` ciclos |
| Prueba `b_test.asm` con Kernighan | 2412 instrucciones; salida y convención de registros correctas. |

Sea `p = popcount(x)`. Esta versión cuesta **`4p + 3` instrucciones**, porque cada iteración apaga un bit encendido. En las 64 palabras hay 1061 bits encendidos: `4 × 1061 + 3 × 64 = 4436` instrucciones en los cuerpos.

Para el programa completo, Kernighan mejora el software original, pero no gana al hardware con syscall de 10 ciclos: necesita 5171 ciclos frente a 1503. El hardware es `5171/1503 = 3.440452×` más rápido. Con costos enteros, el hardware gana hasta 67 ciclos por syscall y pierde desde 68. Para una llamada aislada, Kernighan gana al wrapper de 12 ciclos si la palabra tiene como máximo dos bits encendidos.

| `x` | Total medido con Kernighan en `b_one` | Cuerpo de Kernighan |
|---|---:|---:|
| `0x00000000` | 32 | 3 |
| `0x00000001` | 36 | 7 |
| `0x0000FFFF` | 96 | 67 |
| `0x80000000` | 36 | 7 |
| `0xFFFFFFFF` | 160 | 131 |
| `0x12345678` | 84 | 55 |

**Caso límite:** uso `addiu $t0, $a0, -1`. Para `0x80000000`, el patrón se transforma en `0x7FFFFFFF` y el AND deja cero, sin excepción. `addi` interpretaría la operación como `−2147483648 − 1`, que desborda el rango con signo. `addiu` no genera excepción por desbordamiento y conserva los 32 bits bajos; su inmediato sigue extendiéndose con signo, de modo que `-1` sí representa una resta de uno.

## Parte C — Un dispositivo con memoria

### C.1 Preguntas

1. **¿Por qué `memo_get` devuelve «existe» en `$v1`?**

   Todos los valores de 32 bits con signo son datos válidos, incluidos −1 y cero. Ninguno puede reservarse como indicador de ausencia sin perder un valor representable. `$v1 = 1` indica una entrada existente aunque su valor sea cero; `$v1 = 0` indica ausencia y entonces `$v0` se fija en cero. También se aceptan claves negativas.

2. **¿Qué diferencia hay entre `g_memo[k]` y `g_memo.find(k)`?**

   `g_memo[k]` inserta una entrada con valor inicial cero cuando la clave no existe. Si se usara para consultar, aumentaría `memo_size` y futuras búsquedas confundirían esa entrada accidental con un valor calculado. `find(k)` devuelve un iterador, o `end()` si no existe, sin insertar. Por eso uso `[]` para `memo_put`, donde insertar o reemplazar sí es lo esperado, y `find` para `memo_get`.

   El mapa es `static`: persiste entre syscalls mientras esté cargado el plugin. `memo_clear` lo vacía. No es una variable local nueva en cada llamada ni una memoria persistente entre ejecuciones independientes de EasyMIPS.

### C.2 y C.3 Registros y pila

| Procedimiento | Registros que guarda en la pila | Motivo |
|---|---|---|
| `fib_memo` (etiqueta `fib`) | `$ra`, `$s0`, `$s1`; marco de 12 bytes. | `$ra` conserva el regreso del llamador durante la recursión; `$s0` conserva `n`; `$s1` conserva `fib(n−1)` durante `fib(n−2)` y después conserva el resultado total durante `memo_put`. |
| `collatz_memo` (etiqueta `collatz_len`) | `$ra`, `$s0`, `$s1`; marco de 12 bytes. | `$ra` conserva el regreso; `$s0` conserva el `n` original que será la clave; `$s1` conserva `1 + collatz_len(siguiente)` durante `memo_put`. |

En ambos procedimientos se resta 12 a `$sp` al entrar y se suma 12 al salir. Todas las rutas —caso base, acierto de caché y cálculo nuevo— llegan al mismo epílogo que restaura los tres registros. La pila queda alineada a 4 bytes.

Los casos base se resuelven directamente, como pide el esquema del kit: `fib(0) = 0`, `fib(1) = 1` y `collatz_len(1) = 0`. Los demás valores consultan primero la tabla. Un acierto devuelve `$v0`; un fallo calcula y guarda. Después de `memo_put`, el resultado se recupera de `$s1`: no se supone que `$v0` conserve el valor anterior a la syscall.

`c_fib_big` pasa con **`fib(46) = 1836311903`**, en **2346 instrucciones**. `fib(47) = 2971215073` ya no cabe en 32 bits con signo.

### C.4 Análisis de instrucciones

| Programa | Instrucciones sin memoria | Instrucciones con memoria | Cociente sin/con memoria |
|---|---:|---:|---:|
| `c_fib_main` (fib 0, 1, 2, 10, 20, 25) | 4238580 | 1933 | **2192.747025×** |
| `c_collatz_main` (casos iniciales del arnés y recorrido de 1 a 999) | 510756 | 81871 | **6.238546×** |

Son conteos del arnés completo, incluidas impresión y comprobación de registros. La tabla de memoización se vacía una vez al principio; después se comparte entre las llamadas de cada programa. En Collatz, el resultado de la búsqueda es **n = 871, con 178 pasos**.

1. **¿Por qué Fibonacci mejora mucho más?**

   La versión ingenua de Fibonacci abre dos llamadas por cada caso no base. Esas ramas vuelven a calcular los mismos Fibonacci muchas veces, con un crecimiento exponencial. Con memoria, cada `fib(n)` no base se calcula una sola vez y las consultas repetidas recuperan el resultado: el número de subproblemas distintos crece linealmente con `n`.

   Collatz ingenuo ya usa un lazo corto y recorre una sola cadena por llamada, sin abrir dos ramas recursivas. La memoización reutiliza las colas compartidas por diferentes cadenas, pero añade consultas, inserciones y marcos recursivos. El trabajo repetido que elimina es menor y la sobrecarga pesa más. Aun así, en este arnés reduce las instrucciones unas 6.24 veces.

2. **¿Qué pasa si cada `memo_get` y `memo_put` cuesta 10 ciclos?**

   Se contaron las llamadas ejecutando los mismos arneses con una **copia temporal del plugin instrumentada**. Su salida funcional y conteo de instrucciones coincidieron exactamente con los del plugin normal. El archivo final del plugin no contiene esa instrumentación ni imprime depuración.

   | Programa con memoria | `memo_get` | `memo_put` | Total de llamadas get/put | Ciclos con costo 10 | Speedup frente a naive |
   |---|---:|---:|---:|---:|---:|
   | Fibonacci | 49 | 24 | 73 | `1933 + 9 × 73 = 2590` | `4238580 / 2590 = 1636.517375×` |
   | Collatz | 3230 | 2227 | 5457 | `81871 + 9 × 5457 = 130984` | `510756 / 130984 = 3.899377×` |

   Se suman **9 ciclos adicionales**, porque el conteo ya incluye un ciclo por syscall. Las versiones naive no ejecutan `memo_get` ni `memo_put`. La conclusión se mantiene: ambas versiones con memoria ganan, aunque Collatz baja de una mejora de 6.24× a 3.90× y Fibonacci de 2192.75× a 1636.52×.

   Aquí solo cambió el costo de get/put, tal como precisa la pregunta de la plantilla. Cada arnés también ejecuta un `memo_clear`, tanto con memoria como sin ella. Si se asignaran 10 ciclos también a ese clear, se añadirían 9 ciclos a cada total de ambos lados; seguirían ganando las versiones con memoria. Las syscalls de impresión permanecen a 1 ciclo en este análisis.

## Repaso para la evaluación

- **Recorrido de una syscall:** el programa coloca el número en `$v0` y los argumentos en `$a0`/`$a1`. EasyMIPS resuelve internamente 1, 4, 5, 8, 10, 11 y 12; para las demás llama a `handleSyscall`. El plugin lee y escribe el banco `regs[]`. `$v0`/`$v1` llevan resultados; el `ErrorCode` que devuelve C++ controla si continúa la VM. En este laboratorio no se accede a la memoria MIPS mediante `mem`.
- **`jal` frente a `syscall`:** `jal` reemplaza `$ra`; una función que hace llamadas debe guardar su regreso. `syscall` no reemplaza `$ra`, pero cargar el número ya sobrescribe `$v0`. Argumentos y temporales no son almacenamiento seguro a través de llamadas; los valores que sobreviven se guardan en `$s` o en la pila, conservando los `$s` del llamador.
- **Traza de `fib(4)` con tabla vacía:** fallan las consultas de 4, 3 y 2; se resuelven 1 y 0; se guarda `2 → 1`; se completa y guarda `3 → 2`; la segunda consulta de 2 acierta; finalmente se guarda `4 → 3`. Los casos base no se insertan en esta implementación.
- **Errores que debes reconocer:** no guardar `$ra` pierde la dirección de regreso; usar `$t0` para guardar un valor durante `jal` puede perderlo; olvidar `memo_put` deja la tabla vacía y mantiene el trabajo repetido; olvidar restaurar `$s` o liberar el marco viola la convención.
- **Cálculo de rendimiento:** primero define los ciclos y el trabajo que cambia. Para 64 llamadas, el ajuste del stub es `+64`, no `+1`. Usa `tiempo = instrucciones × CPI × período de reloj`; un menor CPI por sí solo no garantiza menor tiempo. Amdahl limita la mejora por los ciclos que no se aceleran.

## Registro de verificación

| Prueba oficial | Resultado | Instrucciones |
|---|---|---:|
| `a_main` | OK | 14498 |
| `a_div0` | OK: detención esperada | — |
| `a_ovf` | OK: detención esperada | — |
| `b_test_sw` | OK | 2664 |
| `b_test_hw` | OK | 1972 |
| `b_main_sw` | OK | 8899 |
| `b_main_hw` | OK | 927 |
| `c_memo` | OK | 414 |
| `c_fib_naive` | OK | 4238580 |
| `c_fib_memo` | OK | 1933 |
| `c_fib_big` | OK | 2346 |
| `c_collatz_naive` | OK | 510756 |
| `c_collatz_memo` | OK | 81871 |

Se conservaron los archivos de infraestructura, los arneses y las salidas esperadas del kit. El reto opcional se comprobó además con `b_test.asm` y `b_main.asm`, comparando sus salidas completas con los archivos esperados originales.
