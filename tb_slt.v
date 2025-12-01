`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2025 01:58:21
// Design Name: 
// Module Name: tb_slt
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

module tb_slt;

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
        $display("       STARTING SLT TEST (SMALL NUMBERS)          ");
        $display("==================================================");

        // 1. ADDI R1, R0, 1  (Load value 1)
        // Hex: 28010001
        uut.Mem[0] = 32'h28010001;

        // --- NOP Bubbles ---
        uut.Mem[1] = 0; uut.Mem[2] = 0; uut.Mem[3] = 0; 

        // 2. ADDI R2, R0, 2  (Load value 2)
        // Hex: 28020002
        uut.Mem[4] = 32'h28020002;

        // --- NOP Bubbles ---
        uut.Mem[5] = 0; uut.Mem[6] = 0; uut.Mem[7] = 0;

        // 3. CASE 1: SLT R3, R1, R2 
        // Logic: Is 1 < 2? (YES/TRUE)
        // Result should be 1
        // Hex: 10221800
        uut.Mem[8] = 32'h10221800;
        
        // --- NOP Bubbles ---
        uut.Mem[9] = 0; uut.Mem[10] = 0; uut.Mem[11] = 0;

        // 4. CASE 2: SLT R4, R2, R1
        // Logic: Is 2 < 1? (NO/FALSE)
        // Result should be 0
        // Hex: 10412000
        uut.Mem[12] = 32'h10412000;

        // --- Finishing NOPs and HALT ---
        uut.Mem[13] = 0; uut.Mem[14] = 0; uut.Mem[15] = 0;
        uut.Mem[16] = 32'hFC000000; // HLT

        // Run until halted
        wait(halted_out == 1);
        #20; 
        
        $display("\n==================================================");
        $display("                 FINAL RESULTS                    ");
        $display("==================================================");
        
        $display("Inputs: R1=%0d, R2=%0d", uut.Reg[1], uut.Reg[2]);
        
        // Verify Case 1
        $display("\nCheck 1: 1 < 2? (Should be 1)");
        $display("  Actual Result (Reg[3]): %0d", uut.Reg[3]);
        
        if (uut.Reg[3] == 1) 
            $display("  >>> STATUS: PASS <<<");
        else 
            $display("  >>> STATUS: FAIL <<<");

        // Verify Case 2
        $display("\nCheck 2: 2 < 1? (Should be 0)");
        $display("  Actual Result (Reg[4]): %0d", uut.Reg[4]);

        if (uut.Reg[4] == 0) 
            $display("  >>> STATUS: PASS <<<");
        else 
            $display("  >>> STATUS: FAIL <<<");

        $display("==================================================");
        $stop;
    end
      
endmodule
