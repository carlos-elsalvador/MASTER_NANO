module max_2 #(
    parameter int DATA_WIDTH = 8,  // Data word length
    parameter int CHAN_WIDTH = 3,  //Channel word length
    parameter bit PIPE_ON = 1'b1  // ON OFF registered outputs
) (
    input logic [DATA_WIDTH-1:0] id_x,  // u[DATA_WIDTH 0]: Input data x
    input logic [DATA_WIDTH-1:0] id_y,  // u[DATA_WIDTH 0]: Input data y
    input logic [CHAN_WIDTH-1:0] id_ch_x,  // u[CHAN_WIDTH 0]: Channel x
    input logic [CHAN_WIDTH-1:0] id_ch_y,  // u[CHAN_WIDTH 0]: Channel y
    input logic ic_clk,  // Clock signal
    output logic [DATA_WIDTH-1:0] od_max,  // u[DATA_WIDTH 0]: Maximum value
    output logic [CHAN_WIDTH-1:0] od_ch_max  // u[CHAN_WIDTH 0]: Channel of maximum value
);

  /* 1. Declaration zone */
logic comp;
logic [DATA_WIDTH-1:0] max_data;
logic [CHAN_WIDTH-1:0] ch_max_data; 
  /* 2. Description zone */
  assign comp = id_y >= id_x ? 1'b1 : 1'b0;
  
  generate
    if (PIPE_ON) begin
      always_ff @ (posedge ic_clk) begin 
        max_data <= comp ? id_y : id_x;
        ch_max_data <= comp ? id_ch_y : id_ch_x;
      end
    end else begin
      assign max_data = comp ? id_y : id_x;
      assign ch_max_data = comp ? id_ch_y : id_ch_x;
    end
  endgenerate
  /* 3. Output assignment */
  assign od_max = max_data;
  assign od_ch_max = ch_max_data;

endmodule
