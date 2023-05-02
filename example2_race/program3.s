first_message DEFB "It's a race.\nFirst to 1000000\0"
result_message DEFB "\nis the winner!\0"
thread1_str DEFB "Thread 1\0"
thread2_str DEFB "Thread 2\0"
ALIGN

WINNING_VALUE DEFW 1000000

prog3
    ADR SP, prog3_stack
    ADR R0, first_message
    SVC call_write_string

    ADRL R4, thing1
    ADRL R5, thing2


    ADR R3, WINNING_VALUE
    LDR R3, [R3]

    check_for_winner
        LDR R2, [R4]
        CMP R2, R3
        ADRGE R0, thread1_str
        BGE win

        LDR R2, [R5]
        CMP R2, R3
        ADRGE R0, thread2_str
        BGE win

        SVC call_yield ; yield to other threads if we haven't got a winner
        B check_for_winner

    win
        SVC call_clear_display
        SVC call_write_string ; write name of winning thread
        ADR R0, result_message
        SVC call_write_string ; write result message after
        SVC call_hang

DEFS 256
prog3_stack