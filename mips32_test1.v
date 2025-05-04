`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.05.2025 19:06:44
// Design Name: 
// Module Name: mips32_test1
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


module mips32_test1();
 reg clk1, clk2;
    integer k;

    pipe_MIPS32 mips(clk1, clk2);

    initial
    begin
        clk1 = 0; clk2 = 0;
        repeat(20)   // shows that there will be 20 clock cycles
        begin       // generating two phase clock
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0; 
        end

    end
    initial
    begin
        for(k = 0; k < 31; k = k +1)
            mips.Reg[k] = k; // initialize registers
        
        mips.mem[0] = 32'h2801000a;  // ADDI R1, R0, 10;
        mips.mem[1] = 32'h28020014;  // ADDI R2, R0, 20;
        mips.mem[2] = 32'h28030019;  // ADDI R3, R0, 25;
        mips.mem[3] = 32'h0ce77800;  // OR   R7, R7, R7; -- Dummy instruction (not req)
        mips.mem[4] = 32'h0ce77800;  // OR   R7, R7, R7; -- Dummy instruction (not req)
        mips.mem[5] = 32'h00222000;  // ADD  R4, R1, R2;
        mips.mem[6] = 32'h0ce77800;  // OR   R7, R7, R7; -- Dummy instruction
        mips.mem[7] = 32'h00832800;  // ADD  R5, R4, R3;
        mips.mem[8] = 32'hfc000000;  // HLT
        mips.HALTED = 0;
        mips.PC = 0;
        mips.TAKEN_BRANCH = 0;

        #280
        for(k = 0; k < 6; k = k + 1)
            $display("R%1d - %2d", k , mips.Reg[k]);
    end
    initial 
    begin
            #300 $finish; 
    end

endmodule
