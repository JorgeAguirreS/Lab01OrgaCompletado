#pragma once
#include <cstdint>
#include <unordered_map>
#include <easm.h>

// Infraestructura proporcionada. No editar.
extern std::unordered_map<int32_t, int32_t> g_memo;
ErrorCode exam_split_low(uint32_t* regs);
ErrorCode exam_memo_take(uint32_t* regs);
