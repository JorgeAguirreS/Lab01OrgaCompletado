; Servicios y adaptadores del arnes. NO EDITAR.
.global popcount
popcount:
    li $v0, 20
    syscall
    jr $ra

.global divmod
divmod:
    li $v0, 23
    syscall
    jr $ra

.global memo_put
memo_put:
    li $v0, 24
    syscall
    jr $ra

.global memo_get
memo_get:
    li $v0, 25
    syscall
    jr $ra

.global memo_clear
memo_clear:
    li $v0, 26
    syscall
    jr $ra

.global memo_size
memo_size:
    li $v0, 27
    syscall
    jr $ra

.global sys_count
sys_count:
    li $v0, 28
    syscall
    jr $ra

.global stats_clear
stats_clear:
    li $v0, 29
    syscall
    jr $ra

.global device_split
device_split:
    li $v0, 30
    syscall
    jr $ra

.global device_take
device_take:
    li $v0, 31
    syscall
    jr $ra
