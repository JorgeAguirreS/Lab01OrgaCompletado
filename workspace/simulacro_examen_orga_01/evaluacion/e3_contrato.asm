; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_1: .word 1, 1, 0, 0, 2
    .word 0xFFFFFFFF, 1, 31, 0
    .word 16, 2, 2, 0
    .word 1, 1, 0, 0
    .word 0, 1, 1, 0
t_case_2: .word 0, 0, 0, 0, 1
    .word 20, 0, 4, 0
n_case_1: .byte "hamming", 0
n_case_2: .byte "sys_count", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal stats_clear
    li $a0, n_case_1
    li $a1, hamming
    li $a2, t_case_1
    li $a3, 4
    jal run_table
    li $a0, n_case_2
    li $a1, sys_count
    li $a2, t_case_2
    li $a3, 1
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
