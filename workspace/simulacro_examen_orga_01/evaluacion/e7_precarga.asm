; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_4: .word 0, 0, 0, 0, 1
    .word 45, 0, 18059374, 0
    .word 45, 0, 18059374, 0
t_case_5: .word 0, 0, 0, 0, 1
    .word 25, 0, 2, 0
    .word 24, 0, 0, 0
t_case_6: .word 0, 0, 0, 0, 1
    .word 0, 0, 2, 0
t_case_7: .word 0, 0, 0, 1, 1
    .word -7, 0, -9, 1
n_case_4: .byte "ways", 0
n_case_5: .byte "sys_count", 0
n_case_6: .byte "memo_size", 0
n_case_7: .byte "memo_get", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal memo_clear
    li $a0, 45
    li $a1, 18059374
    jal memo_put
    li $a0, -7
    li $a1, -9
    jal memo_put
    jal stats_clear
    li $a0, n_case_4
    li $a1, ways
    li $a2, t_case_4
    li $a3, 2
    jal run_table
    li $a0, n_case_5
    li $a1, sys_count
    li $a2, t_case_5
    li $a3, 2
    jal run_table
    li $a0, n_case_6
    li $a1, memo_size
    li $a2, t_case_6
    li $a3, 1
    jal run_table
    li $a0, n_case_7
    li $a1, memo_get
    li $a2, t_case_7
    li $a3, 1
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
