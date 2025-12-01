`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2025 01:29:03
// Design Name: 
// Module Name: tb_logic_ops
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


`timescale 1ns / 1ps

module tb_logic_ops;

    // Inputs
    reg clk1;
    reg clk2;

    // Outputs
    wire [31:0] pc_out;
    wire [31:0] alu_result;
    wire halted_out;
    wire [31:0] debug_operand1;
    wire [31:0] debug_operand2;

    // Instantiate the Unit Under Test (UUT)
    pipe_MIPS20 uut (
        .clk1(clk1), 
        .clk2(clk2), 
        .pc_out(pc_out), 
        .alu_result(alu_result), 
        .halted_out(halted_out), 
        .debug_operand1(debug_operand1), 
        .debug_operand2(debug_operand2)
    );

    // Clock Generation
    initial begin
        clk1 = 0; clk2 = 0;
        forever begin
            #5 clk1 = 1; #5 clk1 = 0;
            #5 clk2 = 1; #5 clk2 = 0;
        end
    end

    initial begin
        $display("==================================================");
        $display("   STARTING LOGIC OPS (Clean Numbers)             ");
        $display("==================================================");

        // 1. ADDI R1, R0, 170
        // Hex: 280100AA | Binary Pattern: 1010 1010
        uut.Mem[0] = 32'h280100AA;

        // --- NOP Bubbles ---
        uut.Mem[1] = 0; uut.Mem[2] = 0; uut.Mem[3] = 0; 

        // 2. ADDI R2, R0, 85
        // Hex: 28020055 | Binary Pattern: 0101 0101
        uut.Mem[4] = 32'h28020055;

        // --- NOP Bubbles ---
        uut.Mem[5] = 0; uut.Mem[6] = 0; uut.Mem[7] = 0;

        // 3. AND R3, R1, R2
        // Hex: 08221800 
        // Expected: 1010... & 0101... = 0
        uut.Mem[8] = 32'h08221800;
        
        // --- NOP Bubbles ---
        uut.Mem[9] = 0; uut.Mem[10] = 0; uut.Mem[11] = 0;

        // 4. OR R4, R1, R2
        // Hex: 0C222000 
        // Expected: 1010... | 0101... = 1111... (255 or FF)
        uut.Mem[12] = 32'h0C222000;

        // --- Finishing NOPs and HALT ---
        uut.Mem[13] = 0; uut.Mem[14] = 0; uut.Mem[15] = 0;
        uut.Mem[16] = 32'hFC000000; // HLT

        // Run until halted
        wait(halted_out == 1);
        #20;
        
        $display("\n==================================================");
        $display("                 FINAL RESULTS                    ");
        $display("==================================================");
        
        $display("Input R1 (Hex AA): %0d", uut.Reg[1]);
        $display("Input R2 (Hex 55): %0d", uut.Reg[2]);
        
        // --- AND CHECK ---
        $display("\nTest 1: AND (AA & 55)");
        $display("  Expected: 0");
        $display("  Actual:   %0d", uut.Reg[3]);
        
        // --- OR CHECK ---
        $display("\nTest 2: OR (AA | 55)");
        $display("  Expected: 255 (Hex FF)");
        $display("  Actual:   %0d", uut.Reg[4]);

        if (uut.Reg[3] == 0 && uut.Reg[4] == 255) 
            $display("\n  >>> STATUS: ALL LOGIC OPS PASSED <<<");
        else 
            $display("\n  >>> STATUS: FAIL <<<");

        $display("==================================================");
        $stop;
    end
      
endmodule
