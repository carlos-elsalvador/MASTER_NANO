module mult_add (
    input logic signed [7:0] id_a,  // S[8 7]
    input logic signed [7:0] id_b,  // S[8 7]
    input logic signed [7:0] id_c,  // S[8 7]
    input logic ic_val,
    input logic ic_clk,
    output logic signed [8:0] od_res,  // S[16]
    output logic oc_val
);

  /* 1. Declaration zone */
logic  signed [15:0] add_res;

//Vaiables Truncado
logic  ic_val_reg;
logic signed [8:0] add_res_trunc;  // 4.1.4 S[9 7]


  /* 2. Description zone */
always_ff @(posedge ic_clk) begin
  if (ic_val ) begin
           //  (id_a * id_b) S[16,14] +  (id_c <<< 7) S[15,14]
    add_res <= (id_a * id_b) + (id_c <<< 7);  // Resultado  S[16,14]
    add_res_trunc <= add_res[15:7];  // Truncar a S[9 7]
  end
  ic_val_reg <= ic_val; // Doble registro considerando truncado
  oc_val <= ic_val_reg;
end

  /* 3. Output zone */
  assign  od_res  = add_res_trunc;
endmodule





// module mult_add (
//     input logic signed [7:0] id_a,  // S[8 7]
//     input logic signed [7:0] id_b,  // S[8 7]
//     input logic signed [7:0] id_c,  // S[8 7]
//     input logic ic_val,
//     input logic ic_clk,
//     output logic signed [15:0] od_res,  // S[16]
//     output logic oc_val
// );

//   /* 1. Declaration zone */
// logic  signed [15:0] add_res;

//   /* 2. Description zone */
// always_ff @(posedge ic_clk) begin
//   if (ic_val ) begin
//            //  (id_a * id_b) S[16,14] +  (id_c <<< 7) S[15,14]
//     add_res <= (id_a * id_b) + (id_c <<< 7);  // Resultado  S[16,14]
//   end
//   oc_val <= ic_val;
// end

//   /* 3. Output zone */
//   assign  od_res  = add_res;
// endmodule
