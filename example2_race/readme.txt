Example 2: Race
This example races 2 threads against each other, and outputs the result via a 3rd thread.

program1.s: Simple program that increments a memory location by 1.

program2.s: Simple program that increments a memory location by 2.

program3.s: Checks both memory locations referenced above to see if they have reached the WINNING_VALUE.
If one has, they are shown on the LCD as a winner.


Note: Program 2 increments by 2 as it begins at a disadvantage, given that Program 1 is first in the thread queue. 