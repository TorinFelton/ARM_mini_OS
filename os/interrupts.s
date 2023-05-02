; v9.5
; Changelog:
; - Added ISR_context_switch_nosave label (used for exiting a thread)
; - Added context switching using thread's own stack to save its registers



INCLUDE timer_constants.s ; for timer status variables, minute/second times, etc.
INCLUDE ts_circ_buffer_util.s ; Functions & data for the thread stack pointer queue

interrupt_active_port_offset EQU &18
timer_compare_interrupt_active EQU &1
timer_counter_port EQU &10000008

FPGA_PIO_base_address EQU &2000_0000
OFFSET_FPGA_PIO_kb_port_data EQU &2
OFFSET_FPGA_PIO_kb_port_control EQU &3

OFFSET_PIO_kb_port_IO_control EQU 1


interrupt_handler
    ADRL SP, interrupt_stack_top
        ; When a context switch happens, the interrupt SP is changed to the thread's SP
        ; Therefore we need to make sure the SP_irq uses the interrupt stack at first, to avoid
        ; corrupting a thread SP.
        ; It is fine to set this to the static memory location 'interrupt_stack_top' 
        ; as nothing useful should be stored on the interrupt stack after/before an interrupt.

    SUB LR, LR, #4 ; LR points ahead when interrupt happens so we need to correct it
    PUSH {R0-R1, LR}

    
    MOV R0, #base_IO_address ; from OS_header.s, which this must be included into
    ADD R0, R0, #interrupt_active_port_offset
    LDRB R1, [R0]

    ANDS R1, R1, #timer_compare_interrupt_active
        POPNE {R0-R1, LR} ; restore registers to be saved for context switch
        BNE ISR_context_switch ; no link as we want to preserve LR_irq (user prog PC)

    POP {R0-R1, PC}^ ; restore & return


ISR_context_switch
    ; Set up timer for next interrupt and execute context switch

    ; get user SP and push onto interrupt stack
    PUSH {SP}^
    LDR SP, [SP]
        ; Why not POP {SP}? Because this will decrement SP_usr and not SP_irq.
        ; SP_irq is forgotten at this point, because when we interrupt again we will reset SP_irq to
        ; 'interrupt_stack_top', starting at the beginning again.

    PUSH {R0-LR}^ ; store R0-LR_usr onto the user program's stack
    MRS R0, SPSR ; get user's CPSR
    PUSH {R0, LR} ; store CPSR and PC to return to (LR_irq)

    MOV R0, SP
    BL TS_BUFFER_enqueue ; enqueue this thread stack for later

    ISR_context_switch_nosave
        ; Why have this label?
        ; This label enables us to skip the 'state saving' section of the context switch.
        ; It is used when we want to CLOSE a thread (therefore never switch to it again).
        ; Thus we do NOT save the thread's info back, we just switch to another.


    ; -------------- SETUP NEXT CONTEXT SWITCH INTERRUPT -----------

    TIME_PER_THREAD EQU 2;ms

    MOV R1, #timer_compare_port
    LDRB R0, [R1] ; load current time
    ADD R0, R0, #TIME_PER_THREAD ; add ms to wait for
    STRB R0, [R1]


    ; ACKNOWLEDGE THE TIMER INTERRUPT
    MOV R0, #base_IO_address ; from OS_header.s, which this will be included into
    ADD R0, R0, #interrupt_active_port_offset
    LDRB R1, [R0]
    BIC R1, R1, #timer_compare_interrupt_active ; clear timer interrupt bit
    STRB R1, [R0]
    ; STORE ACKNOWLEDGEMENT

    ; -------------- End of Setup -----------

    
    ; -------------- Restore next thread's state ----------------
    BL TS_BUFFER_dequeue ; R0 = new thread stack
    MOV SP, R0

    POP {R0, LR} ; get SPSR, PC to return to
    MSR SPSR_cxsf, R0
    POP {R0-LR}^ ; pop R0-LR_usr 

    MOVS PC, LR ; return PC to new thread and restore its status