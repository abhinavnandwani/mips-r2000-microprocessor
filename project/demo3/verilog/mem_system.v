/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err, 
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;
   
   output [15:0] DataOut;
   output Done;
   output Stall;
   output CacheHit;
   output err;

   // needed wires
   wire enable_ct, hit_0, hit_1, dirty_0, dirty_1, valid_0, valid_1, err_c0, err_c1, cmp_ct, wr_ct, valid_in_ct;
   wire Hit, stall_dummy, err_m, wr_m, rd_m, ori, err_reg, enable_ct_0, enable_ct_1, final_state, idle;
   wire [2:0] offset_ct;
   wire [3:0] busy_dummy;
   wire [4:0] tag_out_0, tag_out_1, tag_out_c, tag_ct;
   wire [7:0] index_ct;
   wire [15:0] data_out_0, data_out_1, data_out_c, data_in_ct, data_out_m, addr_in_m, data_in_m, DataOut_ct, dataout_temp;
   wire [255:0] victimway_in_c, victimway_out_c;


   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out_0),
                          .data_out             (data_out_0),
                          .hit                  (hit_0),
                          .dirty                (dirty_0),
                          .valid                (valid_0),
                          .err                  (err_c0),
                          // Inputs
                          .enable               (enable_ct_0),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (tag_ct),
                          .index                (index_ct),
                          .offset               (offset_ct),
                          .data_in              (data_in_ct),
                          .comp                 (cmp_ct),
                          .write                (wr_ct),
                          .valid_in             (valid_in_ct));
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (tag_out_1),
                          .data_out             (data_out_1),
                          .hit                  (hit_1),
                          .dirty                (dirty_1),
                          .valid                (valid_1),
                          .err                  (err_c1),
                          // Inputs
                          .enable               (enable_ct_1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (tag_ct),
                          .index                (index_ct),
                          .offset               (offset_ct),
                          .data_in              (data_in_ct),
                          .comp                 (cmp_ct),
                          .write                (wr_ct),
                          .valid_in             (valid_in_ct));

   four_bank_mem mem(// Outputs
                     .data_out          (data_out_m),
                     .stall             (stall_dummy),
                     .busy              (busy_dummy),
                     .err               (err_m),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (addr_in_m),
                     .data_in           (data_in_m),
                     .wr                (wr_m),
                     .rd                (rd_m));
   
   // your code here
   cache_controller ctrl(
      // Input from system
	.clk(clk), .rst(rst), .creat_dump(createdump),
	// Input from mem
	.Addr(Addr), .DataIn(DataIn), .Rd(Rd), .Wr(Wr), .Hit(Hit), .victimway_in(victimway_out_c), .Data_latch(dataout_temp),
	// Input from cache0
	.hit_0(hit_0), .dirty_0(dirty_0), .tag_out_0(tag_out_0) ,.DataOut_cache_0(data_out_0), .valid_0(valid_0),
	// Input from cache1
	.hit_1(hit_1), .dirty_1(dirty_1), .tag_out_1(tag_out_1), .DataOut_cache_1(data_out_1), .valid_1(valid_1),
   // Input from the whole cache
   .DataOut_cache(data_out_c), .tag_out(tag_out_c),
	// Input from four bank
	.DataOut_mem(data_out_m),
	// Output to cache
	.enable_ct(enable_ct), .index_cache(index_ct), .offset_cache(offset_ct), .cmp_ct(cmp_ct), .wr_cache(wr_ct), .tag_cache(tag_ct), .DataIn_ct(data_in_ct),.valid_in_ct(valid_in_ct),
	// Output to fourbank
	.Addr_mem(addr_in_m), .DataIn_mem(data_in_m), .wr_mem(wr_m), .rd_mem(rd_m),
	// Output to system
	.Done(Done), .CacheHit(CacheHit), .Stall_sys(Stall), .victimway_out(victimway_in_c), .ori(ori), .idle(idle), .final_state(final_state), .DataOut_ct(DataOut_ct)
);


   assign tag_out_c = enable_ct ? tag_out_0 : tag_out_1; 
   assign data_out_c = enable_ct ? data_out_0 : data_out_1;
   assign Hit = ((hit_0 & valid_0) | (hit_1 & valid_1));
   assign err = err_c0 | err_c1 | err_m; 
   assign enable_ct_0 = idle ? 1'b0 : (ori ? 1 : enable_ct);
   assign enable_ct_1 = idle ? 1'b0 : (ori ? 1 : (!enable_ct)); 


   reg_16 #(.SIZE(256)) LRU_cnter(.readData(victimway_out_c), .err(err_reg), .clk(clk), .rst(rst), .writeData(victimway_in_c), .writeEn(1'b1));

   // reg_16 #(.SIZE(1)) latch_victimway(.readData(victimway_out_c), .err(err_reg), .clk(clk), .rst(rst), .writeData(victimway_in_c), .writeEn(1'b1));

   reg_16 #(.SIZE(16)) latch_DataOut(.readData(dataout_temp), .err(err_reg), .clk(clk), .rst(rst), .writeData(DataOut_ct), .writeEn(1'b1));
   assign DataOut = final_state ? (DataOut_ct) : (dataout_temp);

   
endmodule // mem_system


// DUMMY LINE FOR REV CONTROL :9: