`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.05.2025 19:30:11
// Design Name: 
// Module Name: mips32_test2
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


module mips32_test2();
 reg clk1, clk2;
    integer k;

    pipe_MIPS32 mips(clk1, clk2);

    initial
    begin
        clk1 = 0; clk2 = 0;
        repeat(50)   // shows that there will be 20 clock cycles
        begin       // generating two phase clock
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0; 
        end

    end
    initial
    begin
        for(k = 0; k < 31; k = k +1)
            mips.Reg[k] = k; // initialize registers
            
        mips.mem[0] = 32'h28010078;  // ADDI R1, R0, 120;
        mips.mem[1] = 32'h0c631800;  // OR   R3, R3, R3; -- Dummy instruction
        mips.mem[2] = 32'h20220000;  // LW   R2, 0(R1);
        mips.mem[3] = 32'h0c631800;  // OR   R3, R3, R3; -- Dummy instruction
        mips.mem[4] = 32'h2842002d;  // ADDI R2, R2, 45;
        mips.mem[5] = 32'h0c631800;  // OR   R3, R3, R3; -- Dummy instruction
        mips.mem[6] = 32'h24220001;  // SW   R2, 1(R1);
        mips.mem[7] = 32'hfc000000;  // HLT
        mips.mem[120] = 85;
        mips.HALTED = 0;
        mips.PC = 0;
        mips.TAKEN_BRANCH = 0;

        #500
        $display("Mem[120]: %4d \nMem[121]: %4d", mips.mem[120], mips.mem[121]);
      end 
      
       initial 
            #600 $finish; 
      
            
endmodule
