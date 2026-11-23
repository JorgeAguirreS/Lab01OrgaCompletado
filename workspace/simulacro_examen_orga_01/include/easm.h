// EasyMIPS Plugin Development Kit — the syscall plugin ABI.
//
// This header is the **single source of truth** for everything that crosses the
// boundary between the emulator (EasyMIPS) and a `--sc-handler` plugin (.so / .dll /
// .dylib). The emulator includes it as well (through include/EasyMIPS/easm_abi.h), so
// the two sides cannot drift apart: one definition of ErrorCode, of the register
// numbering, of MemoryMap and of the entry point.
//
// It is valid C **and** C++:
//   * C++ gets an `enum class`, a `Register` class and `MemoryMap` member functions:
//     `ErrorCode::Stop`, `Register::v0`, `mm->getOffset(addr)`.
//   * C gets typedefs and `static inline` helpers, with every enumerator prefixed so
//     that including this header does not add names like `Ok` or `v0` to the global
//     namespace: `EASM_STOP`, `EASM_REG_V0`, `MemoryMap_getOffset(mm, addr)`.
//   * Zig reaches the same declarations through build-time translate-c
//     (plugin-sample-zig/main.zig); Zig 0.17 has no @cImport. That is why the header
//     must stay free of C++-only syntax outside the `#ifdef __cplusplus` blocks.
// The value lists are written once, as macros, and mapped to each language's syntax
// below — so the numbers and the layout cannot diverge.
//
// ABI rules: enumerators and struct fields may only be *appended*; never reorder,
// retype or remove anything that is already here.

#ifndef __EASM_H__
#define __EASM_H__

#include <stdint.h>
#include <stddef.h>

typedef uint32_t VirtualAddr;

// ---------------------------------------------------------------------------
// ErrorCode: return value of handleSyscall(). The numeric values are the ABI.
//   C++: ErrorCode::Stop    C: EASM_STOP    Zig: c.EASM_STOP
// ---------------------------------------------------------------------------
#define EASM_ERROR_CODE_LIST(X)                             \
    X(Ok, OK)                                               \
    X(Overflow, OVERFLOW)                                   \
    X(DivisionByZero, DIVISION_BY_ZERO)                     \
    X(VirtualAddrOutOfRange, VIRTUAL_ADDR_OUT_OF_RANGE)     \
    X(VirtualAddrNotAligned, VIRTUAL_ADDR_NOT_ALIGNED)      \
    X(InstAddrOutOfRange, INST_ADDR_OUT_OF_RANGE)           \
    X(SyscallNotImplemented, SYSCALL_NOT_IMPLEMENTED)       \
    X(UnsupportedInst, UNSUPPORTED_INST)                    \
    X(Break, BREAK)                                         \
    X(Stop, STOP)                                           \
    X(Bug, BUG)                                             \
    X(SyscallsNotSupported, SYSCALLS_NOT_SUPPORTED)

#ifdef __cplusplus
enum class ErrorCode
{
#define EASM_ENUM_ENTRY(name, c_name) name,
    EASM_ERROR_CODE_LIST(EASM_ENUM_ENTRY)
#undef EASM_ENUM_ENTRY
};
#else
typedef enum ErrorCode
{
#define EASM_ENUM_ENTRY(name, c_name) EASM_##c_name,
    EASM_ERROR_CODE_LIST(EASM_ENUM_ENTRY)
#undef EASM_ENUM_ENTRY
} ErrorCode;
#endif

// ---------------------------------------------------------------------------
// Register: index into the `regs[]` array that handleSyscall() receives.
//   C++: Register::v0    C: EASM_REG_V0    Zig: c.EASM_REG_V0
// ---------------------------------------------------------------------------
#define EASM_REGISTER_LIST(X)                   \
    X(Zero, ZERO) X(At, AT) X(v0, V0) X(v1, V1) \
    X(a0, A0) X(a1, A1) X(a2, A2) X(a3, A3)     \
    X(t0, T0) X(t1, T1) X(t2, T2) X(t3, T3)     \
    X(t4, T4) X(t5, T5) X(t6, T6) X(t7, T7)     \
    X(s0, S0) X(s1, S1) X(s2, S2) X(s3, S3)     \
    X(s4, S4) X(s5, S5) X(s6, S6) X(s7, S7)     \
    X(t8, T8) X(t9, T9) X(k0, K0) X(k1, K1)     \
    X(Gp, GP) X(Sp, SP) X(Fp, FP) X(Ra, RA)     \
    X(Lo, LO) X(Hi, HI) X(Pc, PC)

#ifdef __cplusplus
class Register
{
public:
    Register() = delete;

    enum
    {
#define EASM_ENUM_ENTRY(name, c_name) name,
        EASM_REGISTER_LIST(EASM_ENUM_ENTRY)
#undef EASM_ENUM_ENTRY
    };
};
#else
typedef enum Register
{
#define EASM_ENUM_ENTRY(name, c_name) EASM_REG_##c_name,
    EASM_REGISTER_LIST(EASM_ENUM_ENTRY)
#undef EASM_ENUM_ENTRY
} Register;
#endif

// ---------------------------------------------------------------------------
// MemoryMap: the virtual machine's memory ranges, published on every syscall.
// The emulator fills this in (it keeps sizes internally and converts them).
// The four fields are the ABI; the list below is the single definition of them.
// Field names are the same in C and C++ (struct members are not global names).
// ---------------------------------------------------------------------------
#define EASM_MEMORY_MAP_FIELDS \
    VirtualAddr gbl_start;     \
    VirtualAddr gbl_end;       \
    VirtualAddr stk_start;     \
    VirtualAddr stk_end

#ifdef __cplusplus
struct MemoryMap
{
    long getOffset(VirtualAddr vaddr) const
    {
        if (vaddr >= gbl_start && vaddr < gbl_end) {
            return (vaddr - gbl_start);
        } else if (vaddr >= stk_start && vaddr < stk_end) {
            return (long)((vaddr - stk_start) + gblWordSize() * 4);
        } else {
            return -1;
        }
    }

    size_t gblWordSize() const { return (gbl_end - gbl_start)/4; }
    size_t stkWordSize() const { return (stk_end - stk_start)/4; }
    size_t wordSize() const { return gblWordSize() + stkWordSize(); }

    EASM_MEMORY_MAP_FIELDS;
};
#else
typedef struct MemoryMap
{
    EASM_MEMORY_MAP_FIELDS;
} MemoryMap;

static inline size_t MemoryMap_gblWordSize(const MemoryMap* mm)
{
    return (size_t)((mm->gbl_end - mm->gbl_start) / 4);
}

static inline size_t MemoryMap_stkWordSize(const MemoryMap* mm)
{
    return (size_t)((mm->stk_end - mm->stk_start) / 4);
}

static inline long MemoryMap_getOffset(const MemoryMap* mm, VirtualAddr vaddr)
{
    if (vaddr >= mm->gbl_start && vaddr < mm->gbl_end) {
        return (long)(vaddr - mm->gbl_start);
    } else if (vaddr >= mm->stk_start && vaddr < mm->stk_end) {
        return (long)((vaddr - mm->stk_start) + MemoryMap_gblWordSize(mm) * 4);
    } else {
        return -1;
    }
}

static inline size_t MemoryMap_wordSize(const MemoryMap* mm)
{
    return MemoryMap_gblWordSize(mm) + MemoryMap_stkWordSize(mm);
}
#endif

// ---------------------------------------------------------------------------
// The one exported symbol of a plugin: EasyMIPS opens the library and looks up this
// name (`--sc-handler <lib>`). Declared here — not only in each plugin — so that the
// plugin and the emulator use exactly the same function type (that is also what the
// compiler's -fsanitize=function check verifies at the call site).
// ---------------------------------------------------------------------------
#ifdef __cplusplus
extern "C"
#endif
ErrorCode handleSyscall(uint32_t* regs, void* mem, MemoryMap* mem_map);

#ifdef __cplusplus
// What EasyMIPS stores in place of the `void*` returned by dlsym()/GetProcAddress().
typedef decltype(&handleSyscall) SyscallHandler;

// Compile-time guard for the numbers above: they are the wire format between the
// emulator and a plugin, so reordering or inserting anything is a breaking change.
static_assert(static_cast<int>(ErrorCode::Ok) == 0, "ErrorCode::Ok must stay 0 (ABI)");
static_assert(static_cast<int>(ErrorCode::Bug) == 10, "ErrorCode values are ABI");
static_assert(static_cast<int>(ErrorCode::SyscallsNotSupported) == 11,
              "append new ErrorCode values, never insert (ABI)");
static_assert(static_cast<int>(Register::Pc) == 34, "Register numbering is ABI");
static_assert(sizeof(MemoryMap) == 16, "MemoryMap is four uint32 fields (ABI)");
#else
typedef ErrorCode (*SyscallHandler)(uint32_t* regs, void* mem, MemoryMap* mem_map);
#endif

#endif
