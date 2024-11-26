/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

`default_nettype none
module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input wire [15:0] Addr;
   input wire [15:0] DataIn;
   input wire        Rd;
   input wire        Wr;
   input wire        createdump;
   input wire        clk;
   input wire        rst;
   
   output wire [15:0] DataOut;
   output wire        Done;
   output wire       Stall;
   output wire       CacheHit;
   output wire       err;

   wire comp, write;
   wire hit, dirty, valid, valid_in;
   wire [3:0] busy;
   wire [4:0] tag_out;
   wire err_mem, err_cache;
   wire [15:0] data_out_cache,data_out_mem,mem_addr;
   wire write_mem, read_mem;
   wire [2:0] offset_out;
   wire cache_in, mem_in, mem_stall;
   wire [4:0] tag_in;
   wire [7:0] index_in;
   wire [2:0] offset_in;

   wire [1:0]counter_ff, counter_2ff;
   wire done,stall;
   assign Done =  done;
   assign Stall =  stall;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out),
                          .data_out             (data_out_cache),
                          .hit                  (hit),
                          .dirty                (dirty),
                          .valid                (valid),
                          .err                  (err_cache),
                          // Inputs
                          .enable               (1'b1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (offset_out),
                          .data_in              (cache_in ? data_out_mem : DataIn),
                          .comp                 (comp),
                          .write                (write),
                          .valid_in             (valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (data_out_mem),
                     .stall             (mem_stall),
                     .busy              (busy),
                     .err               (err_mem),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (mem_addr),
                     .data_in           (mem_in ? data_out_cache : (DataIn)),
                     .wr                (write_mem),
                     .rd                (read_mem));
   
   // your code here
   cache_controller ctrl(
      .clk(clk),
      .rst(rst),
      .createdump(createdump),
      .Rd(Rd),
      .Wr(Wr),
      .valid(valid),
      .dirty(dirty),
      .hit(hit),
      .mem_stall(mem_stall),
      .tag_in(Addr[15:11]),
      .index_in(Addr[10:3]),
      .offset_in(Addr[2:0]),
      .tag_out(tag_out),
      //outputs
      .valid_in(valid_in),
      .offset_out(offset_out),
      .mem_addr(mem_addr),
      .comp(comp),
      .write(write),
      .Stall(stall),
      .write_mem(write_mem), 
      .CacheHit(CacheHit),
      .read_mem(read_mem),
      .cache_in(cache_in),
      .mem_in(mem_in),
      .done(done)
   ); 

   assign err = err_mem | err_cache;
  // assign CacheHit = hit;
   assign DataOut = 1'b1 ? data_out_cache : data_out_mem;


endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9: