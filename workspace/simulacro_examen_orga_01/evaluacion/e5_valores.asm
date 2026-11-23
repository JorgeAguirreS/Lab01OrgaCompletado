; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_4: .word 0, 0, 0, 1, 1
    .word -1, 0, 0, 1
    .word -2147483648, 0, -2147483648, 1
    .word 2147483647, 0, -1, 1
    .word -1, 0, 0, 0
t_case_5: .word 0, 0, 0, 0, 1
    .word 0, 0, 0, 0
n_case_4: .byte "device_take", 0
n_case_5: .byte "memo_size", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal memo_clear
    li $a0, -1
    li $a1, 0
    jal memo_put
    li $a0, -2147483648
    li $a1, -2147483648
    jal memo_put
    li $a0, 2147483647
    li $a1, -1
    jal memo_put
    li $a0, n_case_4
    li $a1, device_take
    li $a2, t_case_4
    li $a3, 4
    jal run_table
    li $a0, n_case_5
    li $a1, memo_size
    li $a2, t_case_5
    li $a3, 1
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
