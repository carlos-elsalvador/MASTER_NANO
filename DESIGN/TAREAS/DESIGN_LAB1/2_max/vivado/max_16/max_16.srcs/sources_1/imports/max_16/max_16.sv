module max_16 #(
    parameter int DATA_WIDTH = 8,  // Data word length
    parameter int CHAN_WIDTH = $clog2(16), // Channel    
    parameter bit [0:3] VPIPE_ON = 4'b1010  // ON OFF registered outputs vector
) (
    input logic [DATA_WIDTH-1:0] id_data_in[16],  // u[DATA_WIDTH 0]: Input data x
    input logic ic_val_in,  // Control input for data validation
    input logic ic_clk,  // Clock signal
    output logic [DATA_WIDTH-1:0] od_max,  // u[DATA_WIDTH 0]: Maximum value
    output logic [CHAN_WIDTH-1:0] od_ch_max,  // u[CHAN_WIDTH 0]: Channel of maximum value
    output logic oc_val_out  // Control output for data validation
);

  /* 0. Constants */
  //localparam int CHAN_WIDTH = $clog2(16);  // 4  This line was moved to become a module's parameter

  /* 1. Declaration zone */
localparam STAGE_1 = 8;
localparam STAGE_2 = 4;
localparam STAGE_3 = 2;
 // First stage signals (8 winners)
logic       [DATA_WIDTH-1:0] max_stage_1    [STAGE_1-1:0];
logic       [CHAN_WIDTH-1:0] max_ch_stage_1 [STAGE_1-1:0];
 // Second stage signals (4 winners)
logic       [DATA_WIDTH-1:0] max_stage_2    [STAGE_2-1:0];
logic       [CHAN_WIDTH-1:0] max_ch_stage_2 [STAGE_2-1:0];
 // Third stage signals (2 winners)
logic       [DATA_WIDTH-1:0] max_stage_3    [STAGE_3-1:0];
logic       [CHAN_WIDTH-1:0] max_ch_stage_3 [STAGE_3-1:0];
  // Fourth / final stage signals (single winner)
logic       [DATA_WIDTH-1:0] max_stage_4;
logic       [CHAN_WIDTH-1:0] max_ch_stage_4;

// Validation pipeline (to align oc_val_out)
logic [3:0] val_pipe;

/* 2. Description zone */

// First stage: 8 max_2 blocks compare inputs in pairs.
generate
  for (genvar i = 0; i < STAGE_1; i++) begin : gen_stage_1
    max_2 #(
      .DATA_WIDTH(DATA_WIDTH),
      .CHAN_WIDTH(CHAN_WIDTH),
      .PIPE_ON(VPIPE_ON[0])
      ) compa_stage_1(
      .id_x(id_data_in[i*2]),
      .id_y(id_data_in[2*i+1]),
      .id_ch_x(CHAN_WIDTH'(2*i)),
      .id_ch_y(CHAN_WIDTH'(2*i+1)),
      .ic_clk(ic_clk),
      .od_max(max_stage_1[i]),
      .od_ch_max(max_ch_stage_1[i])
    );
  end
endgenerate

  // Second stage: 4 max_2 blocks compare the winners.
  generate
   for (genvar i = 0; i < STAGE_2; i++) begin : gen_stage_2
    max_2 #(
    .DATA_WIDTH(DATA_WIDTH),
    .CHAN_WIDTH(CHAN_WIDTH),
    .PIPE_ON(VPIPE_ON[1])
      ) compa_stage_2(
      .id_x(max_stage_1[i*2]),
      .id_y(max_stage_1[2*i+1]),
      .id_ch_x(max_ch_stage_1[2*i]),
      .id_ch_y(max_ch_stage_1[2*i+1]),
      .ic_clk(ic_clk),
      .od_max(max_stage_2[i]),
      .od_ch_max(max_ch_stage_2[i])
    );
   end
  endgenerate

// Third stage: 2 max_2 blocks compare winners.
  generate
   for (genvar i = 0; i < STAGE_3; i++) begin : gen_stage_3
    // compare pairs of stage_2 winners: (0,1) and (2,3)
    max_2 #(
    .DATA_WIDTH(DATA_WIDTH),
    .CHAN_WIDTH(CHAN_WIDTH),
    .PIPE_ON(VPIPE_ON[2])
      ) compa_stage_3(
      .id_x(max_stage_2[i*2]),
      .id_y(max_stage_2[2*i+1]),
      .id_ch_x(max_ch_stage_2[i*2]),
      .id_ch_y(max_ch_stage_2[2*i+1]),
      .ic_clk(ic_clk),
      .od_max(max_stage_3[i]),
      .od_ch_max(max_ch_stage_3[i])
    );
   end
  endgenerate  

// Fourth stage: 1 max_2 block selects the final maximum.  Compare the two stage_3 winners
  max_2 #(
    .DATA_WIDTH(DATA_WIDTH),
    .CHAN_WIDTH(CHAN_WIDTH),
    .PIPE_ON(VPIPE_ON[3])
    ) compa_stage_4(
    .id_x(max_stage_3[0]),
    .id_y(max_stage_3[1]),
    .id_ch_x(max_ch_stage_3[0]),
    .id_ch_y(max_ch_stage_3[1]),
    .ic_clk(ic_clk),
    .od_max(max_stage_4),
    .od_ch_max(max_ch_stage_4)
  );

  // 3.1 Validation pipeline
  always_ff @(posedge ic_clk) begin
    val_pipe[0] <= ic_val_in;
    for (int i = 1; i < 4; i++) begin
      if (VPIPE_ON[i-1])
        val_pipe[i] <= val_pipe[i-1];
      else
        val_pipe[i] <= val_pipe[i]; // hold if not pipelined
    end
  end
// 3.2 Output assignment 
  assign od_max = max_stage_4;
  assign od_ch_max = max_ch_stage_4;  
  assign oc_val_out = ic_val_in;    

endmodule

// 2-input maximum finder
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
