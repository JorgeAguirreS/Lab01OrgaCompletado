; =============================================================================
;  testlib.asm - utilidades de prueba del Lab 01.   NO MODIFICAR ESTE ARCHIVO.
;
;  Es el "arnes" que llama a SUS procedimientos y verifica los resultados.
;  Leerlo es opcional, pero es un buen ejemplo de un llamador correcto:
;  guarda y restaura los $s que usa, y llama a otros procedimientos con jal/jalr.
;
;  Procedimientos exportados:
;     print_hex(a0)                 imprime a0 como 0xXXXXXXXX
;     run_table(a0,a1,a2,a3)        ejecuta una tabla de casos de prueba (ver abajo)
;     conv_report()                 informa si alguna funcion violo la convencion
;
;  Una tabla de pruebas son palabras (.word) con este formato:
;     encabezado (5 palabras):  fmt_a0, fmt_a1, fmt_res, cmp_v1, nargs
;         fmt_*  : 0 = decimal con signo, 1 = hexadecimal
;         cmp_v1 : 1 = tambien se compara $v1
;         nargs  : 1 o 2 argumentos (cuantos se imprimen y se pasan)
;     filas de 4 palabras:      arg0, arg1, esperado_v0, esperado_v1
;
;  run_table(nombre, direccion_de_la_funcion, tabla, numero_de_filas)
;
;  Cada caso se ejecuta con run_case, que carga centinelas en $s0-$s7 antes de
;  llamar a su funcion y comprueba despues que siguen intactos (y que $sp es el
;  mismo): asi se detecta una funcion que no respeta la convencion de llamada.
; =============================================================================

.global print_hex
.global run_table
.global conv_report

.data
conv_bad:   .word 0
saved_sp:   .word 0
hexdig:     .byte "0123456789ABCDEF"
s_hex:      .byte "0x", 0
s_lp:       .byte "(", 0
s_rp:       .byte ") = ", 0
s_comma:    .byte ", ", 0
s_v1:       .byte " v1=", 0
s_ok:       .byte " [OK]", 10, 0
s_fail:     .byte " [FALLA: esperado ", 0
s_close:    .byte "]", 10, 0
s_conv_ok:  .byte "Convencion de registros: OK", 10, 0
s_conv_bad: .byte "Convencion de registros: FALLA (una funcion cambio $s0-$s7 o $sp)", 10, 0

.text

; -----------------------------------------------------------------------------
; print_hex(a0): imprime a0 como 0xXXXXXXXX
; -----------------------------------------------------------------------------
print_hex:
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    move $s0, $a0
    li $a0, s_hex
    jal print_str
    li $s1, 28
.ph_loop:
    srlv $t0, $s0, $s1
    andi $t0, $t0, 15
    li $t1, hexdig
    add $t1, $t1, $t0
    lbu $a0, 0($t1)
    jal print_char
    addi $s1, $s1, -4
    bgez $s1, .ph_loop
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra

; -----------------------------------------------------------------------------
; print_val(a0 = valor, a1 = formato): 0 = decimal, 1 = hexadecimal
; -----------------------------------------------------------------------------
print_val:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    beq $a1, $zero, .pv_dec
    jal print_hex
    j .pv_end
.pv_dec:
    jal print_int
.pv_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

; -----------------------------------------------------------------------------
; run_case(a0 = funcion, a1 = arg0, a2 = arg1) -> v0, v1 = resultados de la funcion
; Llama a la funcion con $s0-$s7 = centinelas y verifica la convencion.
; -----------------------------------------------------------------------------
run_case:
    addi $sp, $sp, -48
    sw $ra, 44($sp)
    sw $s0, 40($sp)
    sw $s1, 36($sp)
    sw $s2, 32($sp)
    sw $s3, 28($sp)
    sw $s4, 24($sp)
    sw $s5, 20($sp)
    sw $s6, 16($sp)
    sw $s7, 12($sp)
    li $t0, saved_sp
    sw $sp, 0($t0)
    move $t9, $a0
    move $a0, $a1
    move $a1, $a2
    li $s0, 0x5A5A0001
    li $s1, 0x5A5A0002
    li $s2, 0x5A5A0003
    li $s3, 0x5A5A0004
    li $s4, 0x5A5A0005
    li $s5, 0x5A5A0006
    li $s6, 0x5A5A0007
    li $s7, 0x5A5A0008
    jalr $t9
    ; --- verificar la convencion (usa solo $t0-$t7; $v0 y $v1 se conservan)
    li $t0, saved_sp
    lw $t1, 0($t0)
    xor $t4, $sp, $t1
    move $sp, $t1
    li $t3, 0x5A5A0001
    xor $t5, $s0, $t3
    or $t4, $t4, $t5
    li $t3, 0x5A5A0002
    xor $t5, $s1, $t3
    or $t4, $t4, $t5
    li $t3, 0x5A5A0003
    xor $t5, $s2, $t3
    or $t4, $t4, $t5
    li $t3, 0x5A5A0004
    xor $t5, $s3, $t3
    or $t4, $t4, $t5
    li $t3, 0x5A5A0005
    xor $t5, $s4, $t3
    or $t4, $t4, $t5
    li $t3, 0x5A5A0006
    xor $t5, $s5, $t3
    or $t4, $t4, $t5
    li $t3, 0x5A5A0007
    xor $t5, $s6, $t3
    or $t4, $t4, $t5
    li $t3, 0x5A5A0008
    xor $t5, $s7, $t3
    or $t4, $t4, $t5
    beq $t4, $zero, .rc_conv_ok
    li $t0, conv_bad
    li $t1, 1
    sw $t1, 0($t0)
.rc_conv_ok:
    lw $s0, 40($sp)
    lw $s1, 36($sp)
    lw $s2, 32($sp)
    lw $s3, 28($sp)
    lw $s4, 24($sp)
    lw $s5, 20($sp)
    lw $s6, 16($sp)
    lw $s7, 12($sp)
    lw $ra, 44($sp)
    addi $sp, $sp, 48
    jr $ra

; -----------------------------------------------------------------------------
; run_table(a0 = nombre, a1 = funcion, a2 = tabla, a3 = filas)
; -----------------------------------------------------------------------------
; Registros: s0 nombre, s1 funcion, s2 puntero a la fila, s3 filas restantes,
;            s4 indice, s5 puntero al encabezado.
; Marco: locales en 24($sp) = $v0 obtenido, 28($sp) = $v1 obtenido, 32($sp) = indicador OK
run_table:
    addi $sp, $sp, -72
    sw $ra, 68($sp)
    sw $s0, 64($sp)
    sw $s1, 60($sp)
    sw $s2, 56($sp)
    sw $s3, 52($sp)
    sw $s4, 48($sp)
    sw $s5, 44($sp)
    move $s0, $a0
    move $s1, $a1
    move $s5, $a2
    addi $s2, $a2, 20
    move $s3, $a3
    move $s4, $zero
.rt_loop:
    beq $s3, $zero, .rt_end
    ; --- ejecutar el caso
    move $a0, $s1
    lw $a1, 0($s2)
    lw $a2, 4($s2)
    jal run_case
    sw $v0, 24($sp)
    sw $v1, 28($sp)
    ; --- ok = (v0 == esperado_v0) && (!cmp_v1 || v1 == esperado_v1)
    li $t2, 1
    lw $t0, 8($s2)
    beq $v0, $t0, .rt_v0ok
    li $t2, 0
.rt_v0ok:
    lw $t3, 12($s5)
    beq $t3, $zero, .rt_nov1
    lw $t1, 12($s2)
    beq $v1, $t1, .rt_nov1
    li $t2, 0
.rt_nov1:
    sw $t2, 32($sp)
    ; --- imprimir  nombre(arg0[, arg1]) = v0[ v1=..]
    move $a0, $s0
    jal print_str
    li $a0, s_lp
    jal print_str
    lw $a0, 0($s2)
    lw $a1, 0($s5)
    jal print_val
    lw $t0, 16($s5)
    li $t1, 2
    bne $t0, $t1, .rt_one_arg
    li $a0, s_comma
    jal print_str
    lw $a0, 4($s2)
    lw $a1, 4($s5)
    jal print_val
.rt_one_arg:
    li $a0, s_rp
    jal print_str
    lw $a0, 24($sp)
    lw $a1, 8($s5)
    jal print_val
    lw $t3, 12($s5)
    beq $t3, $zero, .rt_p1
    li $a0, s_v1
    jal print_str
    lw $a0, 28($sp)
    lw $a1, 8($s5)
    jal print_val
.rt_p1:
    lw $t2, 32($sp)
    beq $t2, $zero, .rt_fail
    li $a0, s_ok
    jal print_str
    j .rt_next
.rt_fail:
    li $a0, s_fail
    jal print_str
    lw $a0, 8($s2)
    lw $a1, 8($s5)
    jal print_val
    lw $t3, 12($s5)
    beq $t3, $zero, .rt_f1
    li $a0, s_v1
    jal print_str
    lw $a0, 12($s2)
    lw $a1, 8($s5)
    jal print_val
.rt_f1:
    li $a0, s_close
    jal print_str
.rt_next:
    addi $s2, $s2, 16
    addi $s3, $s3, -1
    addi $s4, $s4, 1
    j .rt_loop
.rt_end:
    lw $s5, 44($sp)
    lw $s4, 48($sp)
    lw $s3, 52($sp)
    lw $s2, 56($sp)
    lw $s1, 60($sp)
    lw $s0, 64($sp)
    lw $ra, 68($sp)
    addi $sp, $sp, 72
    jr $ra

; -----------------------------------------------------------------------------
; conv_report(): imprime si alguna funcion violo la convencion de registros
; -----------------------------------------------------------------------------
conv_report:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $t0, conv_bad
    lw $t1, 0($t0)
    bne $t1, $zero, .cr_bad
    li $a0, s_conv_ok
    jal print_str
    j .cr_end
.cr_bad:
    li $a0, s_conv_bad
    jal print_str
.cr_end:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
