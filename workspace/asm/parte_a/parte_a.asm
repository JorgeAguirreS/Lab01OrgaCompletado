; =============================================================================
;  Parte A - Una instruccion nueva
;  Complete cada procedimiento. Use SOLO instrucciones reales de MIPS32 mas las
;  pseudo-instrucciones li y move (las mismas reglas de la Prueba).
;
;  Convencion de llamada (recuerde):
;     argumentos  $a0-$a3        resultados  $v0, $v1
;     $t0-$t9 los puede cambiar cualquier procedimiento
;     $s0-$s7, $sp y $ra deben quedar como estaban al entrar
;  Un procedimiento que llama a otro con jal DEBE guardar $ra en la pila.
; =============================================================================

.global popcount
.global rotl
.global isqrt
.global divmod
.global parity
.global rotr
.global is_square
.global digit_sum

; ---- A.1  Envoltorios de las syscalls --------------------------------------
; Cada uno traduce una llamada de procedimiento en una syscall:
; los argumentos ya vienen en $a0/$a1, solo falta indicar el numero en $v0.

popcount:               ; $a0 = x  ->  $v0 = cantidad de bits en 1     (syscall 20)
    li $v0, 20
    syscall
    jr $ra

rotl:                   ; $a0 = x, $a1 = n  ->  $v0 = x rotado n bits  (syscall 21)
    li $v0, 21
    syscall
    jr $ra

isqrt:                  ; $a0 = x (sin signo)  ->  $v0 = floor(sqrt(x)) (syscall 22)
    li $v0, 22
    syscall
    jr $ra

divmod:                 ; $a0 = a, $a1 = b  ->  $v0 = a / b, $v1 = a % b (syscall 23)
    li $v0, 23
    syscall
    jr $ra

; ---- A.2  Procedimientos que USAN los envoltorios ---------------------------

parity:                 ; $a0 = x  ->  $v0 = 1 si x tiene una cantidad IMPAR de bits en 1
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    jal popcount
    andi $v0, $v0, 1
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

rotr:                   ; $a0 = x, $a1 = n  ->  $v0 = x rotado n bits a la DERECHA
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    andi $a1, $a1, 31
    subu $a1, $zero, $a1 ; rotar a la derecha n = rotar a la izquierda -n mod 32
    jal rotl             ; el plugin reduce modulo 32; n = 0 sigue siendo cero
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

is_square:              ; $a0 = n (sin signo)  ->  $v0 = 1 si n es un cuadrado perfecto, 0 si no
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)
    move $s0, $a0        ; n debe sobrevivir a jal isqrt
    jal isqrt
    multu $v0, $v0       ; la raiz es <= 65535: su cuadrado cabe sin signo
    mflo $t0
    xor $t0, $t0, $s0
    sltiu $v0, $t0, 1    ; 1 exactamente cuando el XOR es cero
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

digit_sum:              ; $a0 = n >= 0  ->  $v0 = suma de los digitos decimales de n
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    move $s0, $a0        ; numero que falta dividir
    move $s1, $zero      ; suma acumulada, conservada durante jal divmod
.dig_loop:
    beq $s0, $zero, .dig_out
    move $a0, $s0
    li $a1, 10
    jal divmod
    move $s0, $v0        ; cociente para la siguiente iteracion
    addu $s1, $s1, $v1   ; residuo = ultimo digito
    j .dig_loop
.dig_out:
    move $v0, $s1
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    jr $ra
