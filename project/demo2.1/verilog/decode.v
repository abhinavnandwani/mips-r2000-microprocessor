/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : decode.v
    Description     : This is the overall module for the decode stage of the processor. 
*/
`default_nettype none
module decode (
    // Clock and Reset
    input wire clk,
    input wire rst,

    // Instruction and Data Inputs
    input wire [15:0] instr,
    input wire [15:0] instr_comb,
    input wire [15:0] WB,
    input wire [15:0] PC,
    input wire NOP_mech,
    input wire IDF_err,
    input wire Done_DM,
    input wire Done_DM_ff,
    input wire [2:0] DMWB_RD,
    
    // Control Signals
    output wire nHaltSig,
    output wire MemRead,
    output wire ImmSrc,
    output wire nHaltSig_comb,
    output wire ALUSign,
    output wire ALUJmp,
    output wire MemWrt,
    output wire err,
    output wire RegWrt,
    output wire valid,

    // Register and Branch Controls
    output wire [1:0] RegSrc,
    output wire [1:0] BSrc,
    output wire [3:0] BranchTaken,

    // Outputs
    output wire [3:0] Oper,
    output wire [15:0] RSData,
    output wire [15:0] RTData,
    output wire [15:0] Imm5,
    output wire [15:0] Imm8,
    output wire [15:0] sImm8,
    output wire [15:0] sImm11,
    output wire [15:0] PC_Next,
    output wire invA,
    output wire invB,
    output wire Cin,
    output wire [2:0] RD,
    output wire NOP,
    output wire RegWrt_2_nflopped,
    output wire RegWrt_1_nflopped,
    output wire [2:0] RD_2_nflopped, 
    output wire [2:0] RD_1_nflopped,
    output wire DMWB_RegWrt,
    output wire NOP_Branch
    
);

    // Control Signals
    wire ZeroExt;
    wire RegWrt_nflopped;
    wire [5:0] ALUOpr;
    wire [1:0] RegDst;
    wire [2:0] RD_nflopped;
    wire MemRead_nflopped;
    wire ImmSrc_nflopped;
    wire ALUSign_nflopped;
    wire ALUJmp_nflopped;
    wire MemWrt_nflopped,nHaltSig_nflopped;
    wire reg_err, control_err;
    wire nHaltSig_control;


    wire rst_ff;
    dff dff_rst(.q(rst_ff), .d(rst), .clk(clk), .rst(1'b0));
   
    assign valid = rst_ff ? 1'b0 : 1'b1;

    assign NOP_Branch =  BranchTaken[3] | BranchTaken[2];


    // Register File
    assign RD = (RegDst == 2'b00) ? instr[7:5] :
                            (RegDst == 2'b01) ? instr[10:8] :
                            (RegDst == 2'b10) ? instr[4:2] :
                            3'b111;

    // Triple-flopped RD
    //dff dff_RD[8:0](.q({RD, RD_2_nflopped, RD_1_nflopped}), .d({~Done_DM_ff ? 3'b000:RD_2_nflopped, ~Done_DM ? RD_2_nflopped:RD_1_nflopped, RD_nflopped}), .clk({9{clk}}), .rst({9{rst}}));

    regFile_bypass regFile0 (.read1Data(RSData), .read2Data(RTData), .err(reg_err), .clk(clk), .rst(rst), .read1RegSel(instr[10:8]), .read2RegSel(instr[7:5]), .writeRegSel(DMWB_RD), .writeData(WB), .writeEn(DMWB_RegWrt));

    // Sign Extension
    assign Imm5 = (ZeroExt) ? {11'h000, instr[4:0]} : {{11{instr[4]}}, instr[4:0]};
    assign sImm8 = {{8{instr[7]}}, instr[7:0]};
    assign Imm8 = (ZeroExt) ? {8'h00, instr[7:0]} : sImm8;
    assign sImm11 = {{5{instr[10]}}, instr[10:0]};
    assign nHaltSig_comb = nHaltSig_nflopped;

    alu_control aluc (.aluoper(ALUOpr), .instr(instr[1:0]), .op(Oper), .invA(invA), .invB(invB), .Cin(Cin));

    //dff dff_d_RegWrt[2:0](.q({RegWrt, RegWrt_2_nflopped, RegWrt_1_nflopped}), .d({Done_DM_ff ? RegWrt_2_nflopped:1'b0,  Done_DM ? RegWrt_1_nflopped:RegWrt_2_nflopped, RegWrt_nflopped}), .clk({clk,clk,clk}), .rst({rst,rst,rst}));
    control control0 (.instr((NOP_mech) ? 16'b0000_1xxx_xxxx_xxxx : instr), .err(control_err), .NOP(NOP), .nHaltSig(nHaltSig), .MemRead(MemRead), .RegDst(RegDst), .RegWrt(RegWrt), .ZeroExt(ZeroExt), .BSrc(BSrc), .ImmSrc(ImmSrc), .ALUOpr(ALUOpr), .ALUSign(ALUSign), .ALUJmp(ALUJmp), .MemWrt(MemWrt), .RegSrc(RegSrc), .BranchTaken(BranchTaken));

    assign err = control_err | reg_err | IDF_err;
    // assign nHaltSig = nHaltSig_control | err;

     always @(posedge clk) begin
         $display("iNSTR : %h",instr);
     end
endmodule
`default_nettype wire