module forwarding(

    input wire [15:0] EXDM_ALU,
    input wire [15:0] EXDM_PC,
    input wire [15:0] DMWB_PC,
    input wire [15:0] DMWB_ALU,
    input wire [15:0] DMWB_readData,
    input wire [1:0] DMWB_RegSrc,
    input wire [1:0] EXDM_RegSrc,
    input wire [15:0] EXDM_RTData,
    output [1:0] A_Sel,
    output [1:0] B_Sel,
    output wire [15:0] EXDM_RD_Data,
    output wire [15:0] DMWB_RD_Data,
    input wire takeRs_EXDM,
    input wire takeRt_EXDM,
    input wire takeRs_DMWB,
    input wire takeRt_DMWB

);

    // Data logic
    assign EXDM_RD_Data = (EXDM_RegSrc == 2'b00) ? EXDM_PC : 
                          (EXDM_RegSrc == 2'b10) ? EXDM_ALU : 16'h0000;

    assign DMWB_RD_Data = (DMWB_RegSrc == 2'b00) ? DMWB_PC : 
                          (DMWB_RegSrc == 2'b10) ? DMWB_ALU : 
                          (DMWB_RegSrc == 2'b01) ? DMWB_readData : 16'h0000;

    // Selection logic
    assign A_Sel = takeRs_EXDM ? 2'b01 :
                   takeRs_DMWB ? 2'b10 :
                   2'b00;

    assign B_Sel = takeRt_EXDM ? 2'b01 :
                   takeRt_DMWB ? 2'b10 :
                   2'b00;
    
    always@(*)
        $display("EXDM_RTData : %h EXDM_RD_Data : %h DMWB_RD_Data : %h A_Sel : %h B_Sel : %h",EXDM_RTData,EXDM_RD_Data,DMWB_RD_Data,A_Sel,B_Sel);


endmodule