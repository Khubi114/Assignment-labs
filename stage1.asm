; stage1.asm - Matchsticks Game Setup (Stage 1)
; COS10004 Assignment 2
; ARMlite Compatible

.data
prompt_name:       .asciz "Please enter your name:\n"
prompt_match:      .asciz "How many matchsticks (10-100)?\n"
error_range:       .asciz "Invalid number. Enter between 10 and 100.\n"
player_label:      .asciz "Player 1 is "
match_label:       .asciz "Matchsticks: "
newline:           .asciz "\n"

player_name:       .skip 100       ; buffer for name input
input_buffer:      .skip 100       ; buffer for matchstick number input

.text
main:
    ; Prompt for name
    ldr r0, =prompt_name
    bl putstring

    ldr r0, =player_name
    mov r1, #100
    bl getstring

get_matchsticks:
    ; Prompt for number of matchsticks
    ldr r0, =prompt_match
    bl putstring

    ldr r0, =input_buffer
    mov r1, #100
    bl getstring

    ; Convert input string to integer
    ldr r0, =input_buffer
    bl atoi
    mov r4, r0          ; r4 = matchstick count

    ; Check range (10 <= r4 <= 100)
    cmp r4, #10
    blt invalid_input
    cmp r4, #100
    bgt invalid_input

    ; Valid input: proceed
    b show_summary

invalid_input:
    ; Show error and try again
    ldr r0, =error_range
    bl putstring
    b get_matchsticks

show_summary:
    ; Print: Player 1 is <name>
    ldr r0, =player_label
    bl putstring

    ldr r0, =player_name
    bl putstring

    ldr r0, =newline
    bl putstring

    ; Print: Matchsticks: <number>
    ldr r0, =match_label
    bl putstring

    mov r0, r4
    bl putint

    ldr r0, =newline
    bl putstring

exit:
    mov r0, #0
    bx lr

; ===== ARMlite Utility Functions (you may already have these) =====

; putstring - print null-terminated string in r0
putstring:
    push {r1, r2, r3, lr}
loop_ps:
    ldrb r1, [r0], #1
    cmp r1, #0
    beq done_ps
    bl putchar
    b loop_ps
done_ps:
    pop {r1, r2, r3, lr}
    bx lr

; getstring - read up to r1-1 chars into r0, null-terminated
getstring:
    push {r1, r2, r3, lr}
    mov r2, #0
gs_loop:
    cmp r2, r1
    bge gs_done
    bl getchar
    cmp r0, #10
    beq gs_endline
    strb r0, [r0, r2]
    add r2, r2, #1
    b gs_loop
gs_endline:
    mov r3, #0
    strb r3, [r0, r2]
gs_done:
    pop {r1, r2, r3, lr}
    bx lr

; atoi - convert null-terminated string at r0 to int, result in r0
atoi:
    push {r1, r2, r3, lr}
    mov r1, #0          ; result
atoi_loop:
    ldrb r2, [r0], #1
    cmp r2, #0
    beq atoi_done
    cmp r2, #'0'
    blt atoi_done
    cmp r2, #'9'
    bgt atoi_done
    sub r2, r2, #'0'
    mov r3, #10
    mul r1, r1, r3
    add r1, r1, r2
    b atoi_loop
atoi_done:
    mov r0, r1
    pop {r1, r2, r3, lr}
    bx lr

; putint - prints integer in r0
putint:
    push {r1, r2, r3, r4, lr}
    mov r1, r0
    mov r2, #10
    mov r3, #0
    mov r4, sp
    sub sp, sp, #12     ; buffer space
    mov r0, sp

pi_loop:
    mov r0, r1
    bl udivmod
    add r2, r1, #'0'
    strb r2, [sp, r3]
    add r3, r3, #1
    cmp r0, #0
    mov r1, r0
    bne pi_loop

pi_print:
    subs r3, r3, #1
    blt pi_done
    ldrb r0, [sp, r3]
    bl putchar
    b pi_print
pi_done:
    add sp, sp, #12
    pop {r1, r2, r3, r4, lr}
    bx lr

; udivmod - divide r0 by 10, quotient in r0, remainder in r1
udivmod:
    mov r1, #10
    udiv r2, r0, r1
    mul r3, r2, r1
    sub r1, r0, r3
    mov r0, r2
    bx lr