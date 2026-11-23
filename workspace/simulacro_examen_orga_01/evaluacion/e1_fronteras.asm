; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_0: .word 1, 0, 1, 1, 2
    .word 0x80000001, 31, 1, 1
    .word 2147483647, 31, 2147483647, 0
    .word 0xAAAAAAAA, 17, 43690, 21845
    .word 0xFFFFFFFF, 0, 0, 0xFFFFFFFF
n_case_0: .byte "device_split", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $a0, n_case_0
    li $a1, device_split
    li $a2, t_case_0
    li $a3, 4
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
