; =============================================================================
;  c_fib_main.asm - arnes de fib (naive o memo).   NO MODIFICAR.
;  Uso:  EasyMIPS --run crt.asm testlib.asm parte_c/c_fib_main.asm parte_c/fib_naive.asm
;                 --sc-handler plugin/lab01_plugin.so --inst-count
;  (cambie fib_naive.asm por fib_memo.asm para comparar el numero de instrucciones)
; =============================================================================
.global main

.data
t_fib:  .word 0, 0, 0, 0, 1
        .word 0, 0, 0, 0
        .word 1, 0, 1, 0
        .word 2, 0, 1, 0
        .word 10, 0, 55, 0
        .word 20, 0, 6765, 0
        .word 25, 0, 75025, 0
n_fib:  .byte "fib", 0

.text
main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $v0, 26                  ; memo_clear: empezar con la memoria vacia
    syscall
    li $a0, n_fib
    li $a1, fib
    li $a2, t_fib
    li $a3, 6
    jal run_table
    jal conv_report
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
