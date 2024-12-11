/*
   CS/ECE 552, Spring '20
   Homework #3, Problem #1
  
   This module creates a 16-bit register
*/
module reg_16 (
                // Outputs
                readData, err,
                // Inputs
                clk, rst, writeData, writeEn
                );
   
   parameter SIZE = 16;
   
   input         clk, rst, writeEn;
   input[SIZE-1:0]  writeData;

   output         err;
   output [SIZE-1:0] readData;

   /* YOUR CODE HERE */
   wire[SIZE-1:0] in;
   assign in = (writeEn) ? writeData : readData;

   dff ff[SIZE-1:0](.q(readData) ,.d(in), .clk(clk), .rst(rst));   
   
   assign err = 1'b0;

endmodule
