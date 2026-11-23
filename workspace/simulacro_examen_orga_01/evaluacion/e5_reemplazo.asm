; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_3: .word 0, 0, 0, 1, 1
    .word 4, 0, -7, 1
    .word 4, 0, 0, 0
t_case_5: .word 0, 0, 0, 1, 1
    .word 4, 0, 88, 1
t_case_6: .word 0, 0, 0, 0, 1
    .word 0, 0, 0, 0
n_case_3: .byte "device_take", 0
n_case_5: .byte "device_take", 0
n_case_6: .byte "memo_size", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal memo_clear
    li $a0, 4
    li $a1, 9
    jal memo_put
    li $a0, 4
    li $a1, -7
    jal memo_put
    li $a0, n_case_3
    li $a1, device_take
    li $a2, t_case_3
    li $a3, 2
    jal run_table
    li $a0, 4
    li $a1, 88
    jal memo_put
    li $a0, n_case_5
    li $a1, device_take
    li $a2, t_case_5
    li $a3, 1
    jal run_table
    li $a0, n_case_6
    li $a1, memo_size
    li $a2, t_case_6
    li $a3, 1
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
