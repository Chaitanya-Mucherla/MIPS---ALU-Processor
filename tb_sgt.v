`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.12.2025 15:52:15
// Design Name: 
// Module Name: tb_sgt
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


module tb_sgt;
    reg clk1, clk2;
    wire [31:0] pc_out, alu_result, debug_operand1, debug_operand2;
    wire halted_out;

    pipe_MIPS20 uut (
        .clk1(clk1), .clk2(clk2), 
        .pc_out(pc_out), .alu_result(alu_result), 
        .halted_out(halted_out), 
        .debug_operand1(debug_operand1), .debug_operand2(debug_operand2)
    );

    initial begin
        clk1 = 0; clk2 = 0;
        forever begin
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end

    initial begin
        $display("Starting SGT (Set Greater Than) Simulation...");
        
        // 1. ADDI R1, R0, 50 
        uut.Mem[0] = 32'h28010032; // Hex for 50 is 32
        uut.Mem[1] = 0; uut.Mem[2] = 0; uut.Mem[3] = 0; 

        // 2. ADDI R2, R0, 25 
        uut.Mem[4] = 32'h28020019; // Hex for 25 is 19
        uut.Mem[5] = 0; uut.Mem[6] = 0; uut.Mem[7] = 0; 

        // 3. SGT R3, R1, R2 (50 > 25? Should be 1)
        // Opcode(SGT=000111) RS(1) RT(2) RD(3)
        // Hex: 1C221800
        uut.Mem[8] = 32'h1C221800;
        uut.Mem[9] = 0; uut.Mem[10] = 0; uut.Mem[11] = 0;

        // 4. SGT R4, R2, R1 (25 > 50? Should be 0)
        // Opcode(SGT=000111) RS(2) RT(1) RD(4)
        // Hex: 1C412000
        uut.Mem[12] = 32'h1C412000;

        // Finish
        uut.Mem[13] = 0; uut.Mem[14] = 0; uut.Mem[15] = 0;
        uut.Mem[16] = 32'hFC000000; // HLT

        $monitor("Time=%0t | PC=%d | ALU=%d | Op1=%d | Op2=%d | Halted=%b", 
                 $time, pc_out, alu_result, debug_operand1, debug_operand2, halted_out);

        wait(halted_out == 1);
        #20;
        
        $display("--------------------------------------------------");
        $display("Check 1: 50 > 25 (Expect 1): %d", uut.Reg[3]);
        if (uut.Reg[3] == 1) $display("PASS"); else $display("FAIL");

        $display("Check 2: 25 > 50 (Expect 0): %d", uut.Reg[4]);
        if (uut.Reg[4] == 0) $display("PASS"); else $display("FAIL");
        $display("--------------------------------------------------");
        $stop;
    end
endmodule

