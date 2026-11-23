; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_0: .word 1, 0, 0, 1, 1
    .word 0x80000000, 0, 32, 1
    .word 0x80000001, 0, 32, 2
n_case_0: .byte "word_info", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $a0, n_case_0
    li $a1, word_info
    li $a2, t_case_0
    li $a3, 2
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
