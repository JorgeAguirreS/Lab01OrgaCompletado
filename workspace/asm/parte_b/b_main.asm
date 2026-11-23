; =============================================================================
;  b_main.asm - el programa que va a medir en la Parte B.   NO MODIFICAR.
;
;  Genera 64 palabras pseudoaleatorias con un generador congruencial lineal
;      x = x * 1103515245 + 12345      (modulo 2^32, semilla 12345)
;  y para cada una calcula su popcount. Al final imprime el total de bits en 1
;  y el XOR de todas las palabras (sirve para comprobar que el resto del
;  programa no cambio).
;
;  main llama a "popcount" sin saber si es la version software o hardware.
;  Uso:  EasyMIPS --run crt.asm testlib.asm parte_b/b_main.asm parte_b/popcount_sw.asm
;                 --sc-handler plugin/lab01_plugin.so --inst-count
; =============================================================================
.global main

.data
s_words: .byte "Palabras procesadas: 64", 10, 0
s_bits:  .byte "Bits en 1 (total): ", 0
s_xor:   .byte "XOR de las palabras: ", 0

.text
main:
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)
    li $s0, 64              ; palabras restantes
    li $s1, 12345           ; x (semilla)
    move $s2, $zero         ; total de bits en 1
    move $s3, $zero         ; XOR acumulado
    li $s4, 1103515245      ; multiplicador del generador
.mb_loop:
    multu $s1, $s4
    mflo $s1
    addiu $s1, $s1, 12345   ; x = x * 1103515245 + 12345
    xor $s3, $s3, $s1
    move $a0, $s1
    jal popcount
    add $s2, $s2, $v0
    addi $s0, $s0, -1
    bne $s0, $zero, .mb_loop
    li $a0, s_words
    jal print_str
    li $a0, s_bits
    jal print_str
    move $a0, $s2
    jal print_int
    li $a0, 10
    jal print_char
    li $a0, s_xor
    jal print_str
    move $a0, $s3
    jal print_hex
    li $a0, 10
    jal print_char
    lw $s4, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    jr $ra
