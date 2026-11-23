; E3 (12 puntos). hamming(x, y): distancia entre palabras de 32 bits.
; El procedimiento popcount viene proporcionado en infra/servicios.asm.
.global hamming
.text
hamming:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    ; TODO EXAMEN E3: completar el cuerpo usando jal popcount.
    move $v0, $zero
.e3_out:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
