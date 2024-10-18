`default_nettype none
module brchcnd (SF, ZF, brch_instr, BrchCnd);
   input SF, ZF;
   input [2:0] brch_instr;
   output BrchCnd;

   wire brch_sig;

   always @(*) begin
      case (brch_instr[1:0])
         2'b00: brch_sig = ZF;             // BEQZ
         2'b01: brch_sig = ~ZF;            // BNEZ
         2'b10: brch_sig = SF;              // BLTZ
         2'b11: brch_sig = ~SF;             // BGEZ
         default: brch_sig = 1'b0;          // Default to no branch
      endcase
   end

   assign BrchCnd = (brch_instr[2]) ? brch_sig : 1'b0;

endmodule
`default_nettype wire
