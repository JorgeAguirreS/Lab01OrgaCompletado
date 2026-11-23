; Arnes proporcionado. NO EDITAR.
.global main
.data
t_case_0: .word 1, 0, 1, 0, 2
    .word 2, 31, 0x80000000, 0
    .word 3, 20, 0xCFD41B91, 0
    .word 305419896, 7, 0xD5E00000, 0
n_case_0: .byte "power_u32", 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $a0, n_case_0
    li $a1, power_u32
    li $a2, t_case_0
    li $a3, 3
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
