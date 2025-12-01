`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2025 18:08:38
// Design Name: 
// Module Name: pipe_MIPS20
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


module pipe_MIPS20(
    input  wire clk1,
    input  wire clk2,
    
    // OUTPUTS (Visible in Waveform & Netlist)
    output wire [31:0] pc_out,
    output wire [31:0] alu_result,
    output wire        halted_out,
    
    // NEW: DEBUG OUTPUTS FOR INPUT OPERANDS
    output wire [31:0] debug_operand1,
    output wire [31:0] debug_operand2
);

    // ---------- Pipeline Registers ----------
    reg [31:0] PC;
    reg [31:0] IF_ID_IR, IF_ID_NPC;
    reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
    reg [2:0]  ID_EX_type, EX_MEM_type, MEM_WB_type;
    reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
    reg        EX_MEM_cond;
    reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;

    // Register Bank (20x32) & Memory
    reg [31:0] Reg [0:19];   
    reg [31:0] Mem [0:1023]; 
    
    // Flags
    reg HALTED;        
    reg TAKEN_BRANCH;  

    // ---------- OUTPUT CONNECTIONS ----------
    assign pc_out     = PC;
    assign alu_result = EX_MEM_ALUOut;
    assign halted_out = HALTED;

    // LOGIC TO SHOW WHAT IS ENTERING THE ALU
    // Operand 1 is always A
    assign debug_operand1 = ID_EX_A; 
    
    // Operand 2 depends on type: 
    // If RR_ALU (like ADD), use Register B. Otherwise (ADDI, LW, STORE), use Immediate.
    assign debug_operand2 = (ID_EX_type == 3'b000) ? ID_EX_B : ID_EX_Imm;

    // ---------- OPCODES ----------
    parameter ADD    = 6'b000000, SUB    = 6'b000001, AND_OP = 6'b000010,
              OR_OP  = 6'b000011, SLT    = 6'b000100, MUL    = 6'b000101,
              HLT    = 6'b111111, LW     = 6'b001000, SW     = 6'b001001,
              ADDI   = 6'b001010, SUBI   = 6'b001011, SLTI   = 6'b001100,
              BNEQZ  = 6'b001101, BEQZ   = 6'b001110;

    parameter RR_ALU = 3'b000, RM_ALU = 3'b001, LOAD   = 3'b010,
              STORE  = 3'b011, BRANCH = 3'b100, HALT_T = 3'b101, NOP_T  = 3'b110;


    // Helper wires
    wire [5:0] opcode = IF_ID_IR[31:26];
    wire [4:0] rs     = IF_ID_IR[25:21];
    wire [4:0] rt     = IF_ID_IR[20:16];
    wire [4:0] rd     = IF_ID_IR[15:11];

    integer i;

    // ---------- Initialization ----------
    initial begin
        PC = 0; HALTED = 0; TAKEN_BRANCH = 0;
        IF_ID_IR = 0; IF_ID_NPC = 0; ID_EX_IR = 0; ID_EX_NPC = 0;
        EX_MEM_IR = 0; MEM_WB_IR = 0;
        for (i=0; i<20; i=i+1) Reg[i]=0;
        for (i=0; i<1024; i=i+1) Mem[i]=0;
    end

    // ---------- IF Stage ----------
    always @(posedge clk1) begin
        if (!HALTED) begin
            if ((EX_MEM_IR[31:26] == BEQZ && EX_MEM_cond == 1) ||
                (EX_MEM_IR[31:26] == BNEQZ && EX_MEM_cond == 1)) begin
                IF_ID_IR  <= Mem[EX_MEM_ALUOut];
                IF_ID_NPC <= EX_MEM_ALUOut + 1;
                PC        <= EX_MEM_ALUOut + 1;
                TAKEN_BRANCH <= 1;
            end else begin
                IF_ID_IR  <= Mem[PC];
                IF_ID_NPC <= PC + 1;
                PC        <= PC + 1;
            end
        end
    end

    // ---------- ID Stage ----------
    always @(posedge clk2) begin
        if (!HALTED) begin
            ID_EX_Imm <= {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]};
            
            if (rs == 0) ID_EX_A <= 0;
            else if (rs < 20) ID_EX_A <= Reg[rs];
            else ID_EX_A <= 0;

            if (rt == 0) ID_EX_B <= 0;
            else if (rt < 20) ID_EX_B <= Reg[rt];
            else ID_EX_B <= 0;

            ID_EX_NPC <= IF_ID_NPC;
            ID_EX_IR  <= IF_ID_IR;

            case (opcode)
                ADD, SUB, AND_OP, OR_OP, SLT, MUL: ID_EX_type <= RR_ALU;
                ADDI, SUBI, SLTI:                  ID_EX_type <= RM_ALU;
                LW:                                ID_EX_type <= LOAD;
                SW:                                ID_EX_type <= STORE;
                BNEQZ, BEQZ:                       ID_EX_type <= BRANCH;
                HLT:                               ID_EX_type <= HALT_T;
                default:                           ID_EX_type <= NOP_T;
            endcase
        end
    end

    // ---------- EX Stage ----------
    always @(posedge clk1) begin
        if (!HALTED) begin
            EX_MEM_type <= ID_EX_type;
            EX_MEM_IR   <= ID_EX_IR;
            TAKEN_BRANCH <= 0;
            EX_MEM_ALUOut <= 0; EX_MEM_B <= ID_EX_B; EX_MEM_cond <= 0;

            case (ID_EX_type)
                RR_ALU: begin
                    case (ID_EX_IR[31:26])
                        ADD:    EX_MEM_ALUOut <= ID_EX_A + ID_EX_B;
                        SUB:    EX_MEM_ALUOut <= ID_EX_A - ID_EX_B;
                        AND_OP: EX_MEM_ALUOut <= ID_EX_A & ID_EX_B;
                        OR_OP:  EX_MEM_ALUOut <= ID_EX_A | ID_EX_B;
                        SLT:    EX_MEM_ALUOut <= (ID_EX_A < ID_EX_B) ? 1 : 0;
                        MUL:    EX_MEM_ALUOut <= ID_EX_A * ID_EX_B;
                    endcase
                end
                RM_ALU: begin
                    case (ID_EX_IR[31:26])
                        ADDI: EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
                        SUBI: EX_MEM_ALUOut <= ID_EX_A - ID_EX_Imm;
                        SLTI: EX_MEM_ALUOut <= (ID_EX_A < ID_EX_Imm) ? 1 : 0;
                    endcase
                end
                LOAD, STORE: EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
                BRANCH: begin
                    EX_MEM_ALUOut <= ID_EX_NPC + ID_EX_Imm;
                    if (ID_EX_IR[31:26] == BEQZ) EX_MEM_cond <= (ID_EX_A == 0);
                    else if (ID_EX_IR[31:26] == BNEQZ) EX_MEM_cond <= (ID_EX_A != 0);
                    
                    if ((ID_EX_IR[31:26] == BEQZ && ID_EX_A == 0) || 
                        (ID_EX_IR[31:26] == BNEQZ && ID_EX_A != 0)) begin
                         PC <= ID_EX_NPC + ID_EX_Imm;
                         TAKEN_BRANCH <= 1;
                    end
                end
            endcase
        end
    end

    // ---------- MEM Stage ----------
    always @(posedge clk2) begin
        if (!HALTED) begin
            MEM_WB_type <= EX_MEM_type;
            MEM_WB_IR   <= EX_MEM_IR;
            MEM_WB_ALUOut <= EX_MEM_ALUOut;
            MEM_WB_LMD <= 0;
            case (EX_MEM_type)
                LOAD:  MEM_WB_LMD <= Mem[EX_MEM_ALUOut];
                STORE: if (!TAKEN_BRANCH) Mem[EX_MEM_ALUOut] <= EX_MEM_B;
            endcase
        end
    end

    // ---------- WB Stage ----------
    always @(posedge clk1) begin
        if (!HALTED && !TAKEN_BRANCH) begin
            case (MEM_WB_type)
                RR_ALU: if (MEM_WB_IR[15:11] < 20) Reg[MEM_WB_IR[15:11]] <= MEM_WB_ALUOut;
                RM_ALU: if (MEM_WB_IR[20:16] < 20) Reg[MEM_WB_IR[20:16]] <= MEM_WB_ALUOut;
                LOAD:   if (MEM_WB_IR[20:16] < 20) Reg[MEM_WB_IR[20:16]] <= MEM_WB_LMD;
                HALT_T: HALTED <= 1;
            endcase
        end
    end
endmodule
