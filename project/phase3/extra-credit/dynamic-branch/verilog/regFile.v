 /*
   CS/ECE 552, Fall '22
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile (read1Data, read2Data, err, clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn);

   
   parameter BIT_WIDTH = 16;
	parameter BIT_SIZE = 3;
	parameter REG_NUMS = 8;
   
   input clk, rst;
   input [BIT_SIZE-1:0]  read1RegSel;
   input [BIT_SIZE-1:0]  read2RegSel;
   input [BIT_SIZE-1:0]  writeRegSel;
   input [BIT_WIDTH-1:0] writeData;
   input        writeEn;

   output [BIT_WIDTH-1:0] read1Data;
   output [BIT_WIDTH-1:0] read2Data;
   output        err;

   /* YOUR CODE HERE */
   
   wire [BIT_WIDTH-1:0] r0,r1,r2,r3,r4,r5,r6,r7;
   wire [15:0] we;
   
   shifter s1(.In({15'b000000000000000,writeEn}), .ShAmt({1'b0,writeRegSel}), .Oper(2'b01), .Out(we));
   //assign we = (writeEn) ? (1 << writeRegSel) : 0;
   
   register registers [REG_NUMS-1:0](.r({r7,r6,r5,r4,r3,r2,r1,r0}),.w(writeData),.we(we[7:0]),.clk(clk),.rst(rst));
   
   assign read1Data =    (read1RegSel == 3'b000) ? r0 :
                        (read1RegSel == 3'b001) ? r1 :
                        (read1RegSel == 3'b010) ? r2 :
                        (read1RegSel == 3'b011) ? r3 :
                        (read1RegSel == 3'b100) ? r4 :
                        (read1RegSel == 3'b101) ? r5 :
                        (read1RegSel == 3'b110) ? r6 :
                        (read1RegSel == 3'b111) ? r7 : r0;

   assign read2Data =    (read2RegSel == 3'b000) ? r0 :
                        (read2RegSel == 3'b001) ? r1 :
                        (read2RegSel == 3'b010) ? r2 :
                        (read2RegSel == 3'b011) ? r3 :
                        (read2RegSel == 3'b100) ? r4 :
                        (read2RegSel == 3'b101) ? r5 :
                        (read2RegSel == 3'b110) ? r6 :
                        (read2RegSel == 3'b111) ? r7 : r0;


   assign err = (writeEn == 1'bx) ? 1'b1 : (writeData == 16'bx) ? 1'b1 : 1'b0;
   
   
   

endmodule
