; =============================================================================
;  Parte C.3 - Collatz con MEMORIA
;  Muchas cadenas terminan pasando por numeros que ya se calcularon. Escriba
;  collatz_len de forma RECURSIVA y use memo_get / memo_put:
;
;     collatz_len(n):
;        si n == 1: devolver 0
;        (valor, existe) = memo_get(n)
;        si existe: devolver valor
;        siguiente = (n es par) ? n / 2 : 3n + 1
;        r = 1 + collatz_len(siguiente)
;        memo_put(n, r)
;        devolver r
;
;  Mismas advertencias de fib_memo.asm. Compare el numero de instrucciones con el
;  de collatz_naive.asm (c_collatz_main.asm recorre n = 1..999).
; =============================================================================
.global collatz_len

collatz_len:                ; $a0 = n >= 1  ->  $v0 = pasos hasta llegar a 1
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s0, $a0           ; clave original, conservada durante la recursion
    li $t0, 1
    bne $s0, $t0, .cm_lookup
    move $v0, $zero         ; collatz_len(1) = 0
    j .cm_out
.cm_lookup:
    li $v0, 25
    syscall
    bne $v1, $zero, .cm_out
    andi $t0, $s0, 1
    bne $t0, $zero, .cm_odd
    srl $a0, $s0, 1
    j .cm_recurse
.cm_odd:
    sll $t0, $s0, 1
    add $a0, $t0, $s0
    addi $a0, $a0, 1        ; 3n+1, con la misma aritmetica del modelo naive
.cm_recurse:
    jal collatz_len
    addi $s1, $v0, 1        ; conservar el resultado a traves de memo_put
    move $a0, $s0
    move $a1, $s1
    li $v0, 24
    syscall
    move $v0, $s1
.cm_out:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra
