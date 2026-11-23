; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_0: .word 0, 0, 0, 1, 1
    .word 987654321, 0, 9, 9
    .word 0, 0, 1, 0
    .word 1, 0, 1, 1
    .word 10, 0, 2, 1
    .word 100000001, 0, 9, 1
    .word 7, 0, 1, 7
n_case_0: .byte "decimal_stats", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $a0, n_case_0
    li $a1, decimal_stats
    li $a2, t_case_0
    li $a3, 6
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
