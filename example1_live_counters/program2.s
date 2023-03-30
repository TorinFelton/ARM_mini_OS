thing2 DEFW 0
prog2
    ADRL SP, prog2_stack
    ADR R0, thing2

    ; some magic numbers to illustrate register state preservation
    MOV R2, #10
    MOV R3, #11
    MOV R4, #12
    MOV R5, #13

    MOV R8, #15 

    prog2_loop
        ADD R1, R1, #1
        STR R1, [R0]
        B prog2_loop

DEFS 256
prog2_stack