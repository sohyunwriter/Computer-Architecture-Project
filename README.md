# computer-architecture-project
Computer Architecture Team Project

## Phase 1. TSP C programming
-bit masking to check where we have been visiting
-memorize the distance from the visited place to next place : must store ALL information
-Tail Recursion   

## Phase 2. MIPS Aseembly programming
-Arithmetic overflow, bad address exception
-runtime error was shown   

## Phase 3. Resolve Phase 2 problem and simulate on SPIM simulator
-add the distacne calculation code to operate on the new coordinate : available when the place of cities are changed
-remove dynamic allocation; just declare array
-use float data, rather than double : Can use simpler instruction, and less memory space
-use more registers to avoid spending resources to move register : Registers are used as cache, so can reduce memory access and the number of instructions   

-Total instruction: 66350   
