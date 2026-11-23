; E6 (15 puntos). power_u32(base, exponente): potencia recursiva modulo 2^32.
.global power_u32
.text
power_u32:
    ; TODO EXAMEN E6A: establecer el marco necesario para la recursion.
    ; TODO EXAMEN E6B: completar caso base y caso recursivo del enunciado.
    move $v0, $zero
.e6_out:
    ; TODO EXAMEN E6C: restaurar el estado del llamador.
    jr $ra
