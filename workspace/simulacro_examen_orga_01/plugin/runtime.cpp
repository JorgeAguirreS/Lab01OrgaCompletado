// Infraestructura proporcionada: ABI, servicios y aislamiento entre ejercicios.
#include "device.h"
#include <array>
#include <climits>

std::unordered_map<int32_t, int32_t> g_memo;
static std::array<uint32_t, 64> counts{};

static ErrorCode dispatch(uint32_t* r)
{
    const uint32_t code = r[Register::v0];
    if (code < counts.size() && code != 28 && code != 29) ++counts[code];
    switch (code) {
    case 20: {
        uint32_t x = r[Register::a0], bits = 0;
        while (x) { bits += x & 1u; x >>= 1; }
        r[Register::v0] = bits;
        r[Register::v1] = 0xBEEF0003u;
        return ErrorCode::Ok;
    }
    case 23: {
        const int32_t a = static_cast<int32_t>(r[Register::a0]);
        const int32_t b = static_cast<int32_t>(r[Register::a1]);
        if (b == 0) return ErrorCode::DivisionByZero;
        if (a == INT32_MIN && b == -1) return ErrorCode::Overflow;
        r[Register::v0] = static_cast<uint32_t>(a / b);
        r[Register::v1] = static_cast<uint32_t>(a % b);
        return ErrorCode::Ok;
    }
    case 24:
        g_memo[static_cast<int32_t>(r[Register::a0])] = static_cast<int32_t>(r[Register::a1]);
        r[Register::v0] = 0xBEEF0002u;
        r[Register::v1] = 0xBEEF0003u;
        return ErrorCode::Ok;
    case 25: {
        const auto it = g_memo.find(static_cast<int32_t>(r[Register::a0]));
        r[Register::v0] = it == g_memo.end() ? 0 : static_cast<uint32_t>(it->second);
        r[Register::v1] = it == g_memo.end() ? 0 : 1;
        return ErrorCode::Ok;
    }
    case 26:
        g_memo.clear();
        r[Register::v0] = 0;
        r[Register::v1] = 0;
        return ErrorCode::Ok;
    case 27:
        r[Register::v0] = static_cast<uint32_t>(g_memo.size());
        r[Register::v1] = 0;
        return ErrorCode::Ok;
    case 28: // Instrumentacion: numero de invocaciones de la syscall indicada.
        r[Register::v0] = r[Register::a0] < counts.size() ? counts[r[Register::a0]] : 0;
        r[Register::v1] = 0;
        return ErrorCode::Ok;
    case 29:
        counts.fill(0);
        r[Register::v0] = 0;
        r[Register::v1] = 0;
        return ErrorCode::Ok;
    case 30:
#if defined(EXAM_ONLY_PROVIDED)
        return ErrorCode::SyscallNotImplemented;
#else
        return exam_split_low(r);
#endif
    case 31:
#if defined(EXAM_ONLY_PROVIDED)
        return ErrorCode::SyscallNotImplemented;
#else
        return exam_memo_take(r);
#endif
    case 32: {
        uint32_t x = r[Register::a0], width = 0, bits = 0;
        while (x) { ++width; bits += x & 1u; x >>= 1; }
        r[Register::v0] = width;
        r[Register::v1] = bits;
        return ErrorCode::Ok;
    }
    default:
        return ErrorCode::SyscallNotImplemented;
    }
}

extern "C" __declspec(dllexport) ErrorCode handleSyscall(uint32_t* regs, void* mem, MemoryMap* map)
{
    (void)mem;
    (void)map;
    // Ninguna excepcion de C++ debe cruzar la interfaz C de EasyMIPS.
    try {
        const ErrorCode status = dispatch(regs);
        if (status == ErrorCode::Ok) {
            // El contrato permite destruir argumentos y temporales. Se hace
            // tambien en practica para detectar dependencias accidentales.
            for (int i = Register::a0; i <= Register::t7; ++i)
                regs[i] = 0xCAFE0000u + static_cast<uint32_t>(i);
            regs[Register::t8] = 0xCAFE0018u;
            regs[Register::t9] = 0xCAFE0019u;
        }
        return status;
    } catch (...) {
        return ErrorCode::Bug;
    }
}
