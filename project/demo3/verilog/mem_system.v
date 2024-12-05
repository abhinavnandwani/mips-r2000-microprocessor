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
   output wire        Stall;
   output wire        CacheHit;
   output wire        err;

   wire comp, write, write_0, write_1;
   wire hit, dirty, valid, valid_out, valid_out_0, valid_out_1, valid_in;
   wire hit_0, dirty_0, valid_0;
   wire hit_1, dirty_1, valid_1;
   wire [3:0] busy;
   wire [4:0] tag_out, tag_out_0, tag_out_1;
   wire err_mem, err_cache_0, err_cache_1;
   wire [15:0] data_out_cache_0,data_out_cache_1,data_out_mem,mem_addr;
   wire write_mem, read_mem;
   wire [2:0] offset_out;
   wire cache_in, mem_in, mem_stall;
   wire [4:0] tag_in;
   wire [2:0] offset_in;
   wire victimway, evict, cache_sel, CacheHit_0, CacheHit_1;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out_0),
                          .data_out             (data_out_cache_0),
                          .hit                  (hit_0),
                          .dirty                (dirty_0),
                          .valid                (valid_0),
                          .err                  (err_cache_0),
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
                          .write                (write_0), // write_0
                          .valid_in             (valid_out_0));
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (tag_out_1),
                          .data_out             (data_out_cache_1),
                          .hit                  (hit_1),
                          .dirty                (dirty_1),
                          .valid                (valid_1),
                          .err                  (err_cache_1),
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
                          .write                (write_1), // write_1
                          .valid_in             (valid_out_1));

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
                     .data_in           (mem_in ? DataOut : (DataIn)),
                     .wr                (write_mem),
                     .rd                (read_mem));
   
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
      .Stall(Stall),
      .write_mem(write_mem), 
      .CacheHit(CacheHit),
      .read_mem(read_mem),
      .cache_in(cache_in),
      .mem_in(mem_in),
      .done(Done)
   ); 

   // Victimway flip-flop for alternate victim selection
   dff victimway_ff (
      .q(victimway),                      // Output: current state of victimway
      .d(Done ? ~victimway : victimway),  // Toggle on Done signal
      .clk(clk),                          // Clock signal
      .rst(rst)                           // Reset signal
   );

   // LRU bits for 256 sets (one bit per set for 2-way cache)
   wire [255:0] lru_out;                  // Current LRU state
   reg [255:0] lru_in;                    // Next-state LRU
   wire set_lru;                          // Determines LRU update

   // LRU flip-flops for all sets
   dff lru_ff[255:0] (
      .q(lru_out),                        // Output: current LRU state
      .d(Done ? lru_in : lru_out),        // Update LRU on Done
      .clk(clk),                          // Clock signal
      .rst(rst)                           // Reset signal
   );

   // LRU logic to determine next state
   always @(*) begin
      lru_in = lru_out;                   // Default: No change
      case (set_lru)
         1'b0: lru_in[Addr[10:3]] = 1'b0; // Mark Way 0 as least recently used
         1'b1: lru_in[Addr[10:3]] = 1'b1; // Mark Way 1 as least recently used
      endcase
   end

   // Determine which way was hit
   assign CacheHit_0 = hit_0 & valid_0;   // Cache Way 0 hit
   assign CacheHit_1 = hit_1 & valid_1;   // Cache Way 1 hit

   // Set LRU on cache hit
   assign set_lru = CacheHit_0 ? 1'b1 :   // If Way 0 is hit, mark Way 1 as LRU
                    CacheHit_1 ? 1'b0 :   // If Way 1 is hit, mark Way 0 as LRU
                    lru_out[Addr[10:3]];  // Default to current LRU state


   always @(posedge clk) begin
      $display("evict : %h",evict);
      
   end

   // Victim Selection Logic
   assign evict = valid_0 ? (valid_1 ? lru_out[Addr[10:3]] : 1'b1) : 1'b0;

   // Cache selection logic
   assign cache_sel = (Rd | Wr) ? 
                      (CacheHit_0 ? 1'b0 : 
                       (CacheHit_1 ? 1'b1 : evict)) : 1'b0;

   // Combine hit signals
   assign hit = hit_0 | hit_1;

   // Cache outputs based on selected way
   assign dirty = cache_sel ? dirty_1 : dirty_0;
   assign valid = cache_sel ? valid_1 : valid_0;
   assign tag_out = cache_sel ? tag_out_1 : tag_out_0;

   // Write enables for cache ways
   assign valid_out_0 = cache_sel ? 1'b0 : valid_in;
   assign valid_out_1 = cache_sel ? valid_in : 1'b0;
   assign write_0 = cache_sel ? 1'b0 : write;
   assign write_1 = cache_sel ? write : 1'b0;

   // Data output based on selected way
   assign DataOut = cache_sel ? data_out_cache_1 : data_out_cache_0;

   // Aggregate error signals
   assign err = err_mem | err_cache_0 | err_cache_1;

   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
