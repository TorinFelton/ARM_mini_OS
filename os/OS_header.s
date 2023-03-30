; v9.5
; Changelog:
; - Changed init -> SVC_init
;   - 'init' will now be a USER label, denoting the beginning of the program
;   - The user should add the threads (in an atomic block) in the init routine
;   - They should then exit the init thread.
; - Added SVCs for creating atomic block (disables interrupts)
; - Added SVC for exiting thread
; - Added SVC for creating new thread

Max_SVC EQU 11
call_write_string EQU 0
call_write_char EQU 1
call_clear_display EQU 2
call_hang EQU 3
call_wait_ms EQU 4
call_load_port_B EQU 5
call_BEGIN_ATOMIC_BLOCK EQU 6
call_END_ATOMIC_BLOCK EQU 7
call_add_thread_to_pool EQU 8
call_exit_thread EQU 9
call_yield EQU 10

INTERRUPT_enable_timer_compare EQU 1

disable_interrupts EQU &80

base_IO_address EQU &10000000
OFFSET_enable_interrupts_port EQU &1C 

port_B_address EQU &10000004
timer_compare_port EQU &1000000C



B SVC_init
B undefined_instruction
B SVC_handler
NOP
NOP
NOP
B interrupt_handler

SVC_init
    ADRL SP, supervisor_stack_top ; set supervisor sp (R13) to top of stack allocation
    
    BL TS_BUFFER_setup ; set up thread stack buffer pointers to enable enqueue, dequeue

    ; switch to interrupt mode first to set up stack etc.
    MOV R14, #BM_interrupt_mode
    MSR CPSR, R14 ; switch to interrupt mode

    ADRL SP, interrupt_stack_top ; set up interrupt mode stack


    MOV R0, #INTERRUPT_enable_timer_compare
    MOV R1, #base_IO_address
    ADD R1, R1, #OFFSET_enable_interrupts_port
    STR R0, [R1] ; enable timer compare interrupt


    MOV R0, #0
    MOV R1, #0 ; reset registers to 0 for convention

    MOV R14, #BM_user_mode ; set up user mode
    BIC R14, R14, #disable_interrupts  ; Clear the disable interrupts bit, thus ENABLING them.
    
    MSR SPSR, R14 ; switch to user mode
    ADRL R14, init ; set up entry point of user program
    MOVS PC, R14 ; return to user code


undefined_instruction
    B .

SVC_handler
    PUSH {LR}
    LDR R14, [LR, #-4]
    BIC R14, R14, #&FF000000

    CMP R14, #Max_SVC
    
table_calc    ADDLT R14, PC, R14, LSL #2
    LDRLT PC, [R14, #(SVC_jump_table - (table_calc + 8))]
    B undefined_instruction
SVC_jump_table DEFW SVC_0 ; print string
               DEFW SVC_1 ; print char
               DEFW SVC_2 ; clear display
               DEFW SVC_3 ; hang prog
               DEFW SVC_4 ; wait variable amount of ms
               DEFW SVC_5 ; load Port B into R0.
               DEFW SVC_6 ; disable interrupts
               DEFW SVC_7 ; enable interrupts
               DEFW SVC_8 ; add thread to pool
               DEFW SVC_9 ; exit current thread and switch to next
               DEFW SVC_10 ; yield to cpu
SVC_0
    ; print string
    BL write_string
    B SVC_exit

SVC_1
    ; print char
    BL write_character
    B SVC_exit

SVC_2
    PUSH {R0}
    MOV R0, #&01
    BL write_character
    POP {R0}
    B SVC_exit

SVC_3
    ; hang program forever
    B .

SVC_4
    ; wait variable amount of ms (R0 is input)
    BL wait_ms
    B SVC_exit

SVC_5
    ; load Port B into R0
    PUSH {R1}
    MOV R1, #port_B_address
    LDRB R0, [R1]
    POP {R1}
    B SVC_exit

SVC_6
    ; Disable interrupts in user mode
    PUSH {R0}

    MRS R0, SPSR
    ORR R0, R0, #disable_interrupts ; enable the 'disable interrupts' bit
    MSR SPSR, R0

    POP {R0}
    B SVC_exit ; will save the SPSR back to the CPSR allowing above^

SVC_7
    ; Enable interrupts in user mode
    PUSH {R0}

    MRS R0, SPSR
    BIC R0, R0, #disable_interrupts ; disable the 'disable interrupts' bit
    MSR SPSR, R0

    POP {R0}
    B SVC_exit ; will save the SPSR back to the CPSR allowing above^

SVC_8
    ; FUNCTION: Add program onto the context switch pool
    ; INPUT: R0 = pointer to beginning of program, R1 = pointer to program's stack
    ; OUTPUT: None
    ; DESCRIPTION: Takes program information as input and sets up information to include program
    ; in context switching.
    ; This is REQUIRED to allow the program to be included in the time slicing.
    
    PUSH {R0, R2-R5}

    MOV R5, SP

    ; Create a fresh user mode CPSR and store for now
    MOV R2, #BM_user_mode
    BIC R2, R2, #disable_interrupts ; enable interrupts so the user program can be context switched

    ; -------------- SETUP thread stack for program --------------
    MOV SP, R1 ; SP = program's stack that was input

    MOV R3, #0
    MOV R4, #15
    ; Push blank (0) data for R0-R14 incl.
    setup_TS_keep_pushing_blank
        PUSH {R3}
        SUBS R4, R4, #1
        BNE setup_TS_keep_pushing_blank


    PUSH {R0} ; push pointer to beginning of program as the PC value
    PUSH {R2} ; push CPSR

    MOV R0, SP ; Input of R0 is OVERWRITTEN (restored by the stack pop though)
    BL TS_BUFFER_enqueue ; enqueue updated SP of prog2
    ; --------------- END SETUP  ----------------

    MOV SP, R5 ; restore back to svc stack

    POP {R0, R2-R5}
    B SVC_exit

SVC_9
    POP {LR} ; LR is pushed by jump table
    ; we need to pop it as we won't use SVC_exit (which normally pops it)

    ; exit current thread
    ; This is done by moving into interrupt mode, branching to the context switch BUT
    ; skipping the 'state saving' part of the switch.
    ; Effectively switch to next thread without saving (and enqueueing) 
    ; current one, therefore 'ending' it.

    MOV R14, #BM_interrupt_mode
    MSR CPSR, R14 ; switch to interrupt mode

    B ISR_context_switch_nosave
    ; no need for BL as we're not coming back

    ; no need for SVC_exit as the above branch will restore the state of the next available thread.

SVC_10
    ; yield to cpu
    ; effectively force a context switch
    ; problem: how do we do LR_irq = LR_svc so 
    ;          that we correctly return to the right place after the yield
    ; current solution: a lot of mode switching
    
    POP {LR}  ; restore original LR as it's been overwritten by jump table
    ; also pop it off stack as it won't be popped by SVC_exit (because we aren't branching there)

    PUSH {R0} ; to use as scratch register. NOTE: pushed to SP_svc

    MOV R0, LR ; R0 = LR_svc

    MOV R14, #BM_interrupt_mode
    MSR CPSR, R14 ; switch to interrupt mode

    MOV LR, R0 ; LR_irq = R0 = LR_svc

    MOV R0, #BM_svc_mode
    MSR CPSR, R0
    
    POP {R0} ; restore R0

    MOV R14, #BM_interrupt_mode
    MSR CPSR, R14 ; switch to interrupt mode
    
    B ISR_context_switch ; now force a context switch



SVC_exit
    POP {PC}^


DEFS 512
supervisor_stack_top DEFW 0

DEFS 512
interrupt_stack_top DEFW 0

INCLUDE interrupts.s ; contains interrupt handler & routines
INCLUDE standard_io.s

