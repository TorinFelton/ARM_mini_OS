Example 3: Hardware Usage
This example contains 3 programs.

program1.s: This program makes use of the hardware-based 16-bit divider. It will set up inputs A and B (each 16 bit numbers) and 
then send a 'START_DIV' instruction to the hardware divider. After this instruction is sent, Program 1 yields (forces a context switch).
When it is Program 1's turn to be resumed, it will execute a loop waiting for the hardware divider
to send an 'ok' response signifying the end of the division. Once this happens, Program 1 will exit itself.

program2.s: The same program from other examples (just increments a memory location by 1 continuously).

program3.s: Will output the division result and Program 2's incremented memory location. Once the correct division result is 
shown, it will hang (effectively terminate all programs). After this, you can see on the screen the division result and also
the number that Program 2 managed to increment to in the time that division was happening.