; v1.0


TS_BUFFER_MAX_CAPACITY EQU 3

TS_BUFFER_setup
    ; FUNCTION: Setup pointers for TS buffer
    ; Description: Should be called at OS setup stage.
    PUSH {R0-R1, LR}

    ; Set up pointers
    ADRL R0, TS_CIRC_BUFFER
    ADR R1, TS_CIRC_BUFFER_HEAD
    STR R0, [R1]
    ADR R1, TS_CIRC_BUFFER_TAIL
    STR R0, [R1]

    POP {R0-R1, PC}


TS_BUFFER_enqueue
    ; FUNCTION: Enqueue a stack pointer to the thread stack buffer
    ; INPUT: R0 as the pointer to enqueue
    ; OUTPUT: None
    ; Description: Enqueues (circularly) stack pointer to buffer. Will NOT overwrite if full.

    PUSH {R1-R4, LR}

    ADR R1, TS_CIRC_BUFFER_LENGTH
    LDR R1, [R1]
    MOV R2, #TS_BUFFER_MAX_CAPACITY
    CMP R1, R2
        POPGE {R1-R4, PC} ; exit routine; don't enqueue if buffer is full

    ; ------ 1. & 2. ------
    ADR R1, TS_CIRC_BUFFER_HEAD
    LDR R2, [R1] ; load pointer from TS_CIRC_BUFFER_HEAD
    STR R0, [R2], #-4               ; -4 as we are word-addressing 

    ; ----- 3. ------
    ADR R3, TS_CIRC_BUFFER
    SUB R4, R3, #(32*TS_BUFFER_MAX_CAPACITY)
    CMP R2, R4
    MOVLT R2, R3 ; if R2 is out of range, change R2 to point back to the top (TS_CIRC_BUFFER)


    STR R2, [R1] ; Store new head pointer back to TS_CIRC_BUFFER_HEAD

    ADR R1, TS_CIRC_BUFFER_LENGTH
    LDR R2, [R1]
    ADD R2, R2, #1 ; +1 to amount of enqueued items (length)
    STR R2, [R1]

    
    POP {R1-R4, PC}

TS_BUFFER_dequeue
    ; FUNCTION: Dequeue thread stack pointer
    ; INPUT: None
    ; OUTPUT: R0 overwritten with next thread stack pointer

    PUSH {R1-R4, LR}

    ADR R1, TS_CIRC_BUFFER_LENGTH
    LDR R1, [R1]
    MOV R2, #0
    CMP R1, R2
        ; Return 0 (empty value) if queue is empty
        MOVEQ R0, #0 ; Return value of 0 as a default
        POPEQ {R1-R4, PC} ; exit routine early to avoid code below

    ; ------ 1. & 2. ------
    ADR R1, TS_CIRC_BUFFER_TAIL
    LDR R2, [R1] ; load pointer from TS_CIRC_BUFFER_TAIL
    LDR R0, [R2], #-4

    ; ----- 3. ------
    ADR R3, TS_CIRC_BUFFER
    SUB R4, R3, #(32*TS_BUFFER_MAX_CAPACITY)
    CMP R2, R4
    MOVLT R2, R3 ; if R2 is out of range, change R2 to point back to the top (TS_CIRC_BUFFER)
    

    STR R2, [R1] ; Store new tail pointer back to TS_CIRC_BUFFER_TAIL

    ADR R1, TS_CIRC_BUFFER_LENGTH
    LDR R2, [R1]
    SUB R2, R2, #1 ; -1 to amount of enqueued items (length)
    STR R2, [R1]

    POP {R1-R4, PC}

TS_CIRC_BUFFER_LENGTH DEFW 0
TS_CIRC_BUFFER_HEAD DEFW 0
TS_CIRC_BUFFER_TAIL DEFW 0
DEFS 128
TS_CIRC_BUFFER DEFW 0