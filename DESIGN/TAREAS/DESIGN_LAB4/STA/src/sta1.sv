module sta1 (
    input [15:0] id_x1,
    input [15:0] id_x2,
    input clk,
    output logic [15:0] od_sa,
    output logic [15:0] od_sb,
    output logic [15:0] od_sd
  );

  logic [15:0] regx1, regx2;
  logic [15:0] add, sub;

  assign add = regx1 + regx2;
  assign sub = regx1 - regx2;

  always_ff @ (posedge clk)
  begin
    regx1 <= id_x1;
    regx2 <= id_x2;
    od_sd <= regx1;
    od_sa <= add * sub;
    od_sb <= regx1 * regx2;
  end

endmodule
