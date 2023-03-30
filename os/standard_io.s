; v7.0
; Changelog:
; - Changed write_char so that the input, R0, holds the ASCII value and not a pointer to an ASCII value
; - Changed write_string to accommodate above change

INCLUDE character_definitions.s 
; includes special characters such as NEWLINE for translation to an LCD newline

INCLUDE bit_mask_definitions.s
; includes bit masks for port A/B configuration

Port_A EQU &10000000
timer_counter_port EQU &10000008

; --------------- FUNCTIONS -----------------
write_string
    ; CHANGED (22nd March, 2023, Exercise 7): Change write_string to use write_char with R0 value (not pointer)
    ; DESCRIPTION: Takes a pointer to a string and outputs it entirely, stopping when a 0 is found. Uses 'write_character'.
    ; INPUT: R0 = Pointer to first char of string.
    ; All registers are restored after usage (including original inputs)
    PUSH {R0, R1, LR}

    MOV R1, R0 ; R1 is now going to be used as a pointer to the char to print
    
    print_loop 
        LDRB R0, [R1], #1    
        CMP R0, #0
        BEQ end_print_loop ; end of string
        BL write_character
        B print_loop
    end_print_loop

    POP  {R0, R1, PC}

write_character
    ; CHANGED (22nd March, 2023, Exercise 7): Change write_char input R0 to hold char value (not pointer)
    ; DESCRIPTION: Takes an ASCII character and outputs to the LCD display.
    ; INPUT: R0 = character value
    ; All registers are restored after usage (including original inputs)
    PUSH {R1-R8, LR}

    MOV R4, #Port_A

    poll_LCD
        LDRB R1, [R4, #4]
        ORR R1, R1, #BM_R_NOTW ;  R/-W = 1
        BIC R1, R1, #BM_RS ; RS=0


        ORR R1, R1, #BM_Enable_Interface  ; E = 1
        STRB R1, [R4, #4]

        LDRB R5, [R4]   ; Load A into R5

        BIC R1, R1, #BM_Enable_Interface  ; E = 0
        STRB R1, [R4, #4]

        AND R3, R5, #BM_Status ; check the status, bit 7

        CMP R3, #0 ; Compare to see if status is clear
        BNE poll_LCD   ; bit 7 of status byte is high

    write
        ORR R1, R1, #BM_RS ; RS=1
        BIC R1, R1, #BM_R_NOTW ; R/-W =bit 0
        STRB R1, [R4, #4]

        ;LDRB R6, [R0] ; Load character from pointer
        ; CHANGED (22nd March, 2023, Exercise 7): Change write_char input R0 to hold char value (not pointer)

        MOV R6, R0 ; copy input character

        CMP R6, #_NEWLINE ; ASCII NEWLINE, needs to replaced with LCD's newline instruction
        BNE skip_newline
            ; We have a new line character
            MOV R6, #NEWLINE_INSTRUCTION
            BIC R1, R1, #BM_RS ; RS = 0, write to control register to set cursor
        skip_newline

        CMP R6, #_CLEAR_DISPLAY ; 0x01
        BNE skip_clear_display
            ; We have a clear display instruction
            BIC R1, R1, #BM_RS ; RS = 0, write to control register to send instruction

        skip_clear_display
        STRB R6, [R4] ; put char from R6 in Port_A

        ORR R1, R1, #BM_Enable_Interface ; E = 1
        BIC R1, R1, #BM_LED_Enable ; LED ENABLE = 0
        STRB R1, [R4, #4] ; Store R1 with E=1

        BIC R1, R1, #BM_Enable_Interface ; E =0
        STRB R1, [R4, #4]

    POP {R1-R8, PC}


wait_ms
    ; DESCRIPTION: Waits a variable amount of ms
    ; INPUT: R0 is the amount of ms to wait
    PUSH {R0-R6, LR}
    MOV R6, #timer_counter_port
    MOV R5, R0 ; R5 <= time to wait in ms

    ; R0 = 'previous time'
    ; R1 = 'currently polled time'
    ; R3 = current diff
    ; R4 = counts total (we stop when >=R5)
    LDRB R0, [R6]
    poll_timer
        LDRB R1, [R6] ; load current time into R1
        
        SUB R3, R1, R0 ; By default, R3 = current_time-prev_time
        CMP R0, R1
        

        ; If R0 > R1, we have wrapped around
        BLE skip_wrap_case            
            ; time diff is 255-prev_time + current_time as it's wrapped around
            MOV R3, #255
            SUB R3, R3, R0 ; R3=255-prev_time
            ADD R3, R3, R1 ; R3 += current_time

        skip_wrap_case
        ADD R4, R4, R3

        MOV R0, R1 ; current time saved to prev_time for next iteration
        CMP R4, R5
        BLT poll_timer
        

    POP {R0-R6, PC}
