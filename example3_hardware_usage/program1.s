divider_program_result DEFW 0

DEFS 256
divider_program_stack


HD_divider_io_RESET_INSTRUCTION EQU &1
HD_divider_io_STARTDIV_INSTRUCTION EQU &2

HD_divider_io_state_OK EQU &2

; As this is a word in total (input_A + input_B = 32 bits)
; we can just LDR from input_A address to capture both inputs
input_A DEFB &AF, &FF
input_B DEFB &00, &05
; If the above was written as a DEFW it would be more confusing
; as it would be "DEFW &0500FFAF" to input 0xAFFF and 0x0005.

; 0xAFFF divided by 0x0005 is 0x2333.
; We verify this division is successful at the end.
ALIGN


divider_program
    ADRL SP, divider_program_stack

    ; some magic numbers to illustrate register state preservation
    MOV R2, #17
    MOV R3, #3
    ; end of magic numbers

    MOV R4, #0 ; R4 is a counter for how many times we poll the divider before it finishes    
    ADR R5, divider_program_result

    MOV R6, #HD_divider_io_base


    ADR R0, input_A
    LDR R0, [R0] ; first input is 0xAFAF, second is 0x0005
    ; two inputs stored in one 32 bit register: 0xAFAF0005 to divide 0xAFAF by 0x0005

    SVC call_divider_IN_send_data ; load R0 into divider inputs


    MOV R0, #HD_divider_io_RESET_INSTRUCTION
    SVC call_divider_IN_send_inst ; send reset to divider

    MOV R0, #HD_divider_io_STARTDIV_INSTRUCTION
    SVC call_divider_IN_send_inst ; send 'start dividing' to divider
    
    SVC call_yield ; Switch to other threads while we wait for division
    
    poll_HD_divider_io ; loop until we get OK (division is done) signal in divider_io_state byte
        SVC call_divider_OUT_recieve_state
        ANDS R0, R0, #HD_divider_io_state_OK

        BEQ poll_HD_divider_io
    
    SVC call_divider_OUT_recieve_data ; get result of division into R0
    STR R0, [R5]

    SVC call_exit_thread ; division is done.
