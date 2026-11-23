; E7 (25 puntos). ways(n): recorridos con saltos de 1 o 3, con memoizacion.
; Servicios disponibles: memo_get, memo_put. Ver contrato en EXAMEN.md.
.global ways
.text
ways:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s0, $a0
    ; TODO EXAMEN E7: completar casos base, consulta, recursion y almacenamiento.
    move $v0, $zero
.e7_out:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra
