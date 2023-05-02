INCLUDE ../os/OS_header.s



init
    SVC call_BEGIN_ATOMIC_BLOCK ; don't want to be interrupted while setting up the threads

    ADRL R0, divider_program
    ADRL R1, divider_program_stack
    SVC call_add_thread_to_pool ; add divider program to thread pool to allow context switching to it


    ADRL R0, prog2
    ADRL R1, prog2_stack
    SVC call_add_thread_to_pool ; add prog2 to thread pool to allow context switching to it

    ADRL R0, prog3
    ADRL R1, prog3_stack
    SVC call_add_thread_to_pool ; add prog3
  

    SVC call_END_ATOMIC_BLOCK

    SVC call_exit_thread ; throw away setup thread


INCLUDE program1.s
INCLUDE program2.s
INCLUDE program3.s