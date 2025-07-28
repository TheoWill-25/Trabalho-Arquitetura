`timescale 1ns / 1ps

module ALUController (
    //Inputs
    input logic [1:0] ALUOp,  // 2-bit opcode field from the Controller--00: LW/SW/AUIPC; 01:Branch; 10: Rtype/Itype; 11:JAL/LUI
    input logic [6:0] Funct7,  // bits 25 to 31 of the instruction
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction

    //Output
    output logic [3:0] Operation  // operation selection for ALU
);

  assign Operation[0] = ((ALUOp == 2'b10) && (Funct3 == 3'b110)) ||  // or
      ((ALUOp == 2'b10) && (Funct3 == 3'b100)) || // XOR
      ((ALUOp == 2'b01) && (Funct3 == 3'b001)) || // BNE
      ((ALUOp == 2'b01) && (Funct3 == 3'b101)) || // BGE
      ((ALUOp == 2'b10) && (Funct3 == 3'b001)) || // SLLI
      ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000)) || // SRAI
      ((ALUOp == 2'b11)); // JAL/JALR

  assign Operation[1] = (ALUOp == 2'b00) ||  // load/store
      ((ALUOp == 2'b10) && (Funct3 == 3'b000)) ||  // ADD
      ((ALUOp == 2'b01) && (Funct3 == 3'b100)) || // BLT
      ((ALUOp == 2'b01) && (Funct3 == 3'b101)) || // BGE
      ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000)) || // SRLI
      ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000)) || // SRAI
      ((ALUOp == 2'b11)); // JAL/JALR

  assign Operation[2] = ((ALUOp == 2'b10) && (Funct3 == 3'b000) && (Funct7 == 7'b0100000)) || // SUB
      ((ALUOp == 2'b10) && (Funct3 == 3'b100)) || // XOR
      ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000)) ||  // SRAI
      ((ALUOp == 2'b10) && (Funct3 == 3'b001)) || // SLLI
      ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000)) || // SRLI
      ((ALUOp == 2'b10) && (Funct3 == 3'b010)) ||  // SLTI/SLT
      ((ALUOp == 2'b11) && (Funct3 == 3'b000)); // JALR

  assign Operation[3] = (ALUOp == 2'b01) ||  // BEQ/BNE/BLT/BGE
      ((ALUOp == 2'b10) && (Funct3 == 3'b001)) || // SSLI
      ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000)) || // SRLI
      ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000)); // SRAI
endmodule

/*
0000 = AND
0001 = OR
0010 = ADD/ADDI
0011 = JAL
0100 = SLTI/SLT
0101 = XOR
0110 = SUB
0111 = JALR
1000 = BEQ/equal
1001 = BNE
1010 = BLT
1011 = BGE
1100
1101 = SLLI
1110 = SRLI
1111 = SRAI
*/