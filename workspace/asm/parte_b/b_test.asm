; =============================================================================
;  b_test.asm - prueba de popcount (software o hardware).   NO MODIFICAR.
;  Uso:  EasyMIPS --run crt.asm testlib.asm parte_b/b_test.asm parte_b/popcount_sw.asm
;                 --sc-handler plugin/lab01_plugin.so
; =============================================================================
.global main

.data
t_pc:   .word 1, 0, 0, 0, 1
        .word 0x00000000, 0, 0, 0
        .word 0x00000001, 0, 1, 0
        .word 0x0000FFFF, 0, 16, 0
        .word 0x80000000, 0, 1, 0
        .word 0xAAAAAAAA, 0, 16, 0
        .word 0xFFFFFFFF, 0, 32, 0
        .word 0x7FFFFFFF, 0, 31, 0
        .word 0x12345678, 0, 13, 0
n_pc:   .byte "popcount", 0

.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $a0, n_pc
    li $a1, popcount
    li $a2, t_pc
    li $a3, 8
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
