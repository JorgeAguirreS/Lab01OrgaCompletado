; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_2: .word 0, 0, 0, 1, 1
    .word 7, 0, 42, 1
t_case_3: .word 0, 0, 0, 1, 1
    .word 7, 0, 0, 0
t_case_4: .word 0, 0, 0, 0, 1
    .word 0, 0, 0, 0
n_case_2: .byte "device_take", 0
n_case_3: .byte "memo_get", 0
n_case_4: .byte "memo_size", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal memo_clear
    li $a0, 7
    li $a1, 42
    jal memo_put
    li $a0, n_case_2
    li $a1, device_take
    li $a2, t_case_2
    li $a3, 1
    jal run_table
    li $a0, n_case_3
    li $a1, memo_get
    li $a2, t_case_3
    li $a3, 1
    jal run_table
    li $a0, n_case_4
    li $a1, memo_size
    li $a2, t_case_4
    li $a3, 1
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
