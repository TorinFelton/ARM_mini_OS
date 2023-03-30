thing1 DEFW 0

DEFS 256
prog1_stack


prog1
    ADRL SP, prog1_stack
    ADR R0, thing1

    prog1_loop
        ADD R1, R1, #1
        STR R1, [R0]
        B prog1_loop
