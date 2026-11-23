; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_1: .word 0, 0, 0, 0, 1
    .word 0, 0, 1, 0
    .word 1, 0, 1, 0
    .word 2, 0, 1, 0
    .word 3, 0, 2, 0
    .word 4, 0, 3, 0
    .word 6, 0, 6, 0
n_case_1: .byte "ways", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal memo_clear
    li $a0, n_case_1
    li $a1, ways
    li $a2, t_case_1
    li $a3, 6
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
