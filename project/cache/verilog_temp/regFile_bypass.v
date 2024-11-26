/*
   CS/ECE 552, Fall '22
   Homework #3, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module regFile_bypass (
                       // Outputs
                       read1Data, read2Data, err,
                       // Inputs
                       clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                       );
   input        clk, rst;
   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;

   output [15:0] read1Data;
   output [15:0] read2Data;
   output        err;

   /* YOUR CODE HERE */
   wire [15:0] internal_read1Data; // Internal read data 1
   wire [15:0] internal_read2Data; // Internal read data 2

   // Instantiate the original register file
   regFile rf (
      .read1Data(internal_read1Data),
      .read2Data(internal_read2Data),
      .err(err),
      .clk(clk),
      .rst(rst),
      .read1RegSel(read1RegSel),
      .read2RegSel(read2RegSel),
      .writeRegSel(writeRegSel),
      .writeData(writeData),
      .writeEn(writeEn)
   );

   // Bypass logic using conditional operators

   assign read1Data = (writeEn & (writeRegSel == read1RegSel)) ? writeData : internal_read1Data; // Bypass for read1Data
   assign read2Data = (writeEn & (writeRegSel == read2RegSel)) ? writeData : internal_read2Data; // Bypass for read2Data

endmodule
