; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_0: .word 1, 0, 1, 0, 2
    .word 0xFFFFFFFF, 2, 1, 0
    .word 0xFFFFFFFF, 3, 0xFFFFFFFF, 0
    .word 65536, 2, 0, 0
    .word 0x80000000, 1, 0x80000000, 0
n_case_0: .byte "power_u32", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $a0, n_case_0
    li $a1, power_u32
    li $a2, t_case_0
    li $a3, 4
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
