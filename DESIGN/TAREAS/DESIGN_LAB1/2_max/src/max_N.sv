import max_N_pkg::*;

module max_N (
    input logic [DATA_WIDTH-1:0] id_data_in[N],  // u[DATA_WIDTH 0]: Input data x
    input logic ic_val_in,  // Control input for data validation
    input logic ic_clk,  // Clock signal
    output logic [DATA_WIDTH-1:0] od_max,  // u[DATA_WIDTH 0]: Maximum value
    output logic [CHAN_WIDTH-1:0] od_ch_max,  // u[CHAN_WIDTH 0]: Channel of maximum value
    output logic oc_val_out  // Control output for data validation
);

  /* 0. Parameters check */
  initial
    assert (N == 2 ** STAGES_NUM)  // Check if N is power of 2
    else $error("INPUTS_NUM must be power of 2");
  /*---------------------------------------------------
   * 1. Declaration zone
   *---------------------------------------------------*/
  logic [DATA_WIDTH-1:0] max_data [STAGES_NUM+1][N];
  logic [CHAN_WIDTH-1:0] max_ch   [STAGES_NUM+1][N];
  logic val_stage [STAGES_NUM+1];

  /*---------------------------------------------------
   * 2. Description zone
   *---------------------------------------------------*/

  // 2.1 Stage 0 initialization
  genvar i;
  generate
    for (i = 0; i < N; i++) begin
      assign max_data[0][i] = id_data_in[i];
      assign max_ch[0][i]   = i[CHAN_WIDTH-1:0];
    end
  endgenerate

  assign val_stage[0] = ic_val_in;

  // 2.2 Generate all comparison stages
  genvar stage, j;
  generate
    for (stage = 0; stage < STAGES_NUM; stage++) begin : gen_stages
      localparam int NUM_ELEMS = N >> stage;  // # of elements in this stage
      localparam bit PIPE_ON = VPIPE_ON[stage];

      for (j = 0; j < NUM_ELEMS/2; j++) begin : gen_comparators
        max_2 #(
          .DATA_WIDTH(DATA_WIDTH),
          .CHAN_WIDTH(CHAN_WIDTH),
          .PIPE_ON(PIPE_ON)
        ) compa (
          .id_x     (max_data[stage][2*j]),
          .id_y     (max_data[stage][2*j+1]),
          .id_ch_x  (max_ch[stage][2*j]),
          .id_ch_y  (max_ch[stage][2*j+1]),
          .ic_clk   (ic_clk),
          .od_max   (max_data[stage+1][j]),
          .od_ch_max(max_ch[stage+1][j])
        );
      end

      // Valid signal pipeline control
      if (PIPE_ON)
        always_ff @(posedge ic_clk)
          val_stage[stage+1] <= val_stage[stage];
      else
        assign val_stage[stage+1] = val_stage[stage];
    end
  endgenerate

  /*---------------------------------------------------
   * 3. Output assignment
   *---------------------------------------------------*/
  assign od_max     = max_data[STAGES_NUM][0];
  assign od_ch_max  = max_ch[STAGES_NUM][0];
  assign oc_val_out = val_stage[STAGES_NUM];

endmodule

