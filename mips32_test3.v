`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.05.2025 19:43:13
// Design Name: 
// Module Name: mips32_test3
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


module mips32_test3();
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
            
        mips.mem[0] = 32'h280a00c8;  // ADDI R10, R0, 200;
        mips.mem[1] = 32'h28020001;  // ADDI R2, R0, 1;
        mips.mem[2] = 32'h0e94a000;  // OR   R20, R20, R20; -- Dummy instruction
        mips.mem[3] = 32'h21430000;  // LW R3, 0()R10;
        mips.mem[4] = 32'h0e94a000;  // OR   R20, R20, R20; -- Dummy instruction
        mips.mem[5] = 32'h14431000;  // Loop: MUL R2,R2,R3;
        mips.mem[6] = 32'h2c630001;  // SUBI R3, R3, 1;
        mips.mem[7] = 32'h0e94a000;  // OR   R20, R20, R20; -- Dummy instruction
        mips.mem[8] = 32'h3460fffc;  // BNEQZ R3, Loop (i.e, -4 offset)
        mips.mem[9] = 32'h2542fffe;  // SW R2, -2(R10);
        mips.mem[10] = 32'hfc000000;  // HLT
        
        mips.mem[200] = 7; // find factorial of 7
        
        mips.HALTED = 0;
        mips.PC = 0;
        mips.TAKEN_BRANCH = 0;

        #2000
        $display("Mem[200]: %2d , Mem[198]: %6d", mips.mem[200], mips.mem[198]);
      end 
      
       initial begin
            $monitor("R2: %4d", mips.Reg[2]);
            #3000 $finish; 
      end
endmodule
