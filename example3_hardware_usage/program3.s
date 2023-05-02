CSWITCH_DELAY EQU 10

thread1_message DEFB "AFFF/5=\0"
thread2_message DEFB "\nThread2:\0"
ALIGN

expected_div_result DEFW &2333

prog3
    ADRL SP, prog3_stack
    ADR R7, divider_program_result
    ADR R8, thing2
    ADR R5, expected_div_result
    LDR R5, [R5]


    prog3_loop
        MOV R3, #CSWITCH_DELAY ; output every 10 times we are context switched to
        prog3_wait SUBS R3, R3, #1
            SVCNE call_yield ; yield to other threads if we don't want to output yet
            BNE prog3_wait

        ; interrupts disabled, cannot be context-switched here
        SVC call_clear_display

        ADR R0, thread1_message
        SVC call_write_string

        ; dirty binary to ASCII hex code from internet: 
        ; https://stackoverflow.com/questions/53400875/converting-integer-to-hex-string-in-arm-assembly
        LDR R4, [R7]
        LSL R4, R4, #16 ; Shift so correct part is output below
        MOV   r6, #4 ; CHANGED: only outputs 2 bytes of R4 (our div result is 16 bits)
        output_thing1
            MOV   r0, r4, LSR #28

            MOV   r4, r4, LSL #4

            ADD   r0, r0, #48
            CMP   r0, #58              
            ADDHS r0, r0, #7           
            SVC call_write_char
            
            SUBS  r6, r6, #1
            BNZ   output_thing1

            ; output next thread's counter

            ADR R0, thread2_message
            SVC call_write_string

            LDR R4, [R8]
            MOV   r6, #8
        output_thing2
            MOV   r0, r4, LSR #28

            MOV   r4, r4, LSL #4

            ADD   r0, r0, #48
            CMP   r0, #58              
            ADDHS r0, r0, #7           
            SVC call_write_char
            
            SUBS  r6, r6, #1
            BNZ   output_thing2

        
        ; check if we have correct div result
        ; terminates if true
        LDR R4, [R7]
        CMP R4, R5
            SVCEQ call_hang ; stop programs if result achieved.
        
        B prog3_loop

DEFS 128
prog3_stack