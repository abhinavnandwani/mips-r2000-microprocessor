module register(r,w,clk,rst,we);

// Parameters
parameter BIT_WIDTH = 16;   // Width of each register in bits
parameter BIT_SIZE = 3;      // Number of bits to address the registers
parameter REG_NUMS = 8;       // Total number of registers


input clk,rst,we;
input [BIT_WIDTH-1:0] w;
output [BIT_WIDTH-1:0] r;

dff dff01[BIT_WIDTH-1:0](.q(r), .d( we ? w:r), .clk(clk),.rst(rst));

endmodule