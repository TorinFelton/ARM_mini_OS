thing3 DEFW 0
prog3
    ADRL SP, prog3_stack
    ADR R0, thing3

    ; some magic numbers to illustrate register state preservation
    MOV R2, #10
    MOV R3, #14
    MOV R4, #11
    MOV R5, #12

    MOV R8, #4

    prog3_loop
        ADD R1, R1, #1
        STR R1, [R0]
        B prog3_loop

DEFS 256
prog3_stack