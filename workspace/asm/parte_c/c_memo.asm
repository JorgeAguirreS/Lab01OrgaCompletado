; =============================================================================
;  c_memo.asm - prueba del plugin: syscalls 24 (memo_put), 25 (memo_get),
;  26 (memo_clear) y 27 (memo_size), llamadas directamente.   NO MODIFICAR.
;  Uso:  EasyMIPS --run crt.asm testlib.asm parte_c/c_memo.asm --sc-handler plugin/lab01_plugin.so
; =============================================================================
.global main

.data
n_v5:     .byte "get(5).valor      ", 0
n_f5:     .byte "get(5).existe     ", 0
n_f9:     .byte "get(9).existe     ", 0
n_sz1:    .byte "size tras get(9)  ", 0
n_v5b:    .byte "get(5) tras put   ", 0
n_sz2:    .byte "size tras reemplazo", 0
n_vneg:   .byte "get(-3).valor     ", 0
n_sz3:    .byte "size con 3 claves ", 0
n_sz4:    .byte "size tras clear   ", 0
n_f5b:    .byte "get(5).existe     ", 0
s_eq:     .byte " = ", 0
s_ok:     .byte " [OK]", 10, 0
s_fail:   .byte " [FALLA: esperado ", 0
s_close:  .byte "]", 10, 0

.text
; chk(a0 = nombre, a1 = obtenido, a2 = esperado): imprime  nombre = obtenido [OK|FALLA]
chk:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s0, $a1
    move $s1, $a2
    jal print_str
    li $a0, s_eq
    jal print_str
    move $a0, $s0
    jal print_int
    bne $s0, $s1, .chk_fail
    li $a0, s_ok
    jal print_str
    j .chk_end
.chk_fail:
    li $a0, s_fail
    jal print_str
    move $a0, $s1
    jal print_int
    li $a0, s_close
    jal print_str
.chk_end:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra

main:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    li $v0, 26                  ; memo_clear
    syscall
    li $a0, 5                   ; memo_put(5, 50)
    li $a1, 50
    li $v0, 24
    syscall
    li $a0, 7                   ; memo_put(7, 70)
    li $a1, 70
    li $v0, 24
    syscall

    li $a0, 5                   ; memo_get(5)
    li $v0, 25
    syscall
    move $s0, $v1
    move $a1, $v0
    li $a0, n_v5
    li $a2, 50
    jal chk
    li $a0, n_f5
    move $a1, $s0
    li $a2, 1
    jal chk

    li $a0, 9                   ; memo_get(9): no existe
    li $v0, 25
    syscall
    li $a0, n_f9
    move $a1, $v1
    li $a2, 0
    jal chk
    li $v0, 27                  ; memo_size: consultar NO debe insertar la clave 9
    syscall
    li $a0, n_sz1
    move $a1, $v0
    li $a2, 2
    jal chk

    li $a0, 5                   ; memo_put(5, 55): reemplaza
    li $a1, 55
    li $v0, 24
    syscall
    li $a0, 5
    li $v0, 25
    syscall
    move $a1, $v0
    li $a0, n_v5b
    li $a2, 55
    jal chk
    li $v0, 27
    syscall
    li $a0, n_sz2
    move $a1, $v0
    li $a2, 2
    jal chk

    li $a0, -3                  ; claves y valores negativos
    li $a1, -30
    li $v0, 24
    syscall
    li $a0, -3
    li $v0, 25
    syscall
    move $a1, $v0
    li $a0, n_vneg
    li $a2, -30
    jal chk
    li $v0, 27
    syscall
    li $a0, n_sz3
    move $a1, $v0
    li $a2, 3
    jal chk

    li $v0, 26                  ; memo_clear
    syscall
    li $v0, 27
    syscall
    li $a0, n_sz4
    move $a1, $v0
    li $a2, 0
    jal chk
    li $a0, 5
    li $v0, 25
    syscall
    li $a0, n_f5b
    move $a1, $v1
    li $a2, 0
    jal chk

    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra
