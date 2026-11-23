; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_0: .word 1, 0, 0, 1, 1
    .word 1, 0, 1, 1
    .word 0xFFFFFFFF, 0, 32, 32
    .word 0, 0, 0, 0
    .word 65536, 0, 17, 1
    .word 305419896, 0, 29, 13
    .word 1, 0, 1, 1
n_case_0: .byte "word_info", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $a0, n_case_0
    li $a1, word_info
    li $a2, t_case_0
    li $a3, 6
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
