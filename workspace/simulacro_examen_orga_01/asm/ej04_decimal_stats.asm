; E4 (15 puntos). decimal_stats(n): cantidad de digitos y digito mayor.
; El marco inicial reserva ra, s0 y s1; puede ampliarlo si lo necesita.
.global decimal_stats
.text
decimal_stats:
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s0, $a0
    ; TODO EXAMEN E4: completar el procesamiento y ambos resultados.
    move $v0, $zero
    move $v1, $zero
.e4_out:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra
