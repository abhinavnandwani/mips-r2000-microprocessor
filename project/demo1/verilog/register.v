module register

		#( parameter BIT_WIDTH = 16,
					 BIT_SIZE = 3,
					 REG_NUMS = 8
		)
		(r,w,clk,rst,we
		);
		


input clk,rst,we;
input [BIT_WIDTH-1:0] w;
output [BIT_WIDTH-1:0] r;

dff dff01[BIT_WIDTH-1:0](.q(r), .d( we ? w:r), .clk(clk),.rst(rst));

endmodule