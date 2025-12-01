`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2025 01:52:21
// Design Name: 
// Module Name: tb_memory
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

module tb_memory;

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
        $display("       STARTING MEMORY TEST (LW & SW)             ");
        $display("==================================================");

        // 1. ADDI R1, R0, 100 (Set Address Pointer)
        // Hex: 28010064 (Decimal 100)
        uut.Mem[0] = 32'h28010064;

        // --- NOP Bubbles ---
        uut.Mem[1] = 0; uut.Mem[2] = 0; uut.Mem[3] = 0; 

        // 2. ADDI R2, R0, 5555 (Set Data to Store)
        // Hex: 280215B3 (Decimal 5555)
        uut.Mem[4] = 32'h280215B3;

        // --- NOP Bubbles ---
        uut.Mem[5] = 0; uut.Mem[6] = 0; uut.Mem[7] = 0;

        // 3. SW R2, 0(R1)  -> Store R2 into Mem[R1 + 0]
        // Opcode(SW=001001) RS(1) RT(2) Imm(0)
        // Hex: 24220000
        uut.Mem[8] = 32'h24220000;
        
        // --- NOP Bubbles (Wait for Store to complete) ---
        uut.Mem[9] = 0; uut.Mem[10] = 0; uut.Mem[11] = 0;

        // 4. LW R3, 0(R1)  -> Load Mem[R1 + 0] into R3
        // Opcode(LW=001000) RS(1) RT(3) Imm(0)
        // Hex: 20230000
        uut.Mem[12] = 32'h20230000;

        // --- Finishing NOPs and HALT ---
        uut.Mem[13] = 0; uut.Mem[14] = 0; uut.Mem[15] = 0;
        // 5. HLT
        uut.Mem[16] = 32'hFC000000; 

        // Run until halted
        wait(halted_out == 1);
        #20; // Wait for WB stage to finish
        
        $display("\n==================================================");
        $display("                 FINAL RESULTS                    ");
        $display("==================================================");
        
        // Verify Store (Check Internal Memory)
        $display("CHECK 1: STORE WORD (SW)");
        $display("  Target Address: Mem[100]");
        $display("  Expected Value: 5555");
        $display("  Actual Value:   %0d", uut.Mem[100]);
        
        if (uut.Mem[100] == 5555) 
            $display("  >>> STORE STATUS: PASS <<<");
        else 
            $display("  >>> STORE STATUS: FAIL <<<");

        // Verify Load (Check Destination Register)
        $display("\nCHECK 2: LOAD WORD (LW)");
        $display("  Destination:    Reg[3]");
        $display("  Expected Value: 5555");
        $display("  Actual Value:   %0d", uut.Reg[3]);

        if (uut.Reg[3] == 5555) 
            $display("  >>> LOAD STATUS:  PASS <<<");
        else 
            $display("  >>> LOAD STATUS:  FAIL <<<");

        $display("==================================================");
        $stop;
    end
      
endmodule
