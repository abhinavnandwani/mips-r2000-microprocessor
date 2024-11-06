module stall_mech(
    output reg NOP_reg,
    input reg [2:0] RSData,
    input reg [2:0] RTData,
    input reg [2:0] RD_ff,
    input reg [2:0] RD_2ff,
    input reg [2:0] RD_3ff,
    input wire RegWrt_2ff,
    input wire RegWrt_ff,
    input wire RegWrt_3ff

);

    always@(*) begin

        case (RSData)
            RD_ff : NOP_reg = RegWrt_ff;
            RD_2ff : NOP_reg = RegWrt_2ff;
            default :  case (RTData) 
                        RD_ff : NOP_reg = RegWrt_ff;
                        RD_2ff : NOP_reg = RegWrt_2ff;
                        default : NOP_reg = 1'b0;
                        endcase
        endcase

    end




endmodule