; =============================================================================
;  fib_naive.asm - Fibonacci recursivo SIN memoria (ya resuelto; es su modelo).
;  Estudie el marco de pila: $ra, $s0 (n) y $s1 (fib(n-1)) se guardan porque
;  hay una llamada recursiva (jal) entre el momento en que se calculan y se usan.
;     fib(0) = 0, fib(1) = 1, fib(n) = fib(n-1) + fib(n-2)
; =============================================================================
.global fib

fib:                        ; $a0 = n  ->  $v0 = fib(n)
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s0, $a0           ; s0 = n
    slti $t0, $s0, 2
    beq $t0, $zero, .fn_rec
    move $v0, $s0           ; caso base: fib(0) = 0, fib(1) = 1
    j .fn_out
.fn_rec:
    addi $a0, $s0, -1
    jal fib
    move $s1, $v0           ; s1 = fib(n-1)
    addi $a0, $s0, -2
    jal fib
    add $v0, $v0, $s1       ; fib(n-1) + fib(n-2)
.fn_out:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra
