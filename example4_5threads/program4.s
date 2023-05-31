thing4 DEFW 0
prog4
    ADRL SP, prog4_stack
    ADR R0, thing4

    ; some magic numbers to illustrate register state preservation
    MOV R2, #10
    MOV R3, #1
    MOV R4, #2
    MOV R5, #3

    MOV R8, #5 

    prog4_loop
        ADD R1, R1, #1
        STR R1, [R0]
        B prog4_loop

DEFS 256
prog4_stack