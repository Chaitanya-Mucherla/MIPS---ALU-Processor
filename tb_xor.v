`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.12.2025 15:53:32
// Design Name: 
// Module Name: tb_xor
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


module tb_xor;
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
        $display("Starting XOR Simulation...");
        
        // 1. ADDI R1, R0, 170 (Hex AA)
        uut.Mem[0] = 32'h280100AA; 
        uut.Mem[1] = 0; uut.Mem[2] = 0; uut.Mem[3] = 0; 

        // 2. ADDI R2, R0, 85 (Hex 55)
        uut.Mem[4] = 32'h28020055; 
        uut.Mem[5] = 0; uut.Mem[6] = 0; uut.Mem[7] = 0; 

        // 3. XOR R3, R1, R2 
        // Opcode(XOR=001111) RS(1) RT(2) RD(3)
        // Hex: 3C221800
        uut.Mem[8] = 32'h3C221800;

        // Finish
        uut.Mem[9] = 0; uut.Mem[10] = 0; uut.Mem[11] = 0;
        uut.Mem[12] = 32'hFC000000; // HLT

        wait(halted_out == 1);
        #20;
        
        $display("--------------------------------------------------");
        $display("XOR Check (AA ^ 55 = FF):");
        $display("Reg[1] (Input A): %h", uut.Reg[1]);
        $display("Reg[2] (Input B): %h", uut.Reg[2]);
        $display("Reg[3] (Result):  %h", uut.Reg[3]);
        
        if (uut.Reg[3] == 255) $display("SUCCESS: XOR Correct.");
        else $display("FAILURE.");
        $display("--------------------------------------------------");
        $stop;
    end
endmodule
