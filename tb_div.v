`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.12.2025 15:49:59
// Design Name: 
// Module Name: tb_div
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


module tb_div;

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
        $display("   STARTING DIVISION TEST (With Hazard Handling)  ");
        $display("==================================================");

        // --- STEP 1: LOAD DIVIDEND (20) ---
        // ADDI R1, R0, 20
        // Hex: 28010014
        uut.Mem[0] = 32'h28010014;

        // --- HAZARD HANDLING FOR R1 ---
        // Since the processor lacks forwarding, we must wait 3 cycles 
        // for R1 to travel from ID stage to WB stage before reading it.
        uut.Mem[1] = 32'h00000000; // NOP 1
        uut.Mem[2] = 32'h00000000; // NOP 2
        uut.Mem[3] = 32'h00000000; // NOP 3

        // --- STEP 2: LOAD DIVISOR (4) ---
        // ADDI R2, R0, 4
        // Hex: 28020004
        uut.Mem[4] = 32'h28020004;

        // --- HAZARD HANDLING FOR R2 ---
        // Wait 3 cycles for R2 to be written back to Register File.
        uut.Mem[5] = 32'h00000000; // NOP 1
        uut.Mem[6] = 32'h00000000; // NOP 2
        uut.Mem[7] = 32'h00000000; // NOP 3

        // --- STEP 3: PERFORM DIVISION ---
        // DIV R3, R1, R2 
        // Logic: 20 / 4 = 5
        // Opcode(DIV=000110) RS(1) RT(2) RD(3)
        // Hex: 18221800
        uut.Mem[8] = 32'h18221800;
        
        // --- HAZARD HANDLING FOR R3 ---
        // Wait for result to finish (optional here since we just HLT next)
        uut.Mem[9]  = 32'h00000000;
        uut.Mem[10] = 32'h00000000;
        uut.Mem[11] = 32'h00000000;

        // --- STEP 4: HALT ---
        uut.Mem[12] = 32'hFC000000; // HLT

        // Monitor
        $monitor("Time=%0t | PC=%d | ALU=%d | Op1=%d | Op2=%d", 
                 $time, pc_out, alu_result, debug_operand1, debug_operand2);

        // Run until halted
        wait(halted_out == 1);
        #20;
        
        $display("\n==================================================");
        $display("                 FINAL RESULTS                    ");
        $display("==================================================");
        
        $display("Dividend (R1): %0d", uut.Reg[1]);
        $display("Divisor  (R2): %0d", uut.Reg[2]);
        $display("Result   (R3): %0d (Expected 5)", uut.Reg[3]);
        
        if (uut.Reg[3] == 5) 
            $display("  >>> STATUS: PASS <<<");
        else 
            $display("  >>> STATUS: FAIL (Check NOPs/Timing) <<<");

        $display("==================================================");
        $stop;
    end
      
endmodule

