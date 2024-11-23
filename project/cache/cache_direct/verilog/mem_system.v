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
   output reg        Done;
   output wire       Stall;
   output reg        CacheHit;
   output wire       err;

   wire comp, write;
   wire hit, dirty, valid, valid_in, busy;
   wire err_mem, err_cache;
   wire [15:0] data_out;
   wire write_mem, read_mem;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (),
                          .data_out             (data_out),
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
                          .offset               (Addr[2:0]),
                          .data_in              (DataOut),
                          .comp                 (comp),
                          .write                (write),
                          .valid_in             (valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (DataOut),
                     .stall             (Stall),
                     .busy              (busy),
                     .err               (err_mem),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (Addr),
                     .data_in           (data_out),
                     .wr                (Wr),
                     .rd                (Rd));
   
   // your code here
   cache_controller ctrl(
      .clk(clk),
      .rst(rst),
      .createdump(createdump),
      .Rd(Rd),
      .Wr(Wr),
      .busy(busy),
      .valid(valid),
      .dirty(dirty),
      .hit(hit),
      .valid_in(valid_in),
      .comp(comp),
      .write(write),
      .write_mem(write_mem),
      .read_mem(read_mem)
   ); 

   assign err = err_mem | err_cache;
   assign CacheHit = hit;

endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
