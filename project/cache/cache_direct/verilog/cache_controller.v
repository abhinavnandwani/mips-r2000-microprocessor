`default_nettype none
module cache_controller (
   // input wire enable,
   input wire clk,
   input wire rst,
   input wire createdump,
   input wire Rd,
   input wire comp,
   input wire write,
   input wire valid,
   input wire dirty,
   input wire hit,
   // input wire [4:0] tag_in,
   // input wire [7:0] index,
   // input wire [2:0] offset,
   // input wire [15:0] data_in,
   // input wire valid_in,

   // output wire [4:0] tag_out,
   // output wire [15:0] data_out,
   output wire err

   //  input wire clk,
   //  input wire rst,
   //  input wire enable,

   //  output reg read_mem,
   //  output reg write_mem,
   //  output reg done
   );

   // Define the states using parameters
   parameter IDLE                  = 4'b0000;
   parameter COMPARE_READ          = 4'b0001;
   parameter COMPARE_WRITE         = 4'b0010;
   parameter ACCESS_READ           = 4'b0011;
   parameter ACCESS_WRITE          = 4'b0100;
   parameter COMPARE               = 4'b0101;
   parameter WRITE_BACK            = 4'b0110;
   parameter FETCH_BLOCK           = 4'b0111;

   reg [1:0] next_state;

   //  // State transition logic
   //  always @(posedge clk or posedge rst) begin
   //      if (rst) begin
   //          state <= IDLE;
   //          done <= 1'b0;
   //      end else begin
   //          state <= next_state;
   //      end
   //  end
   dff state(.q(state), .d(next_state), .clk(clk), .rst(rst));

   // Next state and output logic
   always @(*) begin
      // Default output values
      // read_mem = 1'b0;
      // write_mem = 1'b0;
      // done = 1'b0;
      next_state = state;

      case (state)
         IDLE: begin
               if (comp) begin
                  next_state = COMPARE;
               end
         end

         COMPARE: begin
               if (hit && valid) begin
                  if (write) begin
                     // Write hit
                     next_state = IDLE;
                     done = 1'b1;
                  end else begin
                     // Read hit
                     next_state = IDLE;
                     done = 1'b1;
                  end
               end else begin
                  // Cache miss
                  if (dirty) begin
                     next_state = WRITE_BACK;
                  end else begin
                     next_state = FETCH_BLOCK;
                  end
               end
         end

         WRITE_BACK: begin
               // Simulate write-back operation to main memory
               write_mem = 1'b1;
               next_state = FETCH_BLOCK;
         end

         FETCH_BLOCK: begin
               // Simulate fetching a block from main memory
               read_mem = 1'b1;
               next_state = COMPARE;
               done = 1'b1;  // Indicate operation completion
         end

         default: begin
               next_state = IDLE; // Default case to reset to IDLE
         end
      endcase
   end

endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
