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
   wire err_mem, err_cache;
   wire [15:0] data_out_cache,data_out_mem;
   wire write_mem, read_mem;
   wire [1:0] counter;
   wire cache_in, mem_in, mem_stall;

   wire [1:0]counter_ff;
   wire done;
  // assign counter_ff = counter;
   dff counter_fffx [1:0](.q(counter_ff), .d(counter), .clk({2{clk}}), .rst({2{rst}}));
   assign #100 Done =  done;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (),
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
                          .offset               (Addr[2:0] + {counter_ff,1'b0}),
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
                     .addr              (Addr + {counter,1'b0}),
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
      .busy(busy),
      .mem_stall(mem_stall),
      .valid(valid),
      .dirty(dirty),
      .hit(hit),
      .valid_in(valid_in),
      .comp(comp),
      .write(write),
      .write_mem(write_mem),
      .read_mem(read_mem),
      .cache_in(cache_in),
      .counter(counter),
      .mem_in(mem_in),
      .done(done)
   ); 

   assign err = err_mem | err_cache;
   assign CacheHit = hit;
   assign Stall = ~Done;
   assign DataOut = data_out_cache;

   //  always@(posedge clk)
   //    $display("w0 : %h w1 : %h w2 : %h w3 : %h counter:%d", c0.w0,c0.w1,c0.w2,c0.w3,counter);

   always@(posedge clk)
      $display("Addr : %h state : %b, counter; %h, inc: %h, clr: %h",Addr,ctrl.state, {counter_ff,1'b0}, ctrl.inc_counter, ctrl.clr_counter);


endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
