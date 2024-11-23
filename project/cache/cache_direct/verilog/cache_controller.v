`default_nettype none
module cache_controller (
   // input wire enable,
   input wire clk,
   input wire rst,
   input wire createdump,
   input wire Rd,
   input wire Wr,
   input wire busy,
   input wire valid,
   input wire dirty,
   input wire hit,
   output reg valid_in,
   output reg comp,
   output reg write,
   output reg write_mem,
   output reg read_mem
   );

   // Define the states using parameters
   parameter IDLE                  = 4'b0000;
   parameter COMPARE_READ          = 4'b0001;
   parameter COMPARE_WRITE         = 4'b0010;
   parameter MEMORY_READ           = 4'b0011;
   parameter ACCESS_READ           = 4'b0100;
   parameter ACCESS_WRITE          = 4'b0110;

   wire [2:0] state;
   reg [2:0] next_state;

   //  // State transition logic
   //  always @(posedge clk or posedge rst) begin
   //      if (rst) begin
   //          state <= IDLE;
   //          done <= 1'b0;
   //      end else begin
   //          state <= next_state;
   //      end
   //  end
   dff state_1 [2:0](.q(state), .d(next_state), .clk(clk), .rst(rst));

   // Next state and output logic
   always @(*) begin
      // Default output values
      comp = 1'b1;
      write = 1'b0;
      write_mem = 1'b0;
      read_mem = 1'b0;
      valid_in = 1'b0;
      next_state = state;

      case (state)
         IDLE: begin
            if (Rd) begin
               next_state = COMPARE_READ;
            end else if (Wr) begin 
               next_state = COMPARE_WRITE;
            end
         end

         COMPARE_READ: begin
            /*
            This case is used when the processor executes a load instruction. 
            The "tag_in", "index", and "offset" signals need to be valid. 
            Either a hit or a miss will occur, as indicated by the "hit" output during the same cycle. 
            If a hit occurs, "data_out" will contain the data and "valid" will indicate if the data is valid. 
            If a miss occurs, the "valid" output will indicate whether the block occupying that line of the cache is valid. 
            The "dirty" output indicates the state of the dirty bit in the cache line.
            */
            comp = 1'b1;
            write = 1'b0;
            if (~valid) next_state = MEMORY_READ_MISS;
            else begin
               if (hit)
                  next_state = IDLE; //data ready
               else next_state = MEMORY_READ_NOTVALID;
            end

         end

         MEMORY_READ_MISS : begin // understand 4 banked
            //when memory ready
                           comp = 1'b0;
            valid_in = 1'b1;
            read_mem = 1'b1;
            if (~busy) begin
               if (~valid) begin
                  next_state = ACCESS_WRITE;
               end else begin
                  if (dirty) begin
                     next_state = ACCESS_READ;
                  end
               end
            end
         end


         COMPARE_WRITE: begin
            comp = 1'b1;
            write = 1'b1;
            if (hit && valid) begin
               if (busy) begin
                  next_state = COMPARE_WRITE;
               end else begin
                  next_state = ACCESS_WRITE;
               end
            end else begin
               next_state = IDLE;
            end
         end

         MEMORY_READ: begin
            comp = 1'b0;
            valid_in = 1'b1;
            read_mem = 1'b1;
            if (~busy) begin
               if (~valid) begin
                  next_state = ACCESS_WRITE;
               end else begin
                  if (dirty) begin
                     next_state = ACCESS_READ;
                  end
               end
            end
         end

         ACCESS_READ: begin
            comp = 1'b0;
            write = 1'b0;
            write_mem = 1'b1;
            if (~busy) begin
               next_state = ACCESS_WRITE;
            end
         end

         ACCESS_WRITE: begin
            comp = 1'b0;
            write = 1'b1;
            next_state = IDLE;
         end

         default: begin
            next_state = IDLE; // Default case to reset to IDLE
         end
      endcase
   end

endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
