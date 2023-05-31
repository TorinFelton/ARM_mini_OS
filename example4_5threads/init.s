INCLUDE ../os/OS_header.s



init
    SVC call_BEGIN_ATOMIC_BLOCK ; don't want to be interrupted while setting up the threads

    ADRL R0, prog1
    ADRL R1, prog1_stack
    SVC call_add_thread_to_pool ; add prog1 to thread pool to allow context switching to it


    ADRL R0, prog2
    ADRL R1, prog2_stack
    SVC call_add_thread_to_pool ; add prog2 to thread pool to allow context switching to it

    ADRL R0, prog3
    ADRL R1, prog3_stack
    SVC call_add_thread_to_pool ; add prog3

    ADRL R0, prog4
    ADRL R1, prog4_stack
    SVC call_add_thread_to_pool ; add prog2 to thread pool to allow context switching to it

    ADRL R0, prog5
    ADRL R1, prog5_stack
    SVC call_add_thread_to_pool ; add prog2 to thread pool to allow context switching to it
  

    SVC call_END_ATOMIC_BLOCK

    SVC call_exit_thread ; throw away setup thread


INCLUDE program1.s
INCLUDE program2.s
INCLUDE program3.s
INCLUDE program4.s
INCLUDE program5.s