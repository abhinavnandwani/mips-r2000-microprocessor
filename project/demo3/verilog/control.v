/* 
    Author          : Abhinav Nandwani, Anna Huang
    Filename        : control.v
    Description     : This module decodes the instruction and generates control signals for all the sub-modules of the processor. 
*/

`default_nettype none
module control (
    input wire [15:0] instr,
    
    // Control Signals
    output reg nHaltSig,
    output reg RegWrt,
    output reg ZeroExt,
    output reg MemRead,
    output reg ImmSrc,
    output reg ALUSign,
    output reg ALUJmp,
    output reg MemWrt,
    output reg err,

    // ALU Control
    output reg [5:0] ALUOpr,

    // Register and Branch Controls
    output reg [1:0] RegSrc,
    output reg [1:0] BSrc,
    output reg [1:0] RegDst,
    output reg [3:0] BranchTaken,
    output reg NOP
    );
    wire funct;
    assign funct = instr[1:0];

    
    always@(*) begin
    // Default outputs //
    nHaltSig = 1'b0;
    RegWrt = 1'b0;
    ZeroExt = 1'b0;
    ImmSrc = 1'b0;
    ALUSign = 1'b0;
    ALUJmp = 1'b0;
    MemWrt = 1'b0;
    err = 1'b0;
    ALUOpr = 6'b000000;  // Ensure it's a 6-bit value
    RegSrc = 2'b10;
    RegDst = 2'b00;
    BSrc = 2'b00;
    MemRead = 1'b0;
    BranchTaken = 4'b000;
    NOP = 1'b0;

    casex(instr[15:11])
        5'b00000: nHaltSig = 1'b1;		// HALT 
        5'b00001:begin		// NOP
            // none
            NOP = 1'b1;
            end
        /* I format 1 below: */
        5'b010xx: begin   //ADDI, SUBI, XORI, ANDNI
            RegSrc = 2'b10;
            RegDst = 2'b00;
            RegWrt = 1'b1;
            BSrc = 2'b01;
            ALUOpr = {3'b000,instr[13:11]};
            ZeroExt = instr[12];
        end

        5'b101xx: begin		// ROLI, SLLI, RORI, SRLI
            RegSrc = 2'b10;
            RegDst = 2'b00;
            RegWrt = 1'b1;
            ZeroExt = 1'b1;
            BSrc = 2'b01;
            ALUOpr = {3'b000,instr[13:11]}; 
        end

        5'b10000: begin		// ST
            RegSrc = 2'b01;
            RegWrt = 1'b0;
            MemWrt = 1'b1;
            MemRead = 1'b0;
            ZeroExt = 1'b0;
            BSrc = 2'b01;
            ALUSign = 1'b0;
            ALUOpr = 6'b000000; //ADDI
            BranchTaken = 4'b0000;
        end
        5'b10001: begin		// LD
            RegSrc = 2'b01;
            RegDst = 2'b00;
            RegWrt = 1'b1;
            MemWrt = 1'b0;
            ZeroExt = 1'b0;
            BSrc = 2'b01;
            ALUSign = 1'b0;
            MemRead = 1'b1;
            ALUOpr = 6'b000000; //ADDI
            BranchTaken = 4'b0000;
        end
        5'b10011: begin		// STU
            RegSrc = 2'b10;
            RegDst = 2'b01;
            RegWrt = 1'b1;
            MemWrt = 1'b1;
            ZeroExt = 1'b0;
            BSrc = 2'b01;
            ALUOpr = 6'b000000; //ADDI
            ALUSign = 1'b0;
            BranchTaken = 4'b0000;
        end
                    
        /* R format below: */
        
        5'b11001: begin		// BTR
            RegSrc = 2'b10;
            RegDst = 2'b10;
            RegWrt = 1'b1;
            ZeroExt = 1'b1;
            BSrc = 2'b01;
            ALUSign = 1'b0;
            ALUOpr = 6'b111xxx;
            BranchTaken = 4'b0000;
        end
        // R Type //
        5'b1101x: begin	
            // ADD, SUB, XOR, ANDN ROL, SLL, ROR, SRL
            RegSrc = 2'b10;
            RegDst = 2'b10;
            RegWrt = 1'b1;
            BSrc = 2'b00;
            ALUOpr = {3'b010,~instr[11],2'bxx};
        end

        5'b111xx: begin		// SEQ invA = 1;
            RegSrc = 2'b10;
            RegDst = 2'b10;
            RegWrt = 1'b1;
            BSrc = 2'b00;
            ALUSign = 1'b1;
            ALUOpr = {3'b011 + instr[12:11],3'bxxx};
        end
        /* I format 2 below: */
        
        5'b011xx: begin		// BEQZ, BNEZ, BLTZ, BGEZ
            RegWrt = 1'b0;
            ALUJmp = 1'b0;
            ImmSrc = 1'b1;
            ALUSign = 1'b1;
            BSrc = 2'b11;
            ALUOpr = 6'b000001; //SUBI
            BranchTaken = {2'b01, instr[12:11]};
        end
       5'b11000: begin		// LBI FIX
            RegWrt = 1'b1;
            RegDst = 2'b01;
            ALUJmp = 1'b0;
            ImmSrc = 1'b1;
            ZeroExt = 1'b0;
            BSrc = 2'b10;
            ALUOpr = 6'b00101x;
            RegSrc = 2'b10;
            BranchTaken = 4'b0000;
        end
        5'b10010: begin		// SLBI FIX
            RegWrt = 1'b1;
            RegDst = 2'b01;
            ALUJmp = 1'b0;
            ImmSrc = 1'b1;
            ALUSign = 1'b0;
            ZeroExt = 1'b1;
            BSrc = 2'b10;
            ALUOpr = 6'b00110x;
            RegSrc = 2'b10;
            BranchTaken = 4'b0000;
        end
        
        /* Jump Instructions below: */
        
        5'b00100: begin		// J displacement
            RegWrt = 1'b0;
    
            ALUJmp = 1'b0;
            ImmSrc = 1'b0;
            BranchTaken = 4'b1000;
        end
        5'b00101: begin		// JR
            RegWrt = 1'b0;
    
            ALUJmp = 1'b1;
            ImmSrc = 1'b1;
            BSrc = 2'b10;
            //ZeroExt = 1'b1;
            BranchTaken = 4'b1000;
        end
        5'b00110: begin		// JAL
            RegSrc = 2'b00;
            RegDst = 2'b11;
            RegWrt = 1'b1;
    
            ALUJmp = 1'b0;
            ImmSrc = 1'b0;
            BranchTaken = 4'b1000;
        end
        5'b00111: begin		// JALR
            RegSrc = 2'b00;
            RegDst = 2'b11;
            RegWrt = 1'b1;
    
            ALUJmp = 1'b1;
            ImmSrc = 1'b1;
            BSrc = 2'b10;
            BranchTaken = 4'b1000;
        end
        
        /* TODO: Extra Credit below: */
        
        5'b00010: begin		// siic *****************************************
        
        end
        5'b00011: begin		// NOP / RTI ************************************
        
        end
        
        default: err = 1'b1;		// Control OpCode error
    endcase
    end


endmodule
`default_nettype wire