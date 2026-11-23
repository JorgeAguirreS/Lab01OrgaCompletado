; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_1: .word 1, 1, 0, 0, 2
    .word 7, 7, 0, 0
    .word 0, 0, 0, 0
    .word 305419896, 305419897, 1, 0
n_case_1: .byte "hamming", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal stats_clear
    li $a0, n_case_1
    li $a1, hamming
    li $a2, t_case_1
    li $a3, 3
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
