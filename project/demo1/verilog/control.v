`default_nettype none
module control (instr, nHaltSig, RegDst, RegWrt, MemRead, ZeroExt, BSrc, ImmSrc, ALUOpr, invA, invB, ALUSign, Cin, err,ALUJmp, MemWrt, RegSrc, BranchTaken);
    input wire [15:0] instr;   
    output reg nHaltSig, RegWrt, ZeroExt, MemRead,ImmSrc, invA, invB, ALUSign, Cin, ALUJmp, MemWrt,err;      
    output reg [5:0] ALUOpr;   
    output reg [1:0] RegSrc, BSrc,RegDst;      
    output reg [2:0] BranchTaken;
    wire funct;
    assign funct = instr[1:0];

    
    always@(*) begin
    // Default outputs //
    nHaltSig = 1'b1;
    RegWrt = 1'b0;
    ZeroExt = 1'b0;
    ImmSrc = 1'b0;
    invA = 1'b0;
    invB = 1'b0;
    ALUSign = 1'b0;
    Cin = 1'b0;
    ALUJmp = 1'b0;
    MemWrt = 1'b0;
    MemRead = 1'b1;
    err = 1'b0;
    ALUOpr = 6'b000000;  // Ensure it's a 6-bit value
    RegSrc = 2'b10;
    RegDst = 2'b00;
    BSrc = 2'b00;
    MemRead = 1'b0;
    BranchTaken = 3'b000;

    case(instr[15:11])
        5'b00000: nHaltSig = 1'b0;		// HALT 
        //5'b00001: begin		// NOP
            // none

        /* I format 1 below: */
        
        5'b01000: begin // ADDI
            RegSrc = 2'b10;
            RegDst = 2'b00;
            RegWrt = 1'b1;
            BSrc = 2'b01;
            ALUSign = 1'b0;
            ALUOpr = {3'b000,instr[13:11]}; 
        end

        5'b01001: begin		// SUBI
            RegSrc = 2'b10;
            RegDst = 2'b00;
            RegWrt = 1'b1;
    
            ZeroExt = 1'b0;
            BSrc = 2'b01;
            //ALUSign = 1'b1;
            invA = 1'b1;
            invB = 1'b0;
            Cin = 1'b1;
            ALUOpr = {3'b000,instr[13:11]}; 
            BranchTaken = 3'b000;
        end	
        5'b01010: begin		// XORI
            RegSrc = 2'b10;
            RegDst = 2'b00;
            RegWrt = 1'b1;
    
            ZeroExt = 1'b1;
            BSrc = 2'b01;
            ALUSign = 1'b1;
            invA = 1'b0;
            invB = 1'b0;
            Cin = 1'b0;
            ALUOpr = {3'b000,instr[13:11]}; 
            BranchTaken = 3'b000;
        end
        5'b01011: begin		// ANDNI
            RegSrc = 2'b10;
            RegDst = 2'b00;
            RegWrt = 1'b1;
    
            ZeroExt = 1'b1;
            BSrc = 2'b01;
            ALUSign = 1'b1;
            invA = 1'b0;
            invB = 1'b1;
            Cin = 1'b0;
            ALUOpr = {3'b000,instr[13:11]}; 
            BranchTaken = 3'b000;
        end
        5'b10100: begin		// ROLI
            RegSrc = 2'b10;
            RegDst = 2'b00;
            RegWrt = 1'b1;
    
            ZeroExt = 1'b1;
            BSrc = 2'b01;
            ALUSign = 1'b1;
            invA = 1'b0;
            invB = 1'b0;
            Cin = 1'b0;
            ALUOpr = {3'b000,instr[13:11]}; 
            BranchTaken = 3'b000;
        end
        5'b10101: begin		// SLLI
            RegSrc = 2'b10;
            RegDst = 2'b00;
            RegWrt = 1'b1;
    
            ZeroExt = 1'b1;
            BSrc = 2'b01;
            ALUSign = 1'b1;
            invA = 1'b0;
            invB = 1'b0;
            Cin = 1'b0;
            ALUOpr = {3'b000,instr[13:11]}; 
            BranchTaken = 3'b000;
        end
        5'b10110: begin		// RORI
            RegSrc = 2'b10;
            RegDst = 2'b00;
            RegWrt = 1'b1;
    
            ZeroExt = 1'b1;
            BSrc = 2'b01;
            ALUSign = 1'b1;
            invA = 1'b0;
            invB = 1'b0;
            Cin = 1'b0;
            ALUOpr = {3'b000,instr[13:11]}; 
            BranchTaken = 3'b000;
        end
        5'b10111: begin		// SRLI
            RegSrc = 2'b10;
            RegDst = 2'b00;
            RegWrt = 1'b1;
            ZeroExt = 1'b1;
            BSrc = 2'b01;
            ALUSign = 1'b1;
            invA = 1'b0;
            invB = 1'b0;
            Cin = 1'b0;
            ALUOpr = {3'b000,instr[13:11]}; 
            BranchTaken = 3'b000;
        end

        5'b10000: begin		// ST
            RegSrc = 2'b01;
            RegWrt = 1'b0;
            MemWrt = 1'b1;
            MemRead = 1'b0;
            ZeroExt = 1'b0;
            BSrc = 2'b01;
            ALUSign = 1'b0;
            invA = 1'b0;
            invB = 1'b0;
            Cin = 1'b0;
            ALUOpr = {3'b000,instr[13:11]}; //ADDI
            BranchTaken = 3'b000;
        end
        5'b10001: begin		// LD
            RegSrc = 2'b01;
            RegDst = 2'b00;
            RegWrt = 1'b1;
            MemWrt = 1'b0;
            ZeroExt = 1'b0;
            BSrc = 2'b01;
            ALUSign = 1'b0;
            invA = 1'b0;
            MemRead = 1'b1;
            invB = 1'b0;
            Cin = 1'b0;
            ALUOpr = {3'b000,instr[13:11]}; //ADDI
            BranchTaken = 3'b000;
        end
        5'b10011: begin		// STU
            RegSrc = 2'b10;
            RegDst = 2'b01;
            RegWrt = 1'b1;
            MemWrt = 1'b1;
            ZeroExt = 1'b0;
            BSrc = 2'b01;
            ALUSign = 1'b0;
            invA = 1'b0;
            invB = 1'b0;
            Cin = 1'b0;
            ALUOpr = {3'b000,instr[13:11]}; //ADDI
            BranchTaken = 3'b000;
        end
                    
        /* R format below: */
        
        5'b11001: begin		// BTR FIX!!
            RegSrc = 2'b10;
            RegDst = 2'b10;
            RegWrt = 1'b1;
    
            ZeroExt = 1'b1;
            BSrc = 2'b01;
            ALUSign = 1'b0;
            invA = 1'b0;
            invB = 1'b0;
            Cin = 1'b0;
            ALUOpr = 6'b111xxx;
            BranchTaken = 3'b000;
        end
        // R Type //
        5'b11011: begin		// ADD, SUB, XOR, ANDN
            case(funct)
                2'b00: begin		// ADD
                    RegSrc = 2'b10;
                    RegDst = 2'b10;
                    RegWrt = 1'b1;
            
                    BSrc = 2'b00;
                    ALUSign = 1'b0; // TODO: have to decide ALUSign 
                    invA = 1'b0;
                    invB = 1'b0;
                    Cin = 1'b0;
                    ALUOpr = {3'b010,~instr[11],2'bxx};
                    BranchTaken = 3'b000;
                end
                2'b01: begin		// SUB
                    RegSrc = 2'b10;
                    RegDst = 2'b10;
                    RegWrt = 1'b1;
            
                    ZeroExt = 0;
                    BSrc = 2'b00;
                    ALUSign = 1'b1;
                    invA = 1'b1;
                    invB = 1'b0;
                    Cin = 1'b1;
                    ALUOpr = {3'b010,~instr[11],2'bxx};
                    BranchTaken = 3'b000;
                end 
                2'b10: begin		// XOR
                    RegSrc = 2'b10;
                    RegDst = 2'b10;
                    RegWrt = 1'b1;
            
                    BSrc = 2'b00;
                    ALUSign = 1'b1;
                    invA = 1'b0;
                    invB = 1'b0;
                    Cin = 1'b0;
                    ALUOpr = {3'b010,~instr[11],2'bxx};
                    BranchTaken = 3'b000;
                end
                2'b11: begin		// ANDN
                    RegSrc = 2'b10;
                    RegDst = 2'b10;
                    RegWrt = 1'b1;
            
                    BSrc = 2'b00;
                    ALUSign = 1'b1;
                    invA = 1'b0;
                    invB = 1'b1;
                    Cin = 1'b0;
                    ALUOpr = {3'b010,~instr[11],2'bxx};
                    BranchTaken = 3'b000;
                end
                default: err = 1'b1;			// R format funct code error
            endcase
        end
        5'b11010: begin		// ROL, SLL, ROR, SRL
            case(funct)
                2'b00: begin		// ROL
                    RegSrc = 2'b10;
                    RegDst = 2'b10;
                    RegWrt = 1'b1;
            
                    BSrc = 2'b00;
                    ALUSign = 1'b1;
                    invA = 1'b0;
                    invB = 1'b0;
                    Cin = 1'b0;
                    ALUOpr = {3'b010,~instr[11],2'bxx};
                    BranchTaken = 3'b000;
                end
                2'b01: begin		// SLL
                    RegSrc = 2'b10;
                    RegDst = 2'b10;
                    RegWrt = 1'b1;
            
                    BSrc = 2'b00;
                    ALUSign = 1'b1;
                    invA = 1'b0;
                    invB = 1'b0;
                    Cin = 1'b0;
                    ALUOpr = {3'b010,~instr[11],2'bxx};
                    BranchTaken = 3'b000;
                end
                2'b10: begin		// ROR
                    RegSrc = 2'b10;
                    RegDst = 2'b10;
                    RegWrt = 1'b1;
            
                    BSrc = 2'b00;
                    ALUSign = 1'b1;
                    invA = 1'b0;
                    invB = 1'b0;
                    Cin = 1'b0;
                    ALUOpr = {3'b010,~instr[11],2'bxx};
                    BranchTaken = 3'b000;
                end
                2'b11: begin		// SRL
                    RegSrc = 2'b10;
                    RegDst = 2'b10;
                    RegWrt = 1'b1;
            
                    BSrc = 2'b00;
                    ALUSign = 1'b1;
                    invA = 1'b0;
                    invB = 1'b0;
                    Cin = 1'b0;
                    ALUOpr = {3'b010,~instr[11],2'bxx};
                    BranchTaken = 3'b000;
                end
                default: err = 1'b1;			// R format funct code error
            endcase
        end
        5'b11100: begin		// SEQ
            RegSrc = 2'b11;
            RegDst = 2'b10;
            RegWrt = 1'b1;
    
            BSrc = 2'b00;
            ALUSign = 1'b1;
            invA = 1'b1;
            invB = 1'b0;
            Cin = 1'b1;
            ALUOpr = 6'b011xxx;
            BranchTaken = 3'b000;
        end
        5'b11101: begin		// SLT
            RegSrc = 2'b11;
            RegDst = 2'b10;
            RegWrt = 1'b1;
    
            BSrc = 2'b00;
            ALUSign = 1'b1;
            invA = 1'b1;
            invB = 1'b0;
            Cin = 1'b1;
            ALUOpr = 6'b100xxx;
            BranchTaken = 3'b000;
        end
        5'b11110: begin		// SLE
            RegSrc = 2'b11;
            RegDst = 2'b10;
            RegWrt = 1'b1;
    
            BSrc = 2'b00;
            ALUSign = 1'b1;
            invA = 1'b1;
            invB = 1'b0;
            Cin = 1'b1;
            ALUOpr = 6'b101xxx;
            BranchTaken = 3'b000;
        end
        5'b11111: begin		// SCO
            RegSrc = 2'b11;
            RegDst = 2'b10;
            RegWrt = 1'b1;
    
            BSrc = 2'b00;
            ALUSign = 1'b1;
            invA = 1'b0;
            invB = 1'b0;
            Cin = 1'b0;
            ALUOpr = 6'b110xxx;
            BranchTaken = 3'b000;
        end
        
        /* I format 2 below: */
        
        5'b01100: begin		// BEQZ
            RegWrt = 1'b0;
    
            ALUJmp = 1'b0;
            ImmSrc = 1'b1;
            invA = 1'b1;
            Cin = 1'b1;
            BSrc = 2'b11;
            BranchTaken = {1'b1, instr[12:11]};
        end
        5'b01101: begin		// BNEZ
            RegWrt = 1'b0;
    
            ALUJmp = 1'b0;
            ImmSrc = 1'b1;
            invA = 1'b1;
            Cin = 1'b1;
            BSrc = 2'b11;
            ALUOpr = 3'b101;
            BranchTaken = {1'b1, instr[12:11]};
        end
        5'b01110: begin		// BLTZ
            RegWrt = 1'b0;
    
            ALUJmp = 1'b0;
            ImmSrc = 1'b1;
            BSrc = 2'b11;
            invA = 1'b1;
            Cin = 1'b1;
            ALUOpr = 3'b101;
            BranchTaken = {1'b1, instr[12:11]};
        end
        5'b01111: begin		// BGEZ
            RegWrt = 1'b0;
    
            ALUJmp = 1'b0;
            ImmSrc = 1'b1;
            invA = 1'b1;
            Cin = 1'b1;
            BSrc = 2'b11;
            BranchTaken = {1'b1, instr[12:11]};
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
            BranchTaken = 3'b000;
        end
        5'b10010: begin		// SLBI FIX
            RegWrt = 1'b01;
            RegDst = 2'b01;
    
            ALUJmp = 1'b0;
            ImmSrc = 1'b1;
            ALUSign = 1'b0;
            ZeroExt = 1'b1;
            BSrc = 2'b10;
            ALUOpr = 6'b00110x;
            RegSrc = 2'b10;
            BranchTaken = 3'b000;
        end
        
        /* Jump Instructions below: */
        
        5'b00100: begin		// J displacement
            RegWrt = 1'b0;
    
            ALUJmp = 1'b0;
            ImmSrc = 1'b0;
            BranchTaken = 3'b100;
        end
        5'b00101: begin		// JR
            RegWrt = 1'b0;
    
            ALUJmp = 1'b1;
            ImmSrc = 1'b1;
            BSrc = 2'b10;
            //ZeroExt = 1'b1;
            BranchTaken = 3'b100;
        end
        5'b00110: begin		// JAL
            RegSrc = 2'b00;
            RegDst = 2'b11;
            RegWrt = 1'b1;
    
            ALUJmp = 1'b0;
            ImmSrc = 1'b0;
            BranchTaken = 3'b100;
        end
        5'b00111: begin		// JALR
            RegSrc = 2'b00;
            RegDst = 2'b11;
            RegWrt = 1'b1;
    
            ALUJmp = 1'b1;
            ImmSrc = 1'b1;
            BSrc = 2'b10;
            BranchTaken = 3'b100;
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