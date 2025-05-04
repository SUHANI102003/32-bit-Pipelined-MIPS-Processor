`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2025 11:29:56
// Design Name: 
// Module Name: pipe_MIPS32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pipe_MIPS32(
input clk1, clk2
    );
    
reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
// type = instruction we are decoding like load, alu, store etc
reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;
reg [31:0] EX_MEM_IR, EX_MEM_B, EX_MEM_ALUout, EX_MEM_cond;
reg [31:0]  MEM_WB_LMD,  MEM_WB_IR,  MEM_WB_ALUout;

reg [31:0] Reg [0:31];// register bank
reg [31:0] mem [0:1023]; // memory

// opcodes for instructions. using parameter so the code is readable
parameter ADD = 6'b000000, SUB = 6'b000001, AND = 6'B000010,
          OR = 6'B000011, SLT = 6'B000100, MUL= 6'B000101,
          HLT = 6'B111111, LW = 6'B001000, SW=6'B001001, ADDI=6'B001010,
          SUBI=6'B001011, SLTI = 6'B001100, BNEQZ=6'B001101, BEQZ=6'B001110;

// these are the type of instructions that is excecuted
// whether it is reg-reg, reg-mem, branch, load, etc         
parameter RR_ALU = 3'B000, RM_ALU = 3'B001, LOAD = 3'B010,
            STORE = 3'B011, BRANCH = 3'B100, HALT = 3'B101;
            
reg HALTED;
// set after HLT instruction is completed (in WB stage)

reg TAKEN_BRANCH;
// required to disable instruc after branch

// IF STAGE
always @(posedge clk1) 
    if (HALTED == 0)
    begin
        if (((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1)) ||
           ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0)))
        // cond = (A==0);
        begin // branch taken
            IF_ID_IR        <= #2 mem[EX_MEM_ALUout];
            TAKEN_BRANCH    <= #2 1'b1; 
            IF_ID_NPC       <= #2 EX_MEM_ALUout + 1;
            PC              <= #2 EX_MEM_ALUout + 1; 
        end
        
        else 
        begin
             IF_ID_IR            <= #2 mem[PC];
             IF_ID_NPC           <= #2 PC + 1;
             PC                  <= #2 PC + 1;
        end
    end
    
// ID STAGE
// 1. we decode the instruction - we are not showing in verilog code
// b/c there is implied in case statements
// 2. we are prefetching 2 source registers
// 3. sign extending 16 bit offset
 always @(posedge clk2)  
        if(HALTED == 0)
        begin
        // checking cond for R0 = 0; should always contain 0
            if(IF_ID_IR[25:21] == 5'b00000)
                ID_EX_A <= 0;
             else
                ID_EX_A <= #2 Reg[IF_ID_IR[25:21]]; // "rs"
                
              if(IF_ID_IR[20:16] == 5'b00000)
                    ID_EX_B <= 0;
                else 
                    ID_EX_B <= #2 Reg[IF_ID_IR[20:16]]; // "rt"
                    
                     ID_EX_NPC   <= #2 IF_ID_NPC;
                     ID_EX_IR    <= #2 IF_ID_IR;
                     ID_EX_Imm   <= #2 {{16{IF_ID_IR[15]}}, {IF_ID_IR[15:0]}};   // sign extension
 // the signed bit is replicated in sign extension, so we take the 15th bit and replicate it 16 times and then concatenate with the bits 15 to 0.
     
     case(IF_ID_IR[31:26])
                    ADD, SUB, AND, OR, SLT, MUL : ID_EX_type <= #2 RR_ALU;
                    ADDI, SUBI, SLTI            : ID_EX_type <= #2 RM_ALU;
                    LW                          : ID_EX_type <= #2 LOAD;
                    SW                          : ID_EX_type <= #2 STORE;
                    BEQZ, BNEQZ                 : ID_EX_type <= #2 BRANCH;
                    HLT                         : ID_EX_type <= #2 HALT;
                    default                     : ID_EX_type <= #2 HALT; // INVALID OPCODE
                endcase
        end
 
 // EX STAGE
  always @(posedge clk1)      
        if(HALTED == 0)
        begin
                //below three register values are forwaded to next stage
                EX_MEM_type         <= #2 ID_EX_type;  
                EX_MEM_IR           <= #2 ID_EX_IR;
                TAKEN_BRANCH        <= #2 0;
       
       case(ID_EX_type)  // check for type of instruction
                    RR_ALU      :   begin
                         case(ID_EX_IR[31:26]) // "opcode checking"
                              ADD     : EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_B;
                              SUB     : EX_MEM_ALUout <= #2 ID_EX_A - ID_EX_B;
                              AND     : EX_MEM_ALUout <= #2 ID_EX_A & ID_EX_B;
                              OR      : EX_MEM_ALUout <= #2 ID_EX_A | ID_EX_B;
                              SLT     : EX_MEM_ALUout <= #2 ID_EX_A < ID_EX_B;
                              MUL     : EX_MEM_ALUout <= #2 ID_EX_A * ID_EX_B;
                              default : EX_MEM_ALUout <= #2 32'hxxxxxxxx;
                           endcase
                        end 
                       
 RM_ALU      :   begin 
                    case(ID_EX_IR[31:26])
                         ADDI    : EX_MEM_ALUout <= #2 ID_EX_A + ID_EX_Imm;
                         SUBI    : EX_MEM_ALUout <= #2 ID_EX_A - ID_EX_Imm;
                         SLTI    : EX_MEM_ALUout <= #2 ID_EX_A < ID_EX_Imm;
                         default : EX_MEM_ALUout <= #2 32'hxxxxxxxx;
                      endcase
                          end
                          
 LOAD, STORE :   begin 
                    EX_MEM_ALUout   <= #2 ID_EX_A + ID_EX_Imm; // this will give us address of memory which will be stored in ALUOut.
                    EX_MEM_B        <= #2 ID_EX_B;              // value of B is forwarded to next stage
                 end
                    
  BRANCH      :   begin 
                  EX_MEM_ALUout   <= #2 ID_EX_NPC + ID_EX_Imm;  // calculating the target address if branch has to be taken
                  EX_MEM_cond     <= #2 (ID_EX_A == 0);
                   end

                endcase
        end 
        
 // MEM STAGE
   always @(posedge clk2)              // MEM STAGE
            if(HALTED == 0)
            begin
                    MEM_WB_type     <= #2 EX_MEM_type; 
                    MEM_WB_IR       <= #2 EX_MEM_IR;
                    case(EX_MEM_type)
                        RR_ALU, RM_ALU  : MEM_WB_ALUout         <= #2 EX_MEM_ALUout;
                        LOAD            : MEM_WB_LMD            <= #2 mem[EX_MEM_ALUout];
                        STORE           : if(TAKEN_BRANCH == 0)             // disable write
                                            mem[EX_MEM_ALUout]  <= #2 EX_MEM_B;
                    endcase
            end
         
 // WB STAGE
  always @(posedge clk1)      // WB STAGE
        begin
                if(TAKEN_BRANCH == 0)           // disable write if branch taken
                    case(MEM_WB_type)
                        RR_ALU  : Reg[MEM_WB_IR[15:11]]     <= #2 MEM_WB_ALUout;  // "rd" 
                        RM_ALU  : Reg[MEM_WB_IR[20:16]]     <= #2 MEM_WB_ALUout;  // "rt"
                        LOAD    : Reg[MEM_WB_IR[20:16]]     <= #2 MEM_WB_LMD;     // "rt"
                        HALT    : HALTED                    <= #2 1'b1;
                    endcase
        end
endmodule
