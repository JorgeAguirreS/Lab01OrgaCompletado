; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_0: .word 0, 0, 0, 1, 1
    .word 9123, 0, 4, 9
    .word 1293, 0, 4, 9
    .word 1239, 0, 4, 9
    .word 11111, 0, 5, 1
n_case_0: .byte "decimal_stats", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $a0, n_case_0
    li $a1, decimal_stats
    li $a2, t_case_0
    li $a3, 4
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
