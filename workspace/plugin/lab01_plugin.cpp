// =============================================================================
//  Lab 01 — "Eres el hardware"                 CCC403 Organización de Computadoras
//  Plugin de syscalls para EasyMIPS
// =============================================================================
//
//  EasyMIPS atiende por sí mismo las syscalls 1, 4, 5, 8, 10, 11 y 12 (imprimir,
//  leer, salir). Cualquier otro número en $v0 llega a la función handleSyscall()
//  de ESTE archivo, que EasyMIPS carga con la opción  --sc-handler <biblioteca>.
//
//  Convención de este laboratorio (la misma de las syscalls de SPIM/MARS):
//      $v0           número de syscall (entrada) / resultado (salida)
//      $a0, $a1      argumentos
//      $v1           segundo resultado (cuando la syscall devuelve dos valores)
//
//  El arreglo regs[] ES el banco de registros de la máquina virtual: lo que usted
//  escriba en regs[Register::v0] lo verá el programa MIPS en $v0 al volver.
//  La memoria de la máquina virtual NO es accesible desde el plugin (eso queda
//  para el Laboratorio 2): aquí todo viaja en registros.
//
//  Tabla de syscalls de este laboratorio
//  -------------------------------------------------------------------------
//   #   nombre       entrada                 salida            quién la escribe
//  -------------------------------------------------------------------------
//   20  popcount     $a0 = x                 $v0 = bits en 1   ya resuelta
//   21  rotl         $a0 = x, $a1 = n        $v0 = x rotado    USTED (Parte A)
//   22  isqrt        $a0 = x (sin signo)     $v0 = raíz entera USTED (Parte A)
//   23  divmod       $a0 = a, $a1 = b (con   $v0 = a / b       USTED (Parte A)
//                    signo)                  $v1 = a % b
//   24  memo_put     $a0 = clave, $a1 = val  —                 USTED (Parte C)
//   25  memo_get     $a0 = clave             $v0 = valor       USTED (Parte C)
//                                            $v1 = 1 si existe, 0 si no
//   26  memo_clear   —                       —                 ya resuelta
//   27  memo_size    —                       $v0 = # entradas  ya resuelta
//  -------------------------------------------------------------------------
//
//  Compile con:  make plugin   (Linux/macOS)      .\build.ps1   (Windows)
// =============================================================================

#include <cstdint>
#include <climits>
#include <unordered_map>

#include <easm.h>

// En Windows una .dll solo exporta lo que se marca explícitamente.
#if defined(_WIN32)
#define LAB_EXPORT __declspec(dllexport)
#else
#define LAB_EXPORT
#endif

// --- Números de syscall -------------------------------------------------------
constexpr uint32_t SYS_POPCOUNT  = 20;
constexpr uint32_t SYS_ROTL      = 21;
constexpr uint32_t SYS_ISQRT     = 22;
constexpr uint32_t SYS_DIVMOD    = 23;
constexpr uint32_t SYS_MEMO_PUT  = 24;
constexpr uint32_t SYS_MEMO_GET  = 25;
constexpr uint32_t SYS_MEMO_CLEAR = 26;
constexpr uint32_t SYS_MEMO_SIZE = 27;

// --- Estado del "dispositivo" -------------------------------------------------
// Una variable static vive mientras el plugin esté cargado: sobrevive de una
// syscall a la siguiente. Es la "memoria interna" del hardware que usted construye
// (Parte C). Se crea vacía cuando EasyMIPS carga el plugin.
static std::unordered_map<int32_t, int32_t> g_memo;

// =============================================================================
//  20 — popcount: EJEMPLO RESUELTO. Léalo con atención antes de empezar.
// =============================================================================
static ErrorCode sys_popcount(uint32_t* regs)
{
    uint32_t x = regs[Register::a0];     // argumento: el registro $a0
    uint32_t n = 0;
    while (x != 0) {                     // uint32_t: el desplazamiento es lógico
        n += x & 1u;
        x >>= 1;
    }
    regs[Register::v0] = n;              // resultado: el registro $v0
    return ErrorCode::Ok;                // Ok = el programa MIPS continúa
}

// =============================================================================
//  21 — rotl: rotar x a la izquierda n posiciones (los bits que salen por la
//        izquierda reentran por la derecha).   $a0 = x, $a1 = n   ->   $v0
//        Tenga cuidado: ¿qué valores de n son válidos? ¿qué pasa en C++ si se
//        desplaza un uint32_t 32 o más posiciones?
// =============================================================================
static ErrorCode sys_rotl(uint32_t* regs)
{
    const uint32_t x = regs[Register::a0];
    const uint32_t n = regs[Register::a1] & 31u;
    // Evitar x >> 32: ese desplazamiento no esta definido en C++.
    regs[Register::v0] = n == 0 ? x : (x << n) | (x >> (32u - n));
    return ErrorCode::Ok;
}

// =============================================================================
//  22 — isqrt: parte entera de la raíz cuadrada, tratando $a0 como entero SIN
//        signo de 32 bits.   $a0 = x   ->   $v0 = floor(sqrt(x))
//        Ejemplo: isqrt(99) = 9, isqrt(100) = 10, isqrt(0xFFFFFFFF) = 65535.
//        Cuidado con el desbordamiento al elevar al cuadrado.
// =============================================================================
static ErrorCode sys_isqrt(uint32_t* regs)
{
    const uint32_t x = regs[Register::a0];
    uint32_t low = 0;
    uint32_t high = 65536; // Limite exclusivo: high^2 > cualquier uint32_t.
    // Invariante: low^2 <= x < high^2.
    while (low + 1 < high) {
        const uint32_t mid = low + (high - low) / 2;
        const uint64_t square = static_cast<uint64_t>(mid) * mid;
        if (square <= x) {
            low = mid;
        } else {
            high = mid;
        }
    }
    regs[Register::v0] = low;
    return ErrorCode::Ok;
}

// =============================================================================
//  23 — divmod: división entera CON signo.
//        $a0 = a, $a1 = b   ->   $v0 = a / b,  $v1 = a % b
//        - El cociente se trunca hacia cero (igual que la instrucción div de MIPS).
//        - b == 0            -> devuelva ErrorCode::DivisionByZero
//        - INT_MIN / -1      -> devuelva ErrorCode::Overflow (no cabe en 32 bits)
//        Si devuelve un código distinto de Ok, EasyMIPS detiene el programa.
// =============================================================================
static ErrorCode sys_divmod(uint32_t* regs)
{
    const int32_t a = static_cast<int32_t>(regs[Register::a0]);
    const int32_t b = static_cast<int32_t>(regs[Register::a1]);
    // Comprobar ambos errores ANTES de evaluar / o %.
    if (b == 0) {
        return ErrorCode::DivisionByZero;
    }
    if (a == INT32_MIN && b == -1) {
        return ErrorCode::Overflow;
    }
    regs[Register::v0] = static_cast<uint32_t>(a / b);
    regs[Register::v1] = static_cast<uint32_t>(a % b);
    return ErrorCode::Ok;
}

// =============================================================================
//  24 — memo_put: guardar el par (clave -> valor) en g_memo. Si la clave ya
//        existe, se reemplaza su valor.   $a0 = clave, $a1 = valor
//        Claves y valores son enteros CON signo de 32 bits (int32_t).
// =============================================================================
static ErrorCode sys_memo_put(uint32_t* regs)
{
    const int32_t key = static_cast<int32_t>(regs[Register::a0]);
    const int32_t value = static_cast<int32_t>(regs[Register::a1]);
    g_memo[key] = value; // Inserta una clave nueva o reemplaza su valor.
    return ErrorCode::Ok;
}

// =============================================================================
//  25 — memo_get: buscar una clave en g_memo.
//        $a0 = clave   ->   $v0 = valor (0 si no existe),  $v1 = 1 si existe / 0 si no
//        Importante: consultar NO debe cambiar el contenido de g_memo
//        (memo_size debe seguir igual). Piense en la diferencia entre
//        g_memo[k] y g_memo.find(k).
// =============================================================================
static ErrorCode sys_memo_get(uint32_t* regs)
{
    const int32_t key = static_cast<int32_t>(regs[Register::a0]);
    const auto found = g_memo.find(key); // Consultar no inserta entradas.
    if (found == g_memo.end()) {
        regs[Register::v0] = 0;
        regs[Register::v1] = 0;
    } else {
        regs[Register::v0] = static_cast<uint32_t>(found->second);
        regs[Register::v1] = 1;
    }
    return ErrorCode::Ok;
}

// =============================================================================
//  26 y 27 — ya resueltas: vaciar la memoria y consultar cuántas entradas tiene.
// =============================================================================
static ErrorCode sys_memo_clear(uint32_t* regs)
{
    (void)regs;
    g_memo.clear();
    return ErrorCode::Ok;
}

static ErrorCode sys_memo_size(uint32_t* regs)
{
    regs[Register::v0] = static_cast<uint32_t>(g_memo.size());
    return ErrorCode::Ok;
}

// =============================================================================
//  Punto de entrada: EasyMIPS llama a esta función en cada syscall que no conoce.
//  No cambie su firma (está definida en easm.h).
// =============================================================================
extern "C" LAB_EXPORT ErrorCode handleSyscall(uint32_t* regs, void* mem, MemoryMap* mem_map)
{
    (void)mem;        // siempre nullptr en este laboratorio
    (void)mem_map;

    switch (regs[Register::v0]) {
        case SYS_POPCOUNT:   return sys_popcount(regs);
        case SYS_ROTL:       return sys_rotl(regs);
        case SYS_ISQRT:      return sys_isqrt(regs);
        case SYS_DIVMOD:     return sys_divmod(regs);
        case SYS_MEMO_PUT:   return sys_memo_put(regs);
        case SYS_MEMO_GET:   return sys_memo_get(regs);
        case SYS_MEMO_CLEAR: return sys_memo_clear(regs);
        case SYS_MEMO_SIZE:  return sys_memo_size(regs);
        default:             return ErrorCode::SyscallNotImplemented;
    }
}
