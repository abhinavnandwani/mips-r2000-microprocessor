// Just to separately write for now

   wire [1:0] RegSrc, RegDst, Bsrc;
   wire nHaltSig, ALUJmp, ALUSign, invB, invA, ALUOpr, ImmSrc, RegWrt, 0Ext, MemWrt, SpecOpr;
   assign funct = instr[1:0];

/*
	Instruction Format 			Syntax 							Semantics
	00000 xxxxxxxxxxx 			HALT 							Cease instruction issue, dump memory state to file
	00001 xxxxxxxxxxx 			NOP 							None
	
	01000 sss ddd iiiii 		ADDI Rd, Rs, immediate 			Rd <- Rs + I(sign ext.)
	01001 sss ddd iiiii 		SUBI Rd, Rs, immediate 			Rd <- I(sign ext.) - Rs
	01010 sss ddd iiiii 		XORI Rd, Rs, immediate 			Rd <- Rs XOR I(zero ext.)
	01011 sss ddd iiiii 		ANDNI Rd, Rs, immediate 		Rd <- Rs AND ~I(zero ext.)
	10100 sss ddd iiiii 		ROLI Rd, Rs, immediate 			Rd <- Rs <<(rotate) I(lowest 4 bits)
	10101 sss ddd iiiii 		SLLI Rd, Rs, immediate		 	Rd <- Rs << I(lowest 4 bits)
	10110 sss ddd iiiii 		RORI Rd, Rs, immediate 			Rd <- Rs >>(rotate) I(lowest 4 bits)
	10111 sss ddd iiiii 		SRLI Rd, Rs, immediate 			Rd <- Rs >> I(lowest 4 bits)
	10000 sss ddd iiiii 		ST Rd, Rs, immediate 			Mem[Rs + I(sign ext.)] <- Rd
	10001 sss ddd iiiii 		LD Rd, Rs, immediate 			Rd <- Mem[Rs + I(sign ext.)]
	10011 sss ddd iiiii 		STU Rd, Rs, immediate 			Mem[Rs + I(sign ext.)] <- Rd
																	Rs <- Rs + I(sign ext.)
	
	11001 sss xxx ddd xx 		BTR Rd, Rs 						Rd[bit i] <- Rs[bit 15-i] for i=0..15
	11011 sss ttt ddd 00 		ADD Rd, Rs, Rt 					Rd <- Rs + Rt
	11011 sss ttt ddd 01 		SUB Rd, Rs, Rt 					Rd <- Rt - Rs
	11011 sss ttt ddd 10 		XOR Rd, Rs, Rt 					Rd <- Rs XOR Rt
	11011 sss ttt ddd 11 		ANDN Rd, Rs, Rt 				Rd <- Rs AND ~Rt
	11010 sss ttt ddd 00 		ROL Rd, Rs, Rt 					Rd <- Rs << (rotate) Rt (lowest 4 bits)
	11010 sss ttt ddd 01 		SLL Rd, Rs, Rt 					Rd <- Rs << Rt (lowest 4 bits)
	11010 sss ttt ddd 10 		ROR Rd, Rs, Rt 					Rd <- Rs >> (rotate) Rt (lowest 4 bits)
	11010 sss ttt ddd 11 		SRL Rd, Rs, Rt 					Rd <- Rs >> Rt (lowest 4 bits)
	11100 sss ttt ddd xx 		SEQ Rd, Rs, Rt 					if (Rs == Rt) then Rd <- 1 else Rd <- 0
	11101 sss ttt ddd xx 		SLT Rd, Rs, Rt 					if (Rs < Rt) then Rd <- 1 else Rd <- 0
	11110 sss ttt ddd xx 		SLE Rd, Rs, Rt 					if (Rs <= Rt) then Rd <- 1 else Rd <- 0
	11111 sss ttt ddd xx 		SCO Rd, Rs, Rt 					if (Rs + Rt) generates carry out
																	then Rd <- 1 else Rd <- 0
	
	01100 sss iiiiiiii 			BEQZ Rs, immediate 				if (Rs == 0) then
																	PC <- PC + 2 + I(sign ext.)
	01101 sss iiiiiiii 			BNEZ Rs, immediate 				if (Rs != 0) then
																	PC <- PC + 2 + I(sign ext.)
	01110 sss iiiiiiii 			BLTZ Rs, immediate 				if (Rs < 0) then
																	PC <- PC + 2 + I(sign ext.)
	01111 sss iiiiiiii 			BGEZ Rs, immediate 				if (Rs >= 0) then
																	PC <- PC + 2 + I(sign ext.)
	11000 sss iiiiiiii 			LBI Rs, immediate 				Rs <- I(sign ext.)
	10010 sss iiiiiiii 			SLBI Rs, immediate 				Rs <- (Rs << 8) | I(zero ext.)
	
	00100 ddddddddddd 			J displacement 					PC <- PC + 2 + D(sign ext.)
	00101 sss iiiiiiii 			JR Rs, immediate 				PC <- Rs + I(sign ext.)
	00110 ddddddddddd 			JAL displacement 				R7 <- PC + 2
																	PC <- PC + 2 + D(sign ext.)
	00111 sss iiiiiiii 			JALR Rs, immediate 				R7 <- PC + 2
																	PC <- Rs + I(sign ext.)
	
	00010 						siic Rs 						produce IllegalOp exception. Must provide one source register.
	00011 xxxxxxxxxxx 			NOP / RTI 						PC <- EPC
*/
		
		case(instr[15:11])
			5'b00000: begin		// HALT
				nHaltSig = 1'b0;
			end
			5'b00001: begin		// NOP
				// none
			end
			
			/* I format 1 below: */
			
			5'b01000: begin		// ADDI
				RegSrc = 2'b10;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
				0Ext = 1'b0;
				BSrc = 2'b01;
				ALUSign = 1'b0;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b011;
				
			end
			5'b01001: begin		// SUBI
				RegSrc = 2'b10;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
				0Ext = 1'b0;
				BSrc = 2'b01;
				ALUSign = 1'b1;
                invA = 1'b1;
                invB = 1'b0;
                Cin = 1'b1;
                ALUOpr = 3'b011;
			end	
			5'b01010: begin		// XORI
				RegSrc = 2'b10;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
				0Ext = 1'b1;
				BSrc = 2'b01;
				ALUSign = 1'b1;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b011;
			end
			5'b01011: begin		// ANDNI
				RegSrc = 2'b10;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
				0Ext = 1'b1;
				BSrc = 2'b01;
				ALUSign = 1'b1;
                invA = 1'b0;
                invB = 1'b1;
                Cin = 1'b0;
                ALUOpr = 3'b011;
			end
			5'b10100: begin		// ROLI
				RegSrc = 2'b10;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
				0Ext = 1'b1;
				BSrc = 2'b01;
				ALUSign = 1'b1;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b011;
			end
			5'b10101: begin		// SLLI
				RegSrc = 2'b10;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
				0Ext = 1'b1;
				BSrc = 2'b01;
				ALUSign = 1'b1;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b011;
			end
			5'b10110: begin		// RORI
				RegSrc = 2'b10;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
				0Ext = 1'b1;
				BSrc = 2'b01;
				ALUSign = 1'b1;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b011;
			end
			5'b10111: begin		// SRLI
				RegSrc = 2'b10;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
				0Ext = 1'b1;
				BSrc = 2'b01;
				ALUSign = 1'b1;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b011;
			end
			5'b10000: begin		// ST
				RegSrc = 2'b01;
                RegDst = 2'b00;
                RegWrt = 1'b0;
                MemWrt = 1'b1;
				0Ext = 1'b1;
				BSrc = 2'b01;
				ALUSign = 1'b0;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b100;
			end
			5'b10001: begin		// LD
				RegSrc = 2'b01;
                RegDst = 2'b00;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
				0Ext = 1'b0;
				BSrc = 2'b01;
				ALUSign = 1'b0;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b100;
			end
			5'b10011: begin		// STU
				RegSrc = 2'b10;
                RegDst = 2'b01;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
				0Ext = 1'b0;
				BSrc = 2'b01;
				ALUSign = 1'b0;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b100;
			end
						
			/* R format below: */
			
			5'b11001: begin		// BTR FIX!!
				RegSrc = 2'b01;
                RegDst = 2'b00;
                RegWrt = 1'b0;
                MemWrt = 1'b1;
				0Ext = 1'b1;
				BSrc = 2'b01;
				ALUSign = 1'b0;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b100;
			end
			5'b11011: begin		// ADD, SUB, XOR, ANDN
				case(funct)
					2'b00: begin		// ADD
                        RegSrc = 2'b10;
                        RegDst = 2'b10;
                        RegWrt = 1'b1;
                        MemWrt = 1'b0;
                        BSrc = 2'b00;
                        ALUSign = 1'b1;
                        invA = 1'b0;
                        invB = 1'b0;
                        Cin = 1'b0;
                        ALUOpr = 3'b000;
					end
					2'b01: begin		// SUB
                        RegSrc = 2'b10;
                        RegDst = 2'b10;
                        RegWrt = 1'b1;
                        MemWrt = 1'b0;
                        BSrc = 2'b00;
                        ALUSign = 1'b1;
                        invA = 1'b1;
                        invB = 1'b0;
                        Cin = 1'b1;
                        ALUOpr = 3'b000;
					end
					2'b10: begin		// XOR
                        RegSrc = 2'b10;
                        RegDst = 2'b10;
                        RegWrt = 1'b1;
                        MemWrt = 1'b0;
                        BSrc = 2'b00;
                        ALUSign = 1'b1;
                        invA = 1'b0;
                        invB = 1'b0;
                        Cin = 1'b0;
                        ALUOpr = 3'b000;
					end
					2'b11: begin		// ANDN
                        RegSrc = 2'b10;
                        RegDst = 2'b10;
                        RegWrt = 1'b1;
                        MemWrt = 1'b0;
                        BSrc = 2'b00;
                        ALUSign = 1'b1;
                        invA = 1'b0;
                        invB = 1'b1;
                        Cin = 1'b0;
                        ALUOpr = 3'b000;
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
                        MemWrt = 1'b0;
                        BSrc = 2'b00;
                        ALUSign = 1'b1;
                        invA = 1'b0;
                        invB = 1'b0;
                        Cin = 1'b0;
                        ALUOpr = 3'b001;
					end
					2'b01: begin		// SLL
                        RegSrc = 2'b10;
                        RegDst = 2'b10;
                        RegWrt = 1'b1;
                        MemWrt = 1'b0;
                        BSrc = 2'b00;
                        ALUSign = 1'b1;
                        invA = 1'b0;
                        invB = 1'b0;
                        Cin = 1'b0;
                        ALUOpr = 3'b001;
					end
					2'b10: begin		// ROR
                        RegSrc = 2'b10;
                        RegDst = 2'b10;
                        RegWrt = 1'b1;
                        MemWrt = 1'b0;
                        BSrc = 2'b00;
                        ALUSign = 1'b1;
                        invA = 1'b0;
                        invB = 1'b0;
                        Cin = 1'b0;
                        ALUOpr = 3'b001;
					end
					2'b11: begin		// SRL
                        RegSrc = 2'b10;
                        RegDst = 2'b10;
                        RegWrt = 1'b1;
                        MemWrt = 1'b0;
                        BSrc = 2'b00;
                        ALUSign = 1'b1;
                        invA = 1'b0;
                        invB = 1'b0;
                        Cin = 1'b0;
                        ALUOpr = 3'b001;
					end
					default: err = 1'b1;			// R format funct code error
				endcase
			end
			5'b11100: begin		// SEQ
                RegSrc = 2'b11;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
                BSrc = 2'b00;
                ALUSign = 1'b1;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b010;
			end
			5'b11101: begin		// SLT
                RegSrc = 2'b11;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
                BSrc = 2'b00;
                ALUSign = 1'b1;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b010;
			end
			5'b11110: begin		// SLE
                RegSrc = 2'b11;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
                BSrc = 2'b00;
                ALUSign = 1'b1;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b010;
			end
			5'b11111: begin		// SCO
                RegSrc = 2'b11;
                RegDst = 2'b10;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
                BSrc = 2'b00;
                ALUSign = 1'b1;
                invA = 1'b0;
                invB = 1'b0;
                Cin = 1'b0;
                ALUOpr = 3'b010;
			end
			
			/* I format 2 below: */
			
			5'b01100: begin		// BEQZ
                RegWrt = 1'b0;
                MemWrt = 1'b0;
                ALUJmp = 1'b0;
                ImmSrc = 1'b1;
                ALUOpr = 3'b101;
			end
			5'b01101: begin		// BNEZ
                RegWrt = 1'b0;
                MemWrt = 1'b0;
                ALUJmp = 1'b0;
                ImmSrc = 1'b1;
                ALUOpr = 3'b101;
			end
			5'b01110: begin		// BLTZ
                RegWrt = 1'b0;
                MemWrt = 1'b0;
                ALUJmp = 1'b0;
                ImmSrc = 1'b1;
                ALUOpr = 3'b101;
			end
			5'b01111: begin		// BGEZ
	            RegWrt = 1'b0;
                MemWrt = 1'b0;
                ALUJmp = 1'b0;
                ImmSrc = 1'b1;
                ALUOpr = 3'b101;
			end
			5'b11000: begin		// LBI FIX
                RegWrt = 1'b0;
                MemWrt = 1'b0;
                ALUJmp = 1'b0;
                ImmSrc = 1'b1;
                ALUOpr = 3'b101;
			end
			5'b10010: begin		// SLBI FIX
                RegWrt = 1'b0;
                MemWrt = 1'b0;
                ALUJmp = 1'b0;
                ImmSrc = 1'b1;
                ALUOpr = 3'b101;
			end
			
			/* Jump Instructions below: */
			
			5'b00100: begin		// J displacement
                RegWrt = 1'b0;
                MemWrt = 1'b0;
                ALUJmp = 1'b1;
                ImmSrc = 1'b0;
			end
			5'b00101: begin		// JR
                RegWrt = 1'b0;
                MemWrt = 1'b0;
                ALUJmp = 1'b1;
                ImmSrc = 1'b1;
                //0Ext = 1'b1;
			end
			5'b00110: begin		// JAL
                RegSrc = 2'b00;
                RegDst = 2'b11;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
                ALUJmp = 1'b1;
                ImmSrc = 1'b0;
			end
			5'b00111: begin		// JALR
                RegSrc = 2'b00;
                RegDst = 2'b11;
                RegWrt = 1'b1;
                MemWrt = 1'b0;
                ALUJmp = 1'b1;
                ImmSrc = 1'b1;
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