; popcount en "HARDWARE": un solo envoltorio de la syscall 20 (ya resuelto).
; Es identico al de la Parte A: la etiqueta popcount es la misma que la de
; popcount_sw.asm, asi que main puede usar cualquiera de los dos sin cambios.
.global popcount

popcount:
    li $v0, 20
    syscall
    jr $ra
