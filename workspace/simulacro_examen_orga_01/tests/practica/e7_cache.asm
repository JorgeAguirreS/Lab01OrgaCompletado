; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_1: .word 0, 0, 0, 0, 1
    .word 8, 0, 13, 0
    .word 8, 0, 13, 0
t_case_2: .word 0, 0, 0, 1, 1
    .word 8, 0, 13, 1
n_case_1: .byte "ways", 0
n_case_2: .byte "memo_get", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal memo_clear
    li $a0, n_case_1
    li $a1, ways
    li $a2, t_case_1
    li $a3, 2
    jal run_table
    li $a0, n_case_2
    li $a1, memo_get
    li $a2, t_case_2
    li $a3, 1
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
