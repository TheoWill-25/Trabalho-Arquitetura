`timescale 1ns / 1ps

module datamemory #(
    parameter DM_ADDRESS = 9,
    parameter DATA_W = 32
) (
    input logic clk,
    input logic MemRead,  // comes from control unit
    input logic MemWrite,  // Comes from control unit
    input logic [DM_ADDRESS - 1:0] a,  // Read / Write address - 9 LSB bits of the ALU output
    input logic [DATA_W - 1:0] wd,  // Write Data
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction
    output logic [DATA_W - 1:0] rd  // Read Data
);

  logic [31:0] raddress;
  logic [31:0] waddress;
  logic [31:0] Datain;
  logic [31:0] Dataout;
  logic [ 3:0] Wr;
  logic [31:0] DeslocB;
  logic [31:0] DeslocH;

  Memoria32Data mem32 (
      .raddress(raddress),
      .waddress(waddress),
      .Clk(~clk),
      .Datain(Datain),
      .Dataout(Dataout),
      .Wr(Wr)
  );

  always_ff @(*) begin
    raddress = {{22{1'b0}}, a};
    waddress = {{22{1'b0}}, {a[8:2], {2{1'b0}}}};
    Datain = wd;
    Wr = 4'b0000;

    if (MemRead) begin
      case (Funct3)
        3'b000:  //LB
        if(a[1:0] == 2'b00) rd <= (Dataout[7] == 1) ? {(24'hfff), Dataout[7:0]} : Dataout[7:0];
        else if(a[1:0] == 2'b01) rd <= (Dataout[15] == 1) ? {(24'hfff), Dataout[15:8]} : Dataout[15:8];
        else if(a[1:0] == 2'b10) rd <= (Dataout[23] == 1) ? {(24'hfff), Dataout[23:16]} : Dataout[23:16];
        else if(a[1:0] == 2'b11) rd <= (Dataout[31] == 1) ? {(24'hfff), Dataout[31:24]} : Dataout[31:24];
        3'b100:  //LBU
        if(a[1:0] == 2'b00) rd <= Dataout[7:0];
        else if(a[1:0] == 2'b01) rd <= Dataout[15:8];
        else if(a[1:0] == 2'b10) rd <= Dataout[23:16];
        else if(a[1:0] == 2'b11) rd <= Dataout[31:24];
        3'b001:   //LH
        if(a[1:0] == 2'b00) rd <= (Dataout[15] == 1) ? {(16'hff), Dataout[31:16]} : Dataout[31:16];
        else if(a[1:0] == 2'b10) rd <= (Dataout[31] == 1) ? {(16'hff), Dataout[31:16]} : Dataout[31:16];
        3'b010:  //LW
        rd <= Dataout;
        default: rd <= Dataout;
      endcase
    end else if (MemWrite) begin
      case (Funct3)
        3'b000: begin  //SB
          Wr <= 4'b0001 << a[1:0];
          Datain <= wd;
        end
        3'b001: begin  //SH
          Wr <= 4'b0011 << (a[1] * 2);
          Datain <= wd;
        end
        3'b010: begin  //SW
          Wr <= 4'b1111;
          Datain <= wd;
        end
        default: begin
          Wr <= 4'b1111;
          Datain <= wd;
        end
      endcase
    end
  end

endmodule
