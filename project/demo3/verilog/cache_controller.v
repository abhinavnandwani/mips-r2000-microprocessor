module cache_controller(
	// Input from system
	clk,rst,creat_dump,
	// Input from mem
	Addr,DataIn,Rd,Wr,Hit,victimway_in, Data_latch,
	// Input from cache0
	hit_0,dirty_0,tag_out_0,DataOut_cache_0,valid_0,
	// Input from cache1
	hit_1,dirty_1,tag_out_1,DataOut_cache_1,valid_1,
    // Input from the whole cache
    tag_out, DataOut_cache,
	// Input from four bank
	DataOut_mem,
	// Output to cache
	enable_ct,index_cache,
	offset_cache,cmp_ct,
	wr_cache,tag_cache,
	DataIn_ct,valid_in_ct,
	// Output to fourbank
	Addr_mem,DataIn_mem,
	wr_mem,rd_mem,
	// Output to system
	Done,CacheHit,Stall_sys,victimway_out,ori, final_state, DataOut_ct, idle
);

// Input, output
input clk, rst, creat_dump, Wr, Rd, hit_0, hit_1, dirty_0, dirty_1, valid_0, valid_1, Hit;
input [15:0] Addr, DataIn, DataOut_mem, DataOut_cache_0, DataOut_cache_1, DataOut_cache, Data_latch; // FIXME add tag_out and DataOut_cache
input [4:0] tag_out_0, tag_out_1, tag_out;
input [255:0] victimway_in;

output reg enable_ct, cmp_ct, wr_cache, valid_in_ct, wr_mem, rd_mem, Done, CacheHit, Stall_sys, ori, final_state, idle;
output reg[15:0] DataIn_ct, Addr_mem, DataIn_mem, DataOut_ct;
output reg[7:0] index_cache;
output reg[2:0] offset_cache;
output reg[4:0] tag_cache;
output reg[255:0] victimway_out;


// define states
localparam IDLE = 4'b0000;
// localparam HIT = 4'b0001;
// localparam CMP_RD_0 = 4'b0010;
// localparam CMP_WT_0 = 4'b0011;
localparam ACC_RD_0 = 4'b0100;
localparam ACC_RD_1 = 4'b0101;
localparam ACC_RD_2 = 4'b0110;
localparam ACC_RD_3 = 4'b0111;
localparam ACC_WT_0 = 4'b1000;
localparam ACC_WT_1 = 4'b1001;
localparam ACC_WT_2 = 4'b1010;
localparam ACC_WT_3 = 4'b1011;
localparam ACC_WT_4 = 4'b1100;
localparam ACC_WT_5 = 4'b1101;
// localparam CMP_WT_1 = 4'b1110;
// localparam CMP_RD_1 = 4'b1111;

// ff for state machine
wire err_reg;
reg valid_req;
wire [3:0] state, state_q;
reg [3:0] next_state;
reg_16 #(.SIZE(4)) state_fsm(.readData(state_q), .err(err_reg), .clk(clk), .rst(rst), .writeData(next_state), .writeEn(1'b1));
assign state = rst ? IDLE : state_q;

reg enable_ct_d, enable_ct_en; // FIXME change enable_ct_q to wire
wire enable_ct_q;
reg_16 #(.SIZE(1)) latch_enable(.readData(enable_ct_q), .err(err_reg), .clk(clk), .rst(rst), .writeData(enable_ct_d), .writeEn(enable_ct_en));

wire isWr_q;
reg isWr;
reg_16 #(.SIZE(1)) Wr_track(.readData(isWr_q), .err(err_reg), .clk(clk), .rst(rst), .writeData(isWr), .writeEn(1'b1));

wire isRd_q;
reg isRd;
reg_16 #(.SIZE(1)) Rd_track(.readData(isRd_q), .err(err_reg), .clk(clk), .rst(rst), .writeData(isRd), .writeEn(1'b1));

// reg LRU_update;

reg err_fsm;
// FSM
always @* 
	begin
		enable_ct = 1'b0;
		index_cache = 8'bxxxx_xxxx;
		offset_cache = 3'bxxx;
		cmp_ct = 1'b0;
		wr_cache = 1'b0;
		tag_cache = 5'bxxxx_x;
		DataIn_ct = 16'bxxxx_xxxx_xxxx_xxxx;
		valid_in_ct = 1'b0;
		Addr_mem = 16'bxxxx_xxxx_xxxx_xxxx;
		DataIn_mem = 16'bxxxx_xxxx_xxxx_xxxx; 
		wr_mem = 1'b0;
		rd_mem = 1'b0;
		Done = 1'b0;
		CacheHit = 1'b0;
		Stall_sys = 1'b1;
		err_fsm = 1'b0;
		ori = 1'b0;
		idle = 1'b0;
		victimway_out = victimway_in;
		enable_ct_en = 1'b0;
		enable_ct_d = 1'b0;
		final_state = 1'b0;
		valid_req = 1'b0;
		// LRU_update = 256'b0;

		case(state)
			default: err_fsm = 1'b1;
			IDLE:
				begin
					enable_ct = (Wr|Rd) ? ((hit_0 & valid_0) | (~Hit & ~valid_0 & valid_1) | (~Hit & ~valid_0 & ~valid_1) | (~Hit & valid_1 & valid_0 & victimway_in[Addr[10:3]])) : 1'b0;
					cmp_ct = (Wr|Rd) ? 1'b1 : 1'b0;
					wr_cache = Wr ? 1'b1 : 1'b0;
					index_cache = Addr[10:3];
					offset_cache = (Wr|Rd) ? Addr[2:0] : 3'b000;
					tag_cache = Addr[15:11];
					DataIn_ct = DataIn;
					DataOut_ct = DataOut_cache;
					ori = (Wr|Rd) ? 1'b1 : 1'b0;
					idle = (~Wr) & (~Rd); 
					isWr = Wr ? 1'b1 : 1'b0;
					isRd = Rd ? 1'b1 : 1'b0;
					enable_ct_d = (hit_0 & valid_0) | (~Hit & ~valid_0 & valid_1) | (~Hit & ~valid_0 & ~valid_1) | (~Hit & valid_1 & valid_0 & victimway_in[Addr[10:3]]);
					enable_ct_en = (Wr|Rd) ? 1'b1 : 1'b0;
					Done = Hit;
                    CacheHit = Hit;
                    final_state = Hit;
					Stall_sys = (Wr|Rd) ? ~Hit : 1'b0;
					next_state = (Wr|Rd) ? (Hit ? IDLE : ((((~Hit)&(enable_ct)&(valid_0)&(dirty_0))|(((~Hit)&(!enable_ct)&(valid_1)&(dirty_1)))) ? (ACC_RD_0) : (ACC_WT_0))) : IDLE;
					valid_req = (Wr|Rd) ? (Hit ? 1'b1 : ((((~Hit)&(enable_ct)&(valid_0)&(dirty_0))|(((~Hit)&(!enable_ct)&(valid_1)&(dirty_1)))) ? (1'b1) : (1'b1))) : 1'b0;
                    victimway_out[Addr[10:3]] = (Wr|Rd) ? ~enable_ct : victimway_in[Addr[10:3]];
				end
			ACC_RD_0:
				begin
					enable_ct = enable_ct_q;
					index_cache = Addr[10:3];
					offset_cache = 3'b000;
					Addr_mem = {tag_out,Addr[10:3],3'b000};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_RD_1;
				end
			ACC_RD_1:
				begin
					enable_ct = enable_ct_q;
					index_cache = Addr[10:3];
					offset_cache = 3'b010;
					Addr_mem = {tag_out,Addr[10:3],3'b010};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_RD_2;
				end
			ACC_RD_2:
				begin
					enable_ct = enable_ct_q;
					index_cache = Addr[10:3];
					offset_cache = 3'b100;
					Addr_mem = {tag_out,Addr[10:3],3'b100};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_RD_3;
				end
			ACC_RD_3:
				begin
					enable_ct = enable_ct_q;
					index_cache = Addr[10:3];
					offset_cache = 3'b110;
					Addr_mem = {tag_out,Addr[10:3],3'b110};
					DataIn_mem = DataOut_cache;
					wr_mem = 1'b1;
					next_state = ACC_WT_0;
				end
			ACC_WT_0:
				begin
					enable_ct = enable_ct_q;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b000};
					next_state = ACC_WT_1;
				end
			ACC_WT_1:
				begin
					enable_ct = enable_ct_q;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b010};
					next_state = ACC_WT_2;
				end
			ACC_WT_2:
				begin
				    // read from mem
					enable_ct = enable_ct_q;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b100};
					// wrt to cache
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b000;
					tag_cache = Addr[15:11];
					DataIn_ct = (isWr_q & (Addr[2:0] == 3'b000)) ? DataIn : DataOut_mem;
					DataOut_ct = (isRd_q & (Addr[2:0] == 3'b000)) ? DataOut_mem : Data_latch;
					next_state = ACC_WT_3;
				end
			ACC_WT_3:
				begin
				    // read from mem
					enable_ct = enable_ct_q;
					rd_mem = 1'b1;
					Addr_mem = {Addr[15:3],3'b110};
					// wrt to cache
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b010;
					tag_cache = Addr[15:11];
					DataIn_ct = (isWr_q & (Addr[2:0] == 3'b010)) ? DataIn : DataOut_mem;
					DataOut_ct = (isRd_q & (Addr[2:0] == 3'b010)) ? DataOut_mem : Data_latch;
					next_state = ACC_WT_4;
				end
			ACC_WT_4:
				begin
					// wrt to cache
					enable_ct = enable_ct_q;
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b100;
					tag_cache = Addr[15:11];
					DataIn_ct = (isWr_q & (Addr[2:0] == 3'b100)) ? DataIn : DataOut_mem;
					DataOut_ct = (isRd_q & (Addr[2:0] == 3'b100)) ? DataOut_mem : Data_latch;
					next_state = ACC_WT_5;
				end
			ACC_WT_5:
				begin
					// wrt to cache
					enable_ct = enable_ct_q;
					cmp_ct = isWr_q ? 1'b1 : 1'b0;
					wr_cache = 1'b1;
					valid_in_ct = 1'b1;
					index_cache = Addr[10:3];
					offset_cache = 3'b110;
					tag_cache = Addr[15:11];
					DataIn_ct = (isWr_q & (Addr[2:0] == 3'b110)) ? DataIn : DataOut_mem;
					DataOut_ct = (isRd_q & (Addr[2:0] == 3'b110)) ? DataOut_mem : Data_latch;
					next_state = IDLE;
					final_state = 1'b1;
					Done = 1'b1;
					// victimway_out = (Addr[10:3] == 8'b0) ?  : Addr[10:3] == 8'b0({victimway_in[255:(Addr[10:3]+1)], ~enable_ct_q, victimway_in[Addr[10:3]-1:0]});
					victimway_out[Addr[10:3]] = ~enable_ct_q;
				end
		endcase
	end

//////////////////////////////////////////////////////////////////

endmodule