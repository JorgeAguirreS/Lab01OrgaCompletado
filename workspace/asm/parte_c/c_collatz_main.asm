; =============================================================================
;  c_collatz_main.asm - arnes de collatz_len (naive o memo).   NO MODIFICAR.
;  1) verifica algunos casos conocidos;  2) busca, entre n = 1..999, el numero con
;  la cadena mas larga (si hay empate, el menor).
;  Uso:  EasyMIPS --run crt.asm testlib.asm parte_c/c_collatz_main.asm parte_c/collatz_naive.asm
;                 --sc-handler plugin/lab01_plugin.so --inst-count
; =============================================================================
.global main

.data
t_col:  .word 0, 0, 0, 0, 1
        .word 1, 0, 0, 0
        .word 2, 0, 1, 0
        .word 3, 0, 7, 0
        .word 7, 0, 16, 0
        .word 27, 0, 111, 0
        .word 97, 0, 118, 0
        .word 871, 0, 178, 0
n_col:  .byte "collatz_len", 0
s_best: .byte "Mayor cadena con n < 1000: n = ", 0
s_len:  .byte "  pasos = ", 0

.text
main:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    li $v0, 26                  ; memo_clear
    syscall
    li $a0, n_col
    li $a1, collatz_len
    li $a2, t_col
    li $a3, 7
    jal run_table
    jal conv_report
    ; --- buscar la cadena mas larga entre 1 y 999
    li $s0, 1                   ; n
    move $s1, $zero             ; mejor n
    move $s2, $zero             ; mejor longitud
.cm_loop:
    move $a0, $s0
    jal collatz_len
    slt $t0, $s2, $v0           ; mejor < actual ?
    beq $t0, $zero, .cm_next
    move $s2, $v0
    move $s1, $s0
.cm_next:
    addi $s0, $s0, 1
    slti $t0, $s0, 1000
    bne $t0, $zero, .cm_loop
    li $a0, s_best
    jal print_str
    move $a0, $s1
    jal print_int
    li $a0, s_len
    jal print_str
    move $a0, $s2
    jal print_int
    li $a0, 10
    jal print_char
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra
