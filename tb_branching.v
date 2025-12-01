`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2025 01:41:16
// Design Name: 
// Module Name: tb_branching
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

module tb_branching;

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
        $display("          STARTING BRANCH (BEQZ) TEST             ");
        $display("==================================================");

        // 1. ADDI R1, R0, 0 
        // Hex: 28010000 | Set Condition Flag (R1=0)
        uut.Mem[0] = 32'h28010000;

        // --- NOP Bubbles (Wait for R1 write) ---
        uut.Mem[1] = 0; uut.Mem[2] = 0; uut.Mem[3] = 0; 

        // 2. BEQZ R1, 2 (Offset = 2)
        // Opcode(BEQZ=001110) RS(1) ... Imm(2)
        // We want to skip the next 2 instructions.
        // Target Calculation in RTL: PC_new = (Current_PC + 1) + Imm
        // Hex: 38200002
        uut.Mem[4] = 32'h38200002;

        // --- NOP Bubbles (Required for Branch decision to propagate) ---
        // The branch happens in EX stage, so instructions already in IF/ID might get flushed or NOP'd.
        // In this simple model without flushing, we manually space them.
        uut.Mem[5] = 0; uut.Mem[6] = 0; uut.Mem[7] = 0;

        // 3. THIS SHOULD BE SKIPPED: ADDI R2, R0, 77
        // Hex: 2802004D
        uut.Mem[8] = 32'h2802004D;
        // Padding NOPs for the skipped instruction
        uut.Mem[9] = 0; uut.Mem[10] = 0;

        // 4. THIS SHOULD BE SKIPPED: ADDI R3, R0, 88
        // Hex: 28030058
        uut.Mem[11] = 32'h28030058;
        // Padding NOPs
        uut.Mem[12] = 0; uut.Mem[13] = 0;

        // --- TARGET OF JUMP (Address 14) ---
        // Note: In your RTL logic: PC <= ID_EX_NPC (Addr 5) + Imm (2) = 7? 
        // Wait, let's verify RTL logic:
        // IF_ID_NPC is PC+1.
        // If PC is 4 (where BEQZ is), NPC is 5.
        // Target = 5 + 2 = 7. 
        // So we need to put the valid instruction at Mem[7] + NOP delays.
        // Actually, since we put NOP bubbles *inside* the memory manually, 
        // the "logical" instruction count and "physical" memory address differ.
        
        // Let's adjust for the Bubbles in Mem:
        // The BEQZ is at Mem[4].
        // If we want to skip instructions, we need a larger offset because of the NOPs we inserted manually.
        // Let's try a larger offset to jump over the "Trap" instructions at Mem[8]...Mem[13].
        // Jump from Mem[4]. Next logical is Mem[5]. We need to land at Mem[14].
        // Offset needed = 14 - 5 = 9.
        
        // RE-WRITE INSTRUCTION 2: BEQZ R1, 9
        // Hex: 38200009
        uut.Mem[4] = 32'h38200009;

        // 5. TARGET: ADDI R4, R0, 99
        // This is at Mem[14].
        // Hex: 28040063
        uut.Mem[14] = 32'h28040063;

        // --- Finishing NOPs and HALT ---
        uut.Mem[15] = 0; uut.Mem[16] = 0; uut.Mem[17] = 0;
        uut.Mem[18] = 32'hFC000000; // HLT

        // Run until halted
        wait(halted_out == 1);
        #20;

        $display("\n==================================================");
        $display("               BRANCH RESULTS                     ");
        $display("==================================================");
        
        $display("Condition: R1 = %0d (Should be 0)", uut.Reg[1]);
        
        $display("\nCheck Skipped Instructions:");
        $display("  R2 (Should be 0 - Skipped): %0d", uut.Reg[2]);
        $display("  R3 (Should be 0 - Skipped): %0d", uut.Reg[3]);

        if (uut.Reg[2] == 0 && uut.Reg[3] == 0)
            $display("  >>> SKIP STATUS: PASS (R2/R3 not modified) <<<");
        else
            $display("  >>> SKIP STATUS: FAIL (Code executed linearly) <<<");

        $display("\nCheck Target Instruction:");
        $display("  R4 (Should be 99 - Executed): %0d", uut.Reg[4]);
        
        if (uut.Reg[4] == 99)
            $display("  >>> JUMP STATUS: PASS <<<");
        else
            $display("  >>> JUMP STATUS: FAIL <<<");

        $display("==================================================");
        $stop;
    end
      
endmodule