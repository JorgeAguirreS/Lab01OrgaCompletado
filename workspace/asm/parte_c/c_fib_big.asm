; =============================================================================
;  c_fib_big.asm - fib con n grandes: SOLO tiene sentido con fib_memo.asm.
;  (fib_naive.asm necesitaria miles de millones de instrucciones.)   NO MODIFICAR.
;  fib(46) = 1836311903 es el mayor Fibonacci que cabe en un entero de 32 bits con signo.
; =============================================================================
.global main

.data
t_fib:  .word 0, 0, 0, 0, 1
        .word 30, 0, 832040, 0
        .word 40, 0, 102334155, 0
        .word 46, 0, 1836311903, 0
n_fib:  .byte "fib", 0

.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $v0, 26
    syscall
    li $a0, n_fib
    li $a1, fib
    li $a2, t_fib
    li $a3, 3
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
