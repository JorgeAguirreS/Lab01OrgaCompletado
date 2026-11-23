#include "device.h"

// E1 (10 puntos). Contrato completo en EXAMEN.md.
// a0 = palabra, a1 = cantidad SIN signo. Devuelve dos partes en v0/v1.
ErrorCode exam_split_low(uint32_t* regs)
{
    const uint32_t x = regs[Register::a0];
    const uint32_t n = regs[Register::a1];
    // TODO EXAMEN E1: completar el handler de split_low.
    (void)x;
    (void)n;
    return ErrorCode::SyscallNotImplemented;
}

// E5 (15 puntos). La tabla g_memo ya existe y se comparte con el dispositivo.
// a0 = clave CON signo. Devuelve el valor retirado y la bandera de existencia.
ErrorCode exam_memo_take(uint32_t* regs)
{
    const int32_t key = static_cast<int32_t>(regs[Register::a0]);
    // TODO EXAMEN E5: completar la consulta con retiro, segun EXAMEN.md.
    (void)key;
    return ErrorCode::SyscallNotImplemented;
}
