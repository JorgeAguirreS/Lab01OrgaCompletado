; =============================================================================
;  collatz_naive.asm - longitud de la cadena de Collatz SIN memoria (ya resuelto).
;     Regla:  si n es par, n = n / 2;  si es impar, n = 3n + 1.   Se repite hasta n = 1.
;     collatz_len(n) = cantidad de pasos para llegar a 1.   collatz_len(1) = 0,
;     collatz_len(7) = 16  (7 22 11 34 17 52 26 13 40 20 10 5 16 8 4 2 1).
;  Es un procedimiento hoja (no llama a nadie): no necesita marco de pila.
; =============================================================================
.global collatz_len

collatz_len:                ; $a0 = n >= 1  ->  $v0 = pasos hasta llegar a 1
    move $v0, $zero
.cn_loop:
    li $t0, 1
    beq $a0, $t0, .cn_end
    andi $t1, $a0, 1
    bne $t1, $zero, .cn_odd
    srl $a0, $a0, 1         ; n par: n / 2
    j .cn_next
.cn_odd:
    sll $t1, $a0, 1
    add $a0, $t1, $a0
    addi $a0, $a0, 1        ; n impar: 3n + 1
.cn_next:
    addi $v0, $v0, 1
    j .cn_loop
.cn_end:
    jr $ra
