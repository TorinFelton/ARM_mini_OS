INCLUDE ../os/OS_header.s


; Description of program:
; This is interesting. We have 3 threads in the pool. program1.s will increment a memory location by 1 as fast as possible,
; program2.s will increment a different location by 2 also as fast as possible.
; However, program1.s is FIRST in the queue at the beginning (aka it runs before prog2 does)
; program3.s checks for the first one to reach 1,000,000 and outputs the winner.


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
  

    SVC call_END_ATOMIC_BLOCK

    SVC call_exit_thread ; throw away setup thread


INCLUDE program1.s
INCLUDE program2.s
INCLUDE program3.s