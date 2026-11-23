; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_4: .word 0, 0, 0, 1, 1
    .word 2, 0, 23, 1
    .word 99, 0, 0, 0
t_case_5: .word 0, 0, 0, 0, 1
    .word 0, 0, 2, 0
t_case_6: .word 0, 0, 0, 1, 1
    .word 1, 0, 12, 1
    .word 3, 0, 34, 1
    .word 2, 0, 0, 0
n_case_4: .byte "device_take", 0
n_case_5: .byte "memo_size", 0
n_case_6: .byte "memo_get", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal memo_clear
    li $a0, 1
    li $a1, 12
    jal memo_put
    li $a0, 2
    li $a1, 23
    jal memo_put
    li $a0, 3
    li $a1, 34
    jal memo_put
    li $a0, n_case_4
    li $a1, device_take
    li $a2, t_case_4
    li $a3, 2
    jal run_table
    li $a0, n_case_5
    li $a1, memo_size
    li $a2, t_case_5
    li $a3, 1
    jal run_table
    li $a0, n_case_6
    li $a1, memo_get
    li $a2, t_case_6
    li $a3, 3
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
