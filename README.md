# ARM Mini OS

This is a tiny operating system written in ARMv7 Assembly (Manchester Komodo Version). It contains the following features:
  - CPU mode management (determines mode based on privilege, e.g. user code is ran with user CPU mode, etc.)
  - Supervisor calls for OS interaction & I/O calls
  - Software multithreading w/ time slicing (context switch implementation, ability to create and exit threads, yield to CPU)
  - Example user programs

This OS is configured to run on the Manchester Lab Board, including the I/O on the board (LCD display, keyboard, timer, FPGA etc.) I have put it on GitHub for reference / reading rather than actual usage. 
