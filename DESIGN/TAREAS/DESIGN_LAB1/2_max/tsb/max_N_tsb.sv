import max_N_pkg::*;


module max_N_tsb;
  timeunit 1ns; timeprecision 100ps;

  // Clock period
  localparam int PER2 = 5;
  localparam int PER = 2 * PER2;

  // Ports
  logic [DATA_WIDTH-1:0] id_data_in[N];
  logic ic_val_in;
  logic ic_clk;
  logic [DATA_WIDTH-1:0] od_max;
  logic [CHAN_WIDTH-1:0] od_ch_max;
  logic oc_val_out;

  logic [DATA_WIDTH-1:0] res_max;
  logic [CHAN_WIDTH-1:0] res_ch_max;

  int unsigned error_count_max = 0;
  int unsigned error_count_ch_max = 0;

  max_N max_16_inst (
      .id_data_in(id_data_in),
      .ic_val_in(ic_val_in),
      .ic_clk(ic_clk),
      .od_max(od_max),
      .od_ch_max(od_ch_max),
      .oc_val_out(oc_val_out)
  );

  always #5 ic_clk = !ic_clk;

  initial begin
    ic_clk = 0;
    ic_val_in = 0;


    #(5 * PER);

    for (int i = 0; i < 25; i++) #(3 * PER) inputNumbersAndAssert();

    #(5 * PER);
    if (error_count_max == 0) $display("Test max passed");
    else $display("Test max failed");

    if (error_count_ch_max == 0) $display("Test ch_max passed");
    else $display("Test ch_max failed");

    $stop;

  end

  task automatic inputNumbersAndAssert();
    @(negedge ic_clk);
    for (int i = 0; i < $size(id_data_in); i++) begin
      id_data_in[i] = $urandom_range(0, 2 ** DATA_WIDTH - 1);
    end
    ic_val_in = 1;
    @(negedge ic_clk);
    ic_val_in = 0;

    if (!oc_val_out) @(posedge oc_val_out);

    max_array(id_data_in, res_max, res_ch_max);

    assert (od_max == res_max)
    else begin
      $error("Error: od_max = %h, res_max = %h", od_max, res_max);
      error_count_max++;
    end


    assert (od_ch_max == res_ch_max)
    else begin
      $error("Error: od_ch_max = %h, res_ch_max = %h", od_ch_max, res_ch_max);
      error_count_ch_max++;
    end


  endtask

  function automatic void max_array(input logic [DATA_WIDTH-1:0] data[],
                                    output logic [DATA_WIDTH-1:0] max,
                                    output logic [CHAN_WIDTH-1:0] ch_max);
    max = data[0];
    ch_max = 0;
    for (int i = 1; i < $size(data); i++) begin
      if (data[i] > max) begin
        max = data[i];
        ch_max = i;
      end
    end

  endfunction



endmodule

