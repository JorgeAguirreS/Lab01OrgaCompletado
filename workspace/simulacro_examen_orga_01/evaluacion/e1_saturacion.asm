; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_0: .word 1, 0, 1, 1, 2
    .word 305419896, 33, 305419896, 0
    .word 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0
    .word 0, 64, 0, 0
n_case_0: .byte "device_split", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $a0, n_case_0
    li $a1, device_split
    li $a2, t_case_0
    li $a3, 3
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
