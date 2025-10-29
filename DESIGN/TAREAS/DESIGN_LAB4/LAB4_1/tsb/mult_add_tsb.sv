`timescale 1ns / 1ps
module mult_add_tsb ();

  parameter int PER = 10;  // CLOCK PERIOD

  logic clk;
  logic val_in;
  logic val_out;
  logic signed [7:0] in_data_A, in_data_B, in_data_C;
  logic signed [8:0] out_data;
  logic signed [8:0] out_data_M, out_data_F;

  // counters and control
  integer in_sample_cnt;  // Input sample counter
  integer error_cnt;  // Error counter
  integer sample_cnt;  // Output sample counter
  logic end_sim;  // Simulation on/off indication
  logic load_data;  // Start reading data

  // I/O text management
  integer data_in_file_val;
  logic signed [23:0] data_in_file;
  integer scan_data_in;
  integer data_out_file_val;
  logic signed [8:0] data_out_file;
  integer scan_data_out;

  // Clock
  always #(PER / 2) clk = !clk & end_sim;

  // UUT
  mult_add UUT (
      .id_a  (in_data_A),
      .id_b  (in_data_B),
      .id_c  (in_data_C),
      .ic_val(val_in),
      .ic_clk(clk),
      .od_res(out_data),
      .oc_val(val_out)
  );

  initial begin
    $display("###########################################");
    $display("START TEST");
    $display("###########################################");
    //data_in_file_val  = $fopen("C:\Users\CEMARCRU\Desktop\CLASE5_DISENO\LAB4_1\mat\id_mult_add.txt", "r");
    //data_out_file_val = $fopen("C:\Users\CEMARCRU\Desktop\CLASE5_DISENO\LAB4_1\mat\od_mult_add.txt", "r");
    // data_in_file_val  = $fopen("C:\\Users\\CEMARCRU\\Desktop\\CLASE5_DISENO\\LAB4_1\\mat\\id_mult_add.txt", "r");
    // data_out_file_val = $fopen("C:\\Users\\CEMARCRU\\Desktop\\CLASE5_DISENO\\LAB4_1\\mat\\od_mult_add.txt", "r");

    data_in_file_val  = $fopen("C:\\Users\\CEMARCRU\\Desktop\\CLASE5_DISENO\\LAB4_1\\sim\\iof\\id_mult_add.txt", "r");
    data_out_file_val = $fopen("C:\\Users\\CEMARCRU\\Desktop\\CLASE5_DISENO\\LAB4_1\\sim\\iof\\od_mult_add.txt", "r");




    assert (data_in_file_val && data_out_file_val)
    else begin
      $display("Error opening file");
      $stop;
    end
    end_sim = 1'b1;
    error_cnt = 0;
    sample_cnt = 0;
    in_sample_cnt = 0;
    clk = 1'b1;
    val_in = 1'b0;
    load_data = 1'b0;
    #(10 * PER);
    load_data = 1'b1;
  end

  // Input data reading process
  always @(posedge clk)
    if (load_data) begin
      if (!$feof(data_in_file_val)) begin
        in_sample_cnt = in_sample_cnt + 1;
        scan_data_in  = $fscanf(data_in_file_val, "%b", data_in_file);
        in_data_A <= #(PER / 10) data_in_file[23:16];
        in_data_B <= #(PER / 10) data_in_file[15:8];
        in_data_C <= #(PER / 10) data_in_file[7:0];
        val_in <= #(PER / 10) 1'b1;
      end else begin
        val_in <= #(PER / 10) 1'b0;
        load_data = #(PER / 10) 1'b0;
        end_sim   = #(10 * PER) 1'b0;  // Must leave a number of periods
        $display(" Number of input samples ", "%d", in_sample_cnt);
      end
    end

  // Output data reading process
  always @(posedge clk)
    if (val_out) begin
      sample_cnt = sample_cnt + 1;
      if (!$feof(data_out_file_val)) begin
        scan_data_out = $fscanf(data_out_file_val, "%b", data_out_file);
        out_data_F <= #(PER / 10) data_out_file;  // File output
        out_data_M <= #(PER / 10) out_data;  // UUT output
      end else end_sim = #(10 * PER) 1'b0;
    end

  // Error and sample counter
  always @(out_data_F, out_data_M)
    Assert_error_out :
    assert (out_data_F == out_data_M)
    //$display("OK ","%d", sample_cnt);
    else begin
      error_cnt = error_cnt + 1;
      $display("Error in sample number ", "%d", sample_cnt);
    end

  // End of simulation
  always @(end_sim)
    if (!end_sim) begin
      $display("########################################### ");
      $display("Number of checked samples ", "%d", sample_cnt);
      $display("Number of errors ", "%d", error_cnt);
      $display("########################################### ");
      #(PER * 2) $stop;
    end
endmodule
