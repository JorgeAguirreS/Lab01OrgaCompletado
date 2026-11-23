; =============================================================================
;  Parte B - popcount en SOFTWARE
;  Implemente popcount SIN usar la syscall 20: solo instrucciones MIPS32
;  (mas li y move).   $a0 = x   ->   $v0 = cantidad de bits en 1 de x
;  Idea: examine un bit a la vez con andi y srl, y repita hasta terminar.
; =============================================================================
.global popcount

popcount:
    move $v0, $zero
    beq $a0, $zero, .ps_out
.ps_loop:
    andi $t0, $a0, 1
    addu $v0, $v0, $t0
    srl $a0, $a0, 1      ; desplazamiento logico: tambien termina si el bit 31 es 1
    bne $a0, $zero, .ps_loop
.ps_out:
    jr $ra
