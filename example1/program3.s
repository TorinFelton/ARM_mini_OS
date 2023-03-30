thread1_message DEFB "Thread1:\0"
thread2_message DEFB "\nThread2:\0"
ALIGN

prog3
    ADRL SP, prog3_stack
    MOV R3, #&2000
    ADR R7, thing1
    ADR R8, thing2



    prog3_loop
        SUBS R3, R3, #1
        BNE prog3_loop
        MOV R3, #&2000
            ; interrupts disabled, cannot be context-switched here
            SVC call_clear_display

            ADR R0, thread1_message
            SVC call_write_string

            ; dirty binary to ASCII hex code from internet: 
            ; https://stackoverflow.com/questions/53400875/converting-integer-to-hex-string-in-arm-assembly
            LDR R4, [R7]
            MOV   r6, #8
        loop214
            MOV   r0, r4, LSR #28

            MOV   r4, r4, LSL #4

            ADD   r0, r0, #48
            CMP   r0, #58              
            ADDHS r0, r0, #7           
            SVC call_write_char
            
            SUBS  r6, r6, #1
            BNZ   loop214

            ; output next thread's counter

            ADR R0, thread2_message
            SVC call_write_string

            LDR R4, [R8]
            MOV   r6, #8
        loop215
            MOV   r0, r4, LSR #28

            MOV   r4, r4, LSL #4

            ADD   r0, r0, #48
            CMP   r0, #58              
            ADDHS r0, r0, #7           
            SVC call_write_char
            
            SUBS  r6, r6, #1
            BNZ   loop215

        B prog3_loop

DEFS 256
prog3_stack