; =============================================================================
;  Parte C.2 - Fibonacci con MEMORIA (memoizacion)
;  Parta de fib_naive.asm y use el dispositivo del plugin para no recalcular:
;
;     fib(n):
;        si n < 2: devolver n
;        (valor, existe) = memo_get(n)            ; syscall 25  ->  $v0 / $v1
;        si existe: devolver valor
;        r = fib(n-1) + fib(n-2)
;        memo_put(n, r)                            ; syscall 24  <-  $a0 = n, $a1 = r
;        devolver r
;
;  Atencion: un syscall NO conserva $a0, $a1 ni los $t que usted tenia en uso,
;  y memo_get devuelve DOS valores. Decida que debe vivir en registros $s.
; =============================================================================
.global fib

fib:                        ; $a0 = n  ->  $v0 = fib(n)
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s0, $a0           ; n sobrevive a las syscalls y a la recursion
    slti $t0, $s0, 2
    beq $t0, $zero, .fm_lookup
    move $v0, $s0           ; casos base, sin consultar ni insertar en la tabla
    j .fm_out
.fm_lookup:
    li $v0, 25
    syscall
    bne $v1, $zero, .fm_out ; acierto: el resultado ya esta en v0
    addi $a0, $s0, -1
    jal fib
    move $s1, $v0           ; fib(n-1) debe sobrevivir a fib(n-2)
    addi $a0, $s0, -2
    jal fib
    add $s1, $s1, $v0       ; ahora s1 conserva el resultado durante memo_put
    move $a0, $s0
    move $a1, $s1
    li $v0, 24
    syscall
    move $v0, $s1           ; memo_put no promete devolver el resultado
.fm_out:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra
