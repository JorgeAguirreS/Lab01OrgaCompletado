; Parte B.4 (opcional): una iteracion por cada bit encendido.
; Se enlaza en lugar de popcount_sw.asm, nunca junto con otra etiqueta popcount.
.global popcount

popcount:
    move $v0, $zero
    beq $a0, $zero, .pk_out
.pk_loop:
    addiu $t0, $a0, -1   ; resta modulo 2^32, sin excepcion para 0x80000000
    and $a0, $a0, $t0    ; x &= x-1 apaga el bit encendido menos significativo
    addiu $v0, $v0, 1
    bne $a0, $zero, .pk_loop
.pk_out:
    jr $ra
