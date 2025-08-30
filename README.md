# Implementation-of-32-bit-Pipelined-MIPS-Processor

This repository contains the details and the code for the MIPS32 ISA based RISC 5 stage pipelined Processor along with 3 test test programs in assembly language to verify the functionality of pipeline processor.  
Mips has simple and fewer number of instructions and addressing modes and large number of registers making it easier to implement.


## ▫️ MIPS32  
- 32 x 32 bit GPRs [R0 to R31]  
- R0 hardwired to logic 0 ; cannot be written to
- 32 bit Program Counter (PC)  
- No flag registers (carry, zero, sign..etc)  
- Few Addresing Modes  
- Only Load and Store instructions can access memory  
- We assume memory word size is 32 bits (word addressable)
  
## ▫️ Addressing Modes  
| Addressing Mode | Example Instruction |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Register addressing | ADD R1,R2,R3      |
| Immediate addressing | ADDI R1,R2, 200       |
| Base addressing      | LW R5, 150(R7)    |
| PC relative addressing  | BEQZ R3, Label   |
| Pseudo-direct addressing | J Label      |


## ▫️ Instructions Considered  
Not all instructions of MIPS32 are considered in this design, for implementation sake only a few instructions are considered, mentioned below:  
- Load and Store Instructions  
```
LW R2,124(R8) // R2 = Mem[R8+124]  
SW R5,-10(R25) // Mem[R25-10] = R5  
```
- Arithmetic and Logic Instructions (only register operands)  
```
ADD R1,R2,R3 // R1 = R2 + R3  
ADD R1,R2,R0 // R1 = R2 + 0  
SUB R12,R10,R8 // R12 = R10 – R8  
AND R20,R1,R5 // R20 = R1 & R5  
OR R11,R5,R6 // R11 = R5 | R6  
MUL R5,R6,R7 // R5 = R6 * R7  
SLT R5,R11,R12 // If R11 < R12, R5=1; else R5=0 
```
- Arithmetic and Logic Instructions (immediate operand)  
```
ADDI R1,R2,25 // R1 = R2 + 25  
SUBI R5,R1,150 // R5 = R1 – 150  
SLTI R2,R10,10 // If R10<10, R2=1; else R2=0 
```
- Branch Instructions  
```
BEQZ R1,Loop // Branch to Loop if R1=0  
BNEQZ R5,Label // Branch to Label if R5!=0  
```
- Jump Instruction  
```
J Loop // Branch to Loop unconditionally  
```
- Miscellaneous Instructioon  
```
HLT // Halt execution 
```

## ▫️ Instruction Encoding  
![ISR](https://user-images.githubusercontent.com/68592620/231771092-0c93aeb3-6b01-478f-a363-ecadb1ec578a.png)  
- shamt : shift amount, funct : opcode extension for additional functions.
- Some instructions require two register operands rs & rt as input, while some require only rs. 
- This requirement is only identified only after the instruction is decoded. 
- While decoding is going on, we can prefetch the registers in parallel, which may or may not be used later. 
- Similarly, the 16-bit and 26-bit immediate data are retrieved and signextended to 32-bits in case they are required later.
  
## ▫️ Stages of Execution  
The instruction execution cycle contains the following 5 stages in order:  
1. IF : Instruction Fetch  
2. ID : Instruction Decode / Register Fetch  
3. EX : Execution / Effective Address Calculation  
4. MEM : Memory Access / Branch Completion  
5. WB : Register Write-back  
- micro operations not shown here.
  
## ▫️ Non Pipelined DataPath  
![nonpipelined](https://user-images.githubusercontent.com/68592620/231771101-f7ea7e00-5c8c-4b6d-ae0c-a0419066e7ad.png)  

## ▫️ Pipelined DataPath  
![pipelined](https://user-images.githubusercontent.com/68592620/231771102-12c05fa9-6e74-4835-abc6-1bd9b20e8453.png)  

## ▫️ Example Test 1   
 
Instructions :  
| Assembly Instruction  | Machine Code | Hexcode |  
| ------------- | ------------- | ------------- |  
| ADDI R1,R0,10  | 001010 00000 00001 0000000000001010  | 2801000a  |  
| ADDI R2,R0,20 | 001010 00000 00010 0000000000010100  | 28020014  |  
| ADDI R3,R0,25 | 001010 00000 00011 0000000000011001  | 28030019  |  
| OR R7,R7,R7 (dummy)| 001010 00000 00011 0000000000011001  | 0ce77800  |  
| OR R7,R7,R7 (dummy)| 001010 00000 00011 0000000000011001  | 0ce77800  |  
| ADD R4,R1,R2 | 000000 00001 00010 00100 00000 000000  | 00222000  |  
| OR R7,R7,R7 (dummy)| 001010 00000 00011 0000000000011001  | 0ce77800 |  
| ADD R5,R4,R3 | 000000 00100 00011 00101 00000 000000  | 00832800  |  
| HLT | 111111 00000 00000 00000 00000 000000  | fc000000  |  


Waveform :  

![](https://github.com/SUHANI102003/32-bit-Pipelined-MIPS-Processor/blob/main/sim_logs/test1%20(2).png)

Console output :  

![](https://github.com/SUHANI102003/32-bit-Pipelined-MIPS-Processor/blob/main/sim_logs/test1%20(1).png)

## ▫️ Example Test 2

Instructions :  
| Assembly Instruction  | Machine Code | Hexcode |  
| ------------- | ------------- | ------------- |  
| ADDI R1,R0,10  | 001010 00000 00001 0000000000001010  | 2801000a  |  
| ADDI R2,R0,20 | 001010 00000 00010 0000000000010100  | 28020014  |  
| ADDI R3,R0,25 | 001010 00000 00011 0000000000011001  | 28030019  |  
| OR R7,R7,R7 (dummy)| 001010 00000 00011 0000000000011001  | 0ce77800  |  
| OR R7,R7,R7 (dummy)| 001010 00000 00011 0000000000011001  | 0ce77800  |  
| ADD R4,R1,R2 | 000000 00001 00010 00100 00000 000000  | 00222000  |  
| OR R7,R7,R7 (dummy)| 001010 00000 00011 0000000000011001  | 0ce77800 |  
| ADD R5,R4,R3 | 000000 00100 00011 00101 00000 000000  | 00832800  |  
| HLT | 111111 00000 00000 00000 00000 000000  | fc000000  |  

Waveform:

![Screenshot 2025-05-04 191947.png](<https://media-hosting.imagekit.io/3164ce249b934a23/Screenshot%202025-05-04%20191947.png?Expires=1840977634&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=V2ATnnO-mqemxuztCtbx5-UZimxA2YWd~MUskf65vWxlyB6Iv7U5CTotdoPK60HDdRRWs8Ggg2qWfvB-Agyzv~~Kmxbe8m58wRmpYIpxT0PY0cX83jMvmCIxGFDz5e5JqRu6Fa59CmY~ZemqgXQ4CoJ0KUAWMHuYHp3q~nUEPHqXbvZozeIamRrRvHi3DKSWQNwrrGNrOLG-S8HCJFAoIxFgOi0TWsiDKBKsla7-87MpHwUafN~WyAOD5NavL7MOYP4Gy783DgJUA5JgwHJrZxoiF9~sNIDSrYMLqYJgqpbYoxlFZ~K29Gslk-Y~lJV8UEP4ncuFVATB18CYdMUKBg__>)

Console Output:

![Screenshot 2025-05-04 191633.png](<https://media-hosting.imagekit.io/2dcddde7ccd742d4/Screenshot%202025-05-04%20191633.png?Expires=1840977885&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=zRQ9h8vnFoUnZ~w7lgQ~BEUhGeAtIzZ6tCuRnT-A8N6rOH0DD8QhKAfAyFHwoNEplbPOLZhQkcsCgA6SDv3E4T9mofdTYmULWVyG09~rlIm8ghtgpOfW4C2QHCN3IUe2iQbO-OGzqun7bWCyqB1aD~xV2G-bSO0pEjKE15mJbiafPz1tXjCNquTlQMOFFIuw7Lv2adTRVpvmiFrTE5qh34xOSh4pR44mLc~mDFD6iHDkP3qnTHQ-iJtuAVsY1TCI1TsT1EaIKBpCTJboymcIoHMVPOgQKVrde~1mq95KxC2xFflPNnmoiEry8~iJxxf7sYUPcsyEGVs7MaMPhea5WA__>)


## ▫️ Example Test 3

Instructions :  
| Assembly Instruction  | Machine Code | Hexcode |  
| ------------- | ------------- | ------------- |  
| ADDI R1,R0,10  | 001010 00000 00001 0000000000001010  | 2801000a  |  
| ADDI R2,R0,20 | 001010 00000 00010 0000000000010100  | 28020014  |  
| ADDI R3,R0,25 | 001010 00000 00011 0000000000011001  | 28030019  |  
| OR R7,R7,R7 (dummy)| 001010 00000 00011 0000000000011001  | 0ce77800  |  
| OR R7,R7,R7 (dummy)| 001010 00000 00011 0000000000011001  | 0ce77800  |  
| ADD R4,R1,R2 | 000000 00001 00010 00100 00000 000000  | 00222000  |  
| OR R7,R7,R7 (dummy)| 001010 00000 00011 0000000000011001  | 0ce77800 |  
| ADD R5,R4,R3 | 000000 00100 00011 00101 00000 000000  | 00832800  |  
| HLT | 111111 00000 00000 00000 00000 000000  | fc000000  |  

Waveform:

![Screenshot 2025-05-04 191947.png](<https://media-hosting.imagekit.io/3164ce249b934a23/Screenshot%202025-05-04%20191947.png?Expires=1840977634&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=V2ATnnO-mqemxuztCtbx5-UZimxA2YWd~MUskf65vWxlyB6Iv7U5CTotdoPK60HDdRRWs8Ggg2qWfvB-Agyzv~~Kmxbe8m58wRmpYIpxT0PY0cX83jMvmCIxGFDz5e5JqRu6Fa59CmY~ZemqgXQ4CoJ0KUAWMHuYHp3q~nUEPHqXbvZozeIamRrRvHi3DKSWQNwrrGNrOLG-S8HCJFAoIxFgOi0TWsiDKBKsla7-87MpHwUafN~WyAOD5NavL7MOYP4Gy783DgJUA5JgwHJrZxoiF9~sNIDSrYMLqYJgqpbYoxlFZ~K29Gslk-Y~lJV8UEP4ncuFVATB18CYdMUKBg__>)

Console Output:

![Screenshot 2025-05-04 191633.png](<https://media-hosting.imagekit.io/2dcddde7ccd742d4/Screenshot%202025-05-04%20191633.png?Expires=1840977885&Key-Pair-Id=K2ZIVPTIP2VGHC&Signature=zRQ9h8vnFoUnZ~w7lgQ~BEUhGeAtIzZ6tCuRnT-A8N6rOH0DD8QhKAfAyFHwoNEplbPOLZhQkcsCgA6SDv3E4T9mofdTYmULWVyG09~rlIm8ghtgpOfW4C2QHCN3IUe2iQbO-OGzqun7bWCyqB1aD~xV2G-bSO0pEjKE15mJbiafPz1tXjCNquTlQMOFFIuw7Lv2adTRVpvmiFrTE5qh34xOSh4pR44mLc~mDFD6iHDkP3qnTHQ-iJtuAVsY1TCI1TsT1EaIKBpCTJboymcIoHMVPOgQKVrde~1mq95KxC2xFflPNnmoiEry8~iJxxf7sYUPcsyEGVs7MaMPhea5WA__>)


## ▫️ Known problems and issues  
Following pipelining hazards are present in the given design :  
- Structural Hazards due to shared hardware.  
- Data Hazards due to instruction data dependency.  
- Control hazards due to branch instructions.  
## ▫️ References  
[NPTEL \& IIT KGP 'Hardware Modeling using Verilog'- Prof. Indranil Sengupta](https://nptel.ac.in/courses/106105165)
