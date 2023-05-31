# ARM Mini OS

This is a tiny operating system written in ARM9 Assembly (Manchester Komodo Version). It contains the following features:
  - CPU mode management (determines mode based on privilege, e.g. user code is ran with user CPU mode, etc.)
  - Supervisor calls for user program -> OS interaction & I/O calls
  - Software multithreading w/ time slicing (context switch implementation, ability to create and exit threads, yield to CPU)
  - Example user programs

This OS is configured to run on the Manchester Lab Board, including the I/O on the board (LCD display, keyboard, timer, FPGA etc.) I have put it on GitHub for reference / reading rather than actual usage.

As well as writing this small operating system, I had the opportunity to use Cadence to design some hardware on an FPGA that would interact with the CPU. I ended up adding a memory-mapped integer divider, purely to demonstrate the benefits of the software multithreading (e.g. Thread 1 sends off a 'slow' division operation to the hardware, yields to Thread 2 which goes and does something else until the division is done, when Thread 1 can take over again). Of course division in hardware is extremely fast, so I slowed the clock down significantly as the division represents a 'notional' slower hardware operation.

Other examples include managing multiple threads that all print counters to the screen, racing them, etc.
