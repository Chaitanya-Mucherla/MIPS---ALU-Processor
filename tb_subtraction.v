`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2025 21:23:53
// Design Name: 
// Module Name: tb_subtraction
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



module tb_subtraction;

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
        // Initialize Inputs
        $display("Starting Subtraction Simulation...");

        // --- PIPELINE SAFE PROGRAM (With NOPs) ---
        // Writing immediately at Time 0 to avoid startup race conditions
        
        // 1. ADDI R1, R0, 50 (Hex: 28010032)
        // Opcode(ADDI=001010) RS(0) RT(1) Imm(50=0x32)
        uut.Mem[0] = 32'h28010032;

        // --- 3 NOPs to ensure R1 is written ---
        uut.Mem[1] = 32'h00000000;
        uut.Mem[2] = 32'h00000000; 
        uut.Mem[3] = 32'h00000000; 

        // 2. ADDI R2, R0, 20 (Hex: 28020014)
        // Opcode(ADDI=001010) RS(0) RT(2) Imm(20=0x14)
        uut.Mem[4] = 32'h28020014;

        // --- 3 NOPs to ensure R2 is written ---
        uut.Mem[5] = 32'h00000000;
        uut.Mem[6] = 32'h00000000;
        uut.Mem[7] = 32'h00000000;

        // 3. SUB R3, R1, R2 (Hex: 04221800)
        // Opcode(SUB=000001) RS(1) RT(2) RD(3)
        // Binary: 000001 00001 00010 00011 ...
        uut.Mem[8] = 32'h04221800;

        // --- Finishing NOPs and HALT ---
        uut.Mem[9]  = 32'h00000000;
        uut.Mem[10] = 32'h00000000;
        uut.Mem[11] = 32'h00000000;
        // 4. HLT (Hex: FC000000)
        uut.Mem[12] = 32'hFC000000;

        // Monitor execution
        $monitor("Time=%0t | PC=%d | ALU=%d | Op1=%d | Op2=%d | Halted=%b", 
                 $time, pc_out, alu_result, debug_operand1, debug_operand2, halted_out);

        // Run until halted
        wait(halted_out == 1);
        #20;
        
        $display("--------------------------------------------------");
        $display("Final Subtraction Check (50 - 20 = 30):");
        $display("Reg[1] (Should be 50): %d", uut.Reg[1]);
        $display("Reg[2] (Should be 20): %d", uut.Reg[2]);
        $display("Reg[3] (Should be 30): %d", uut.Reg[3]);
        
        if (uut.Reg[3] == 30)
            $display("SUCCESS: Subtraction worked correctly.");
        else
            $display("FAILURE: Subtraction result incorrect.");
        $display("--------------------------------------------------");
        
        $stop;
    end
      
endmodule
