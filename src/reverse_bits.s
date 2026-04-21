    .data
input_addr:      .word  0x80
output_addr:     .word  0x84

    .text
    .org     0x88
_start:
    ; stack initialization
    lui      sp, %hi(0x1000)
    addi     sp, sp, %lo(0x1000)

    ; input number
    lui      t0, %hi(input_addr)
    addi     t0, t0, %lo(input_addr)
    lw       t0, 0(t0)
    lw       a1, 0(t0)

    ; procedure call
    mv       a0, zero
    addi     a2, zero, 32
    jal      ra, reverse_bits

    ; output result
    lui      t1, %hi(output_addr)
    addi     t1, t1, %lo(output_addr)
    lw       t1, 0(t1)
    sw       a0, 0(t1)

    halt

    ; reverse_bits(n: a1, bits_left: a2) -> reversed_bits: a0
reverse_bits:
    ; store ra and variables in stack
    addi     sp, sp, -12
    sw       ra, 8(sp)                       ; return address
    sw       s2, 4(sp)                       ; least significant bit (lsb)
    sw       s3, 0(sp)                       ; bits_left - 1

    andi     s2, a1, 1                       ; s2 = n & 1
    addi     s3, a2, -1                      ; s3 = bits_left - 1

    srli     a1, a1, 1                       ; a1 = n >> 1
    mv       a2, s3                          ; a2 = bits_left - 1

    ; exit recursion if no bits left
    beqz     a2, reverse_bits_end

    ; reverse_bits(n >> 1, bits_left - 1)
    jal      ra, reverse_bits                

reverse_bits_end:
    ; combine results
    sll      s2, s2, s3                      ; lsb << (bits_left - 1)
    or       a0, a0, s2                      ; reverse_bits(n >> 1, bits_left - 1) | (lsb << (bits_left - 1))

    ; restore values
    lw       ra, 8(sp)
    lw       s2, 4(sp)
    lw       s3, 0(sp)
    addi     sp, sp, 12

    jr       ra
