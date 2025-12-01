`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2025 20:28:14
// Design Name: 
// Module Name: tb_mul
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

module tb_mul;

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
            #5 clk1 = 1; 
            #5 clk1 = 0;
            #5 clk2 = 1; 
            #5 clk2 = 0;
        end
    end

    initial begin
        $display("Starting Multiplication Simulation...");

        // --- PIPELINE SAFE PROGRAM ---
        
        // 1. ADDI R1, R0, 10 (Hex: 2801000A)
        // Puts 10 in R1
        uut.Mem[0] = 32'h2801000A;

        // --- 3 NOPs for Hazard Avoidance ---
        uut.Mem[1] = 32'h00000000;
        uut.Mem[2] = 32'h00000000; 
        uut.Mem[3] = 32'h00000000; 

        // 2. ADDI R2, R0, 5 (Hex: 28020005)
        // Puts 5 in R2
        uut.Mem[4] = 32'h28020005;

        // --- 3 NOPs for Hazard Avoidance ---
        uut.Mem[5] = 32'h00000000;
        uut.Mem[6] = 32'h00000000;
        uut.Mem[7] = 32'h00000000;

        // 3. MUL R3, R1, R2 (Hex: 14221800)
        // Opcode(MUL=000101) RS(1) RT(2) RD(3)
        // Binary: 000101 00001 00010 00011 000...
        // Hex: 14221800
        uut.Mem[8] = 32'h14221800;

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
        $display("Final Multiplication Check (10 * 5 = 50):");
        $display("Reg[1] (Input A): %d", uut.Reg[1]);
        $display("Reg[2] (Input B): %d", uut.Reg[2]);
        $display("Reg[3] (Result):  %d", uut.Reg[3]);
        
        // Note: 50 in Hex is 32
        if (uut.Reg[3] == 50)
            $display("SUCCESS: Multiplication worked correctly.");
        else
            $display("FAILURE: Expected 50, got %d", uut.Reg[3]);
        $display("--------------------------------------------------");
        
        $stop;
    end
      
endmodule
