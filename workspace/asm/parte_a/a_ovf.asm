; a_ovf.asm - arnes: divmod(INT_MIN, -1) debe detener el programa (ErrorCode::Overflow).
; NO MODIFICAR.   Salida esperada: solo la primera linea, y EasyMIPS termina con error.
.global main
.data
s_antes: .byte "antes de dividir", 10, 0
s_desp:  .byte "ESTO NO DEBE IMPRIMIRSE", 10, 0
.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $a0, s_antes
    jal print_str
    li $a0, 0x80000000
    li $a1, -1
    jal divmod
    li $a0, s_desp
    jal print_str
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
