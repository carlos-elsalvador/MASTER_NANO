module max_2_tsb ();
  timeunit 1ns; timeprecision 100ps;

  // Clock period
  localparam int PER2 = 5;
  localparam int PER = 2 * PER2;

  // Parameters
  localparam int DATA_WIDTH = 8;
  localparam int CHAN_WIDTH = 3;
  localparam bit PIPE_ON = 1'b1;

  // Ports
  logic [DATA_WIDTH-1:0] id_x, id_y;
  logic [CHAN_WIDTH-1:0] id_ch_x, id_ch_y;
  logic ic_clk;
  logic [DATA_WIDTH-1:0] od_max;
  logic [CHAN_WIDTH-1:0] od_ch_max;

  int unsigned a, b, ch_a, ch_b, max, ch_max;
  int unsigned error_count_max = 0;
  int unsigned error_count_ch_max = 0;

  max_2 #(
      .DATA_WIDTH(DATA_WIDTH),
      .CHAN_WIDTH(CHAN_WIDTH),
      .PIPE_ON(PIPE_ON)
  ) max_2 (
      .id_x(id_x),
      .id_y(id_y),
      .id_ch_x(id_ch_x),
      .id_ch_y(id_ch_y),
      .ic_clk(ic_clk),
      .od_max(od_max),
      .od_ch_max(od_ch_max)
  );

  always #PER2 ic_clk = ~ic_clk;

  initial begin
    ic_clk = 0;
    #(5 * PER);

    for (int i = 0; i < 25; i++) begin
      #(3 * PER) inputNumbersAndAssert();
    end

    #(3 * PER) $stop;
  end

  task automatic inputNumbersAndAssert();
    @(negedge ic_clk);
    id_x = $urandom_range(0, 2 ** DATA_WIDTH - 1);
    id_y = $urandom_range(0, 2 ** DATA_WIDTH - 1);
    id_ch_x = $urandom_range(0, 2 ** CHAN_WIDTH - 1);
    id_ch_y = $urandom_range(0, 2 ** CHAN_WIDTH - 1);

    if (PIPE_ON) begin
      @(posedge ic_clk);
    end

    #1;

    if (id_x >= id_y) begin
      max = id_x;
      ch_max = id_ch_x;
    end else begin
      max = id_y;
      ch_max = id_ch_y;
    end

    assert (max == od_max) $display("max=%0d, od_max=%0d OK!", max, od_max);
    else begin
      $error("Error: max=%0d, od_max=%0d", max, od_max);
      error_count_max++;
    end

    assert (ch_max == od_ch_max) $display("ch_max=%0d, od_ch_max=%0d OK!", ch_max, od_ch_max);
    else begin
      $error("Error: ch_max=%0d, od_ch_max=%0d", ch_max, od_ch_max);
      error_count_ch_max++;
    end

  endtask


endmodule
