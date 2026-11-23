; =============================================================================
;  a_main.asm - arnes de la Parte A.   NO MODIFICAR.
;  Llama a los procedimientos de parte_a.asm con varios casos de prueba.
;  Cada linea termina en [OK] o en [FALLA: esperado ...].
;  Para ver los datos de un caso, busque la tabla correspondiente mas abajo.
;
;  Uso:  EasyMIPS --run crt.asm testlib.asm parte_a/a_main.asm parte_a/parte_a.asm
;                 --sc-handler plugin/lab01_plugin.so      (o use  ./check.sh a)
; =============================================================================

.global main

.data
; encabezado: fmt_a0, fmt_a1, fmt_res, cmp_v1, nargs  |  fila: arg0, arg1, esperado_v0, esperado_v1
t_popcount: .word 1, 0, 0, 0, 1
            .word 0x00000000, 0, 0, 0
            .word 0x00000001, 0, 1, 0
            .word 0xFFFFFFFF, 0, 32, 0
            .word 0x80000000, 0, 1, 0
            .word 0xF0F0F0F0, 0, 16, 0
            .word 0x12345678, 0, 13, 0

t_rotl:     .word 1, 0, 1, 0, 2
            .word 0x80000001, 1, 0x00000003, 0
            .word 0x12345678, 0, 0x12345678, 0
            .word 0x12345678, 4, 0x23456781, 0
            .word 0x12345678, 32, 0x12345678, 0
            .word 0x12345678, 36, 0x23456781, 0
            .word 0x00000003, -1, 0x80000001, 0
            .word 0xF0000000, 4, 0x0000000F, 0

t_isqrt:    .word 1, 0, 0, 0, 1
            .word 0x00000000, 0, 0, 0
            .word 0x00000001, 0, 1, 0
            .word 0x0000000F, 0, 3, 0
            .word 0x00000010, 0, 4, 0
            .word 0x00000063, 0, 9, 0
            .word 0x00000064, 0, 10, 0
            .word 0xFFFE0001, 0, 65535, 0
            .word 0xFFFE0000, 0, 65534, 0
            .word 0xFFFFFFFF, 0, 65535, 0

t_divmod:   .word 0, 0, 0, 1, 2
            .word 17, 5, 3, 2
            .word -17, 5, -3, -2
            .word 17, -5, -3, 2
            .word -17, -5, 3, -2
            .word 0, 7, 0, 0
            .word -2147483648, 2, -1073741824, 0
            .word 2147483647, 1, 2147483647, 0

t_parity:   .word 1, 0, 0, 0, 1
            .word 0x00000000, 0, 0, 0
            .word 0x00000001, 0, 1, 0
            .word 0x00000003, 0, 0, 0
            .word 0x00000007, 0, 1, 0
            .word 0xFFFFFFFF, 0, 0, 0
            .word 0x80000001, 0, 0, 0
            .word 0x80000000, 0, 1, 0

t_rotr:     .word 1, 0, 1, 0, 2
            .word 0x00000003, 1, 0x80000001, 0
            .word 0x12345678, 0, 0x12345678, 0
            .word 0x12345678, 4, 0x81234567, 0
            .word 0x12345678, 8, 0x78123456, 0
            .word 0x12345678, 32, 0x12345678, 0
            .word 0x80000000, 31, 0x00000001, 0

t_square:   .word 1, 0, 0, 0, 1
            .word 0x00000000, 0, 1, 0
            .word 0x00000001, 0, 1, 0
            .word 0x00000002, 0, 0, 0
            .word 0x00000090, 0, 1, 0
            .word 0x00000091, 0, 0, 0
            .word 0x0000FFFF, 0, 0, 0
            .word 0xFFFE0001, 0, 1, 0
            .word 0xFFFFFFFF, 0, 0, 0

t_digits:   .word 0, 0, 0, 0, 1
            .word 0, 0, 0, 0
            .word 9, 0, 9, 0
            .word 100, 0, 1, 0
            .word 12345, 0, 15, 0
            .word 2147483647, 0, 46, 0

n_popcount: .byte "popcount", 0
n_rotl:     .byte "rotl", 0
n_isqrt:    .byte "isqrt", 0
n_divmod:   .byte "divmod", 0
n_parity:   .byte "parity", 0
n_rotr:     .byte "rotr", 0
n_square:   .byte "is_square", 0
n_digits:   .byte "digit_sum", 0

.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $a0, n_popcount
    li $a1, popcount
    li $a2, t_popcount
    li $a3, 6
    jal run_table

    li $a0, n_rotl
    li $a1, rotl
    li $a2, t_rotl
    li $a3, 7
    jal run_table

    li $a0, n_isqrt
    li $a1, isqrt
    li $a2, t_isqrt
    li $a3, 9
    jal run_table

    li $a0, n_divmod
    li $a1, divmod
    li $a2, t_divmod
    li $a3, 7
    jal run_table

    li $a0, n_parity
    li $a1, parity
    li $a2, t_parity
    li $a3, 7
    jal run_table

    li $a0, n_rotr
    li $a1, rotr
    li $a2, t_rotr
    li $a3, 6
    jal run_table

    li $a0, n_square
    li $a1, is_square
    li $a2, t_square
    li $a3, 8
    jal run_table

    li $a0, n_digits
    li $a1, digit_sum
    li $a2, t_digits
    li $a3, 5
    jal run_table

    jal conv_report

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
