`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2025 18:39:48
// Design Name: 
// Module Name: tb_addition
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

module tb_addition;

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

    // Clock Generation (Two-phase non-overlapping clock)
    // clk1 handles IF, EX, WB
    // clk2 handles ID, MEM
    initial begin
        clk1 = 0;
        clk2 = 0;
        forever begin
            #5 clk1 = 1;  // Phase 1 High
            #5 clk1 = 0;  // Phase 1 Low
            #5 clk2 = 1;  // Phase 2 High
            #5 clk2 = 0;  // Phase 2 Low
        end
    end

initial begin
        // 1. Initialize Inputs
        $display("Starting Simulation...");
        
        // --- FIX 1: Write to Memory IMMEDIATELY (at Time 0) ---
        // Do not wait #10 here, or the CPU will fetch empty garbage first.
        
        // --- Instruction 1: ADDI R1, R0, 10 ---
        // Hex: 2801000A
        uut.Mem[0] = 32'h2801000A;

        // --- 3 NOPs (Bubbles) to ensure R1 is written ---
        // We need 3 slots to bridge the gap between ID (Stage 2) and WB (Stage 5)
        uut.Mem[1] = 32'h00000000;
        uut.Mem[2] = 32'h00000000; 
        uut.Mem[3] = 32'h00000000; 

        // --- Instruction 2: ADDI R2, R0, 20 ---
        // Hex: 28020014
        uut.Mem[4] = 32'h28020014;

        // --- FIX 2: 3 NOPs (Bubbles) for R2 safety ---
        uut.Mem[5] = 32'h00000000;
        uut.Mem[6] = 32'h00000000;
        uut.Mem[7] = 32'h00000000;

        // --- Instruction 3: ADD R3, R1, R2 ---
        // Hex: 00221800
        uut.Mem[8] = 32'h00221800;

        // --- Finishing NOPs and HALT ---
        uut.Mem[9]  = 32'h00000000;
        uut.Mem[10] = 32'h00000000;
        uut.Mem[11] = 32'h00000000;
        uut.Mem[12] = 32'hFC000000; // HLT

        // Monitor execution
        $monitor("Time=%0t | PC=%d | ALU=%d | Op1=%d | Op2=%d | Halted=%b", 
                 $time, pc_out, alu_result, debug_operand1, debug_operand2, halted_out);

        // Run until halted
        wait(halted_out == 1);
        #20;
        
        // Optional: Print final register values to console to verify
        $display("--------------------------------------------------");
        $display("Final Check:");
        $display("Reg[1] (Should be 10): %d", uut.Reg[1]);
        $display("Reg[2] (Should be 20): %d", uut.Reg[2]);
        $display("Reg[3] (Should be 30): %d", uut.Reg[3]);
        $display("--------------------------------------------------");
        
        $stop;
    end
 endmodule