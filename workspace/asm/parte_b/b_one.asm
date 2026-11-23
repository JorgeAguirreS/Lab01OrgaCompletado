; =============================================================================
;  b_one.asm - llama a popcount UNA vez con el valor de "valor".
;  Cambie el valor de la palabra "valor" (linea .word) y vuelva a ejecutar con
;  --inst-count para medir cuantas instrucciones cuesta ese caso. (Parte B.2)
;  Uso:  EasyMIPS --run crt.asm testlib.asm parte_b/b_one.asm parte_b/popcount_sw.asm
;                 --sc-handler plugin/lab01_plugin.so --inst-count
; =============================================================================
.global main

.data
valor:   .word 0x0000FFFF          ; <-- CAMBIE ESTE VALOR
s_res:   .byte "popcount = ", 0

.text
main:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)
    li $t0, valor
    lw $a0, 0($t0)
    jal popcount
    move $s0, $v0
    li $a0, s_res
    jal print_str
    move $a0, $s0
    jal print_int
    li $a0, 10
    jal print_char
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra
