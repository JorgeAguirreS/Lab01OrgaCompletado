# Simulacro de examen práctico — Organización de Computadoras

**Duración recomendada: 110 minutos. Puntaje total: 100 puntos.**

Nombre: ____________________  Inicio: __________  Fin: __________

Complete los fragmentos `TODO EXAMEN` de los archivos de estudiante. El entorno usa MIPS32, EasyMIPS y un plugin en C++17, con las convenciones del Laboratorio 1. Los problemas y los datos de este examen son nuevos. La duración incluye aproximadamente diez minutos de comprobación final.

## Entorno y reglas

1. Trabaje exclusivamente dentro de esta carpeta. No consulte las soluciones del laboratorio original durante la sesión cronometrada.
2. Modifique únicamente los seis archivos enumerados más adelante. Puede ampliar el código, los marcos de pila y las etiquetas locales dentro de esos archivos. Conserve los nombres públicos y los contratos de las funciones. No cambie pruebas, scripts, servicios, cabeceras ni plantillas iniciales.
3. MIPS32: solo instrucciones reales, más `li` y `move`. No use `la`, `beqz`, `bnez`, `blt`, `bgt`, `mul` ni `nop`. Los comentarios empiezan con `;`. Use prefijos distintos para sus etiquetas locales.
4. Argumentos en `$a0`–`$a3`; resultados en `$v0`/`$v1`. Conserve `$s0`–`$s7`, `$sp` y la dirección de regreso de `$ra`. La pila debe permanecer alineada a 4 bytes; ajuste los marcos con `addi $sp, $sp, ±N`. No use variables globales para sustituir la pila.
5. Las funciones llamadas y las syscalls pueden cambiar argumentos y temporales. **El dispositivo proporcionado cambia deliberadamente `$a0`–`$a3` y `$t0`–`$t9` después de cada syscall exitosa**, tanto en práctica como en evaluación. Solo los resultados expresamente especificados son válidos. `memo_put` tampoco conserva `$v0` ni `$v1`.
6. C++17: solo biblioteca estándar, sin entrada/salida de depuración en la entrega. No lance excepciones desde sus handlers. Devuelva el `ErrorCode` correspondiente. No modifique registros fuera de los resultados especificados.
7. Los procedimientos de estudiante no imprimen ni terminan el programa. No use tablas de resultados precalculados, acceso a archivos ni dependencias externas.
8. No debe conectar los ejercicios entre sí: los arneses enlazan cada archivo ASM por separado con los servicios proporcionados. Los ejercicios ASM disponen de su propia biblioteca de soporte aunque el archivo C++ de estudiante tenga errores de compilación.

El ejecutable local ensambla y ejecuta directamente los archivos `.asm`. `build.ps1` compila las bibliotecas C++; los errores de sintaxis ASM aparecen al ejecutar las pruebas.

## Archivos de estudiante

| Archivo | Ejercicios |
|---|---|
| `plugin/ejercicios.cpp` | E1 y E5 |
| `asm/ej02_word_info.asm` | E2 |
| `asm/ej03_hamming.asm` | E3 |
| `asm/ej04_decimal_stats.asm` | E4 |
| `asm/ej06_power.asm` | E6 |
| `asm/ej07_ways.asm` | E7 |

Todos los archivos iniciales compilan. Las respuestas provisionales y los retornos `SyscallNotImplemented` deben reemplazarse al completar cada ejercicio. Los marcos ya entregados pueden ampliarse; no son una restricción sobre la cantidad de registros que necesite.

## Puntaje y distribución sugerida

| Ejercicio | Tema | Puntos | Dificultad | Minutos |
|---|---|---:|---|---:|
| E1 | Separación de campos binarios en C++ | 10 | Básica | 10 |
| E2 | Envoltorio de una syscall con dos resultados | 8 | Básica | 5 |
| E3 | Distancia de Hamming con llamada a un servicio | 12 | Intermedia | 10 |
| E4 | Estadísticas decimales con llamadas repetidas | 15 | Intermedia | 20 |
| E5 | Consulta y retiro de una entrada de memoria | 15 | Intermedia | 10 |
| E6 | Potencia recursiva de 32 bits | 15 | Alta | 15 |
| E7 | Recorridos con recursión y memoización | 25 | Alta | 30 |
| | **Total, más 10 minutos para revisión** | **100** | | **110** |

## E1 — Separación de campos binarios (10 puntos)

Complete `exam_split_low` en `plugin/ejercicios.cpp`. El dispositivo la invoca mediante la **syscall 30**.

- Entrada: `$a0 = x`, palabra de 32 bits sin signo; `$a1 = n`, entero de 32 bits sin signo.
- Sea `k = min(n, 32)`.
- Salida `$v0`: los `k` bits menos significativos de `x`, conservando sus posiciones; los restantes bits deben ser cero.
- Salida `$v1`: los bits restantes de `x`, justificados a la derecha.
- Si `k = 0`, los resultados son `0` y `x`. Si `k = 32`, los resultados son `x` y `0`.
- Devuelva `ErrorCode::Ok` para todas las entradas del dominio. No hay entradas inválidas, incluso cuando `n > 32`.

Ejemplo: `x = 0xABCD`, `n = 8` produce `$v0 = 0xCD` y `$v1 = 0xAB`.

Se exige comportamiento definido en C++ para todo el dominio. No cambie `handleSyscall` ni la interfaz del dispositivo.

## E2 — Envoltorio `word_info` (8 puntos)

Complete `word_info` en `asm/ej02_word_info.asm` como envoltorio de la **syscall 32**, ya implementada en el dispositivo.

- Entrada: `$a0 = x`, palabra sin signo de 32 bits.
- Salida `$v0`: cantidad de posiciones binarias necesarias para representar `x` sin ceros iniciales; para `x = 0`, devuelve 0.
- Salida `$v1`: cantidad de bits encendidos en `x`.

Ejemplo: para `x = 13`, devuelve `$v0 = 4` y `$v1 = 3`.

La función debe invocar la syscall 32 y regresar al llamador. No implemente estas operaciones mediante software ni invoque otra función para sustituir la syscall.

## E3 — Distancia de Hamming (12 puntos)

Complete `hamming` en `asm/ej03_hamming.asm`.

- Entrada: `$a0 = x`, `$a1 = y`, dos palabras de 32 bits.
- Salida: `$v0`, número de posiciones de bit en las que `x` e `y` difieren, entre 0 y 32.
- `$v1` no tiene resultado especificado.

Ejemplo: `hamming(12, 10) = 2`.

**Restricción:** realice exactamente una llamada `jal popcount` por invocación de `hamming`. El procedimiento `popcount` está proporcionado. No cuente bits con un lazo propio ni invoque directamente la syscall 20 desde este archivo.

## E4 — Estadísticas decimales (15 puntos)

Complete `decimal_stats` en `asm/ej04_decimal_stats.asm`.

- Entrada: `$a0 = n`, entero con signo en el intervalo `0..2147483647`.
- Salida `$v0`: cantidad de dígitos de su representación decimal usual, sin ceros iniciales.
- Salida `$v1`: el mayor dígito que aparece en esa representación.
- El número cero tiene un dígito y su mayor dígito es cero.

Ejemplo: para `n = 908`, devuelve `$v0 = 3` y `$v1 = 9`.

**Restricción:** use el procedimiento proporcionado `divmod` mediante `jal` para las divisiones necesarias. No use instrucciones `div`/`divu` en el archivo de estudiante ni conversiones a cadenas. Debe conservar correctamente el estado que necesite entre llamadas.

## E5 — Consulta con retiro de memoria (15 puntos)

Complete `exam_memo_take` en `plugin/ejercicios.cpp`. Corresponde a la **syscall 31** y opera sobre el mismo `g_memo` de los servicios de memoria.

- Entrada: `$a0 = clave`, interpretada como `int32_t`.
- Si la clave existe: `$v0` recibe su valor y `$v1 = 1`; la entrada se elimina de la tabla.
- Si no existe: `$v0 = 0` y `$v1 = 0`; la tabla no cambia.
- Claves y valores pueden ser cualquier entero de 32 bits con signo, incluidos cero y negativos.
- Las demás entradas deben conservarse. Retirar de nuevo una clave ausente no debe crearla.
- Devuelva `ErrorCode::Ok` en ambos casos.

La tabla y los servicios para insertar, consultar, vaciar y contar entradas ya están implementados. No cambie su representación ni mantenga una segunda tabla.

## E6 — Potencia recursiva de 32 bits (15 puntos)

Complete `power_u32` en `asm/ej06_power.asm`.

- Entrada: `$a0 = b`, palabra de 32 bits sin signo; `$a1 = e`, entero en `0..31`.
- Salida: `$v0 = b^e mod 2^32`.
- Por definición de este ejercicio, `b^0 = 1`, incluso para `b = 0`.
- `$v1` no tiene resultado especificado.

Ejemplo: `power_u32(3, 4) = 81`.

**Restricciones:** implemente la recurrencia `P(b, 0) = 1`, `P(b, e) = b × P(b, e−1) mod 2^32` mediante una llamada recursiva `jal power_u32` en cada caso no base. Use `multu` y `mflo` para el producto. No sustituya la recursión por un lazo ni use syscalls para calcular la potencia. El desbordamiento del producto se interpreta módulo `2^32`; no debe generar una excepción por sumar o multiplicar con signo.

## E7 — Recorridos con saltos de 1 o 3 (25 puntos)

Complete `ways` en `asm/ej07_ways.asm`. Se cuenta el número de secuencias ordenadas de saltos de longitud 1 o 3 cuya suma es `n`.

- Entrada: `$a0 = n`, entero en `0..45`.
- Salida: `$v0 = W(n)`, según `W(0) = W(1) = W(2) = 1` y, para `n >= 3`, `W(n) = W(n−1) + W(n−3)`.
- Todos los resultados del dominio caben en 32 bits con signo.
- `$v1` no tiene resultado especificado.

Ejemplo: para `n = 4` hay tres recorridos: `1+1+1+1`, `1+3` y `3+1`; por tanto, `W(4) = 3`.

**Restricciones obligatorias:**

- Resuelva los casos `0`, `1` y `2` directamente, sin insertarlos en la tabla.
- Para `n >= 3`, consulte primero la clave `n` mediante `jal memo_get`. Si existe, devuelva el valor encontrado sin recalcular ni volver a insertarlo.
- Ante un fallo de consulta, calcule mediante llamadas recursivas `jal ways`, de acuerdo con la recurrencia, y guarde el resultado con clave `n` mediante `jal memo_put` antes de regresar.
- La tabla debe persistir entre invocaciones. No la vacíe desde `ways` ni altere claves ajenas. La infraestructura se encarga de iniciar cada prueba.
- Use los servicios dados; no implemente una caché propia, una tabla precalculada ni una solución iterativa.

Las pruebas adicionales comprueban reutilización de entradas, conservación de la tabla y un límite holgado de instrucciones: como máximo 50000 en el grupo de cálculo grande, 10000 en el de entradas precargadas y 20000 en el de llamadas consecutivas. No se exige un marco de pila ni un conteo exacto de instrucciones determinados.

## Servicios proporcionados

Los procedimientos de `infra/servicios.asm` tienen estas interfaces. Todos los argumentos y resultados se transmiten en registros; el plugin no accede a la memoria de EasyMIPS.

| Procedimiento / syscall | Entrada | Resultado o efecto |
|---|---|---|
| `popcount` / 20 | `$a0 = x` | `$v0 = bits encendidos`. |
| `divmod` / 23 | `$a0 = a`, `$a1 = b`, con signo | `$v0 = cociente` truncado a cero, `$v1 = residuo`. Divisor cero o `INT_MIN / -1` detienen el programa. |
| `memo_put` / 24 | `$a0 = clave`, `$a1 = valor` | Inserta o reemplaza. No hay resultado válido en `$v0`/`$v1`. |
| `memo_get` / 25 | `$a0 = clave` | `$v0 = valor`, `$v1 = 1` si existe; ambos cero si falta. No inserta. |
| `memo_clear` / 26 | — | Vacía la tabla. Reservado al arnés. |
| `memo_size` / 27 | — | `$v0 = entradas`. Reservado al arnés. |
| `sys_count` / 28 | `$a0 = número de syscall` | Instrumentación del arnés: número de llamadas a ese servicio. |
| `stats_clear` / 29 | — | Reinicia los contadores del arnés. |
| `device_split` / 30 | Interfaz de E1 | Adaptador de prueba del handler de estudiante. |
| `device_take` / 31 | Interfaz de E5 | Adaptador de prueba del handler de estudiante. |
| Syscall 32 | `$a0 = x` | Ancho binario en `$v0` y bits encendidos en `$v1`. E2 completa su envoltorio. |

Los servicios de instrumentación están implementados. No tiene que modificarlos ni usarlos en su solución.

## Compilar, practicar y evaluar

Desde esta carpeta:

```powershell
.\build.ps1
.\check.ps1
.\check.ps1 -Ejercicio 4
```

`check.ps1` recompila y ejecuta únicamente los **14 grupos de práctica**. Es normal que el estado inicial obtenga 0 puntos. Cada grupo puede incluir varias entradas. Se muestran casos fallidos y se guardan salidas completas en `resultados/practica/`.

**Solo al terminar el examen**, ejecute:

```powershell
.\evaluar.ps1
```

La evaluación final recompila y ejecuta los grupos visibles y **21 grupos adicionales**, separados en `evaluacion/`. Puede evitar abrir esa carpeta mientras resuelve el examen; al estar en su equipo, no existe ocultación real. Los resultados finales se guardan en `resultados/final/`.

Cada grupo se aprueba solo si cumple sus comprobaciones completas. En práctica, los grupos visibles se reparten por igual los puntos del ejercicio. En evaluación final, el 40 % de cada ejercicio corresponde a los grupos visibles y el 60 % a los adicionales, repartidos por igual dentro de cada nivel. Las restricciones de construcción también forman parte de la evaluación. El puntaje es orientativo: una revisión humana puede detectar incumplimientos que no detecte la automatización.

Un error de compilación del C++ afecta E1 y E5, pero los ejercicios ASM continúan. Un fallo funcional, de ensamblado o un tiempo agotado en un grupo no detiene los demás. Cada ejecución tiene un límite de cinco segundos. Los scripts devuelven código 0 si todo pasa, 1 si hay pruebas fallidas y 2 ante un problema de infraestructura del verificador.

## Reiniciar para una nueva sesión

```powershell
.\reiniciar.ps1 -Confirmar
```

Este comando respalda los seis archivos de estudiante actuales en `respaldos/` y los restaura desde `.inicial/`. No cambia la infraestructura, las pruebas ni el laboratorio original. Los registros de ejecuciones anteriores permanecen hasta que vuelva a ejecutar los verificadores. El comando sin `-Confirmar` solo muestra su uso.

## Alcance

Este simulacro evalúa programación y convenciones de llamada. No incluye un ejercicio de medición de CPI/Amdahl ni repite las implementaciones de Fibonacci y Collatz del laboratorio. Sí exige transferir esas habilidades de recursión y memoización a otros problemas. No pretende predecir las preguntas ni la ponderación exacta del examen del profesor.
