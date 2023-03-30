thing2 DEFW 0
prog2
    ADRL SP, prog2_stack
    ADR R0, thing2


    prog2_loop
        ADD R1, R1, #2
        STR R1, [R0]
        B prog2_loop

DEFS 256
prog2_stack