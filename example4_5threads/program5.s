CSWITCH_DELAY EQU 20

txtspace_msg DEFB " \0"
newline_msg DEFB "\n\0"
ALIGN

prog5
    ADRL SP, prog5_stack
    ADRL R7, thing1
    ADRL R8, thing2
    ADRL R9, thing3
    ADRL R10, thing4


    prog5_loop
        MOV R3, #CSWITCH_DELAY ; output every 10 times we are context switched to
        prog5_wait SUBS R3, R3, #1
            SVCNE call_yield ; yield to other threads if we don't want to output yet
            BNE prog5_wait

        ; interrupts disabled, cannot be context-switched here
        SVC call_clear_display


        ; dirty binary to ASCII hex code from internet: 
        ; https://stackoverflow.com/questions/53400875/converting-integer-to-hex-string-in-arm-assembly
        LDR R4, [R7]
        LSL R4, R4, #4 ; Shift so shorter to display on screen
        MOV   r6, #7
        output_thing1
            MOV   r0, r4, LSR #28

            MOV   r4, r4, LSL #4

            ADD   r0, r0, #48
            CMP   r0, #58              
            ADDHS r0, r0, #7           
            SVC call_write_char
            
            SUBS  r6, r6, #1
            BNZ   output_thing1
        LDR R4, [R8]
        LSL R4, R4, #4 ; Shift so shorter to display on screen
        MOV   r6, #7


        ADR R0, txtspace_msg
        SVC call_write_string

        output_thing2
            MOV   r0, r4, LSR #28

            MOV   r4, r4, LSL #4

            ADD   r0, r0, #48
            CMP   r0, #58              
            ADDHS r0, r0, #7           
            SVC call_write_char
            
            SUBS  r6, r6, #1
            BNZ   output_thing2

        ; output next line's counters

        ADR R0, newline_msg
        SVC call_write_string

        LDR R4, [R9]
        LSL R4, R4, #4 ; Shift so shorter to display on screen
        MOV   r6, #7
        output_thing3
            MOV   r0, r4, LSR #28

            MOV   r4, r4, LSL #4

            ADD   r0, r0, #48
            CMP   r0, #58              
            ADDHS r0, r0, #7           
            SVC call_write_char
            
            SUBS  r6, r6, #1
            BNZ   output_thing3
        LDR R4, [R10]
        LSL R4, R4, #4 ; Shift so shorter to display on screen
        MOV   r6, #7

        ADR R0, txtspace_msg
        SVC call_write_string

        output_thing4
            MOV   r0, r4, LSR #28

            MOV   r4, r4, LSL #4

            ADD   r0, r0, #48
            CMP   r0, #58              
            ADDHS r0, r0, #7           
            SVC call_write_char
            
            SUBS  r6, r6, #1
            BNZ   output_thing4

        B prog5_loop

DEFS 256
prog5_stack