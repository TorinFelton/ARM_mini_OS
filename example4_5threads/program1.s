thing1 DEFW 0

DEFS 256
prog1_stack


prog1
    ADRL SP, prog1_stack
    ADR R0, thing1

    ; some magic numbers to illustrate register state preservation
    MOV R3, #3
    MOV R4, #4
    MOV R5, #5

    MOV R8, #8


    prog1_loop
        ADD R1, R1, #1
        STR R1, [R0]
        B prog1_loop
