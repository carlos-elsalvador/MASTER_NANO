//`timescale 1ns / 1ps 

module gcf_tsb ();
  timeunit 1ns; timeprecision 100ps;

  parameter int MPER = 5;
  parameter int PER = 2 * MPER;

  parameter int N = 8;

  logic clk, rstn;
  logic val_in;
  logic [N-1:0] x, y;

  logic val_out, busy;
  logic [N-1:0] gcd;

  logic [N-1:0] res_gcd_model;
  int unsigned error_count = 0;

  always #MPER clk = ~clk;

  gcd #(
      .N(N)
  ) uut (
      .id_x(x),
      .id_y(y),
      .ic_val(val_in),
      .ic_clk(clk),
      .ic_rstn(rstn),
      .oc_val(val_out),
      .oc_busy(busy),
      .od_gcd(gcd)
  );

// ** AGREGAR BLOQUE PARA VOLCADO DE SEÑALES (DUMPING) **
    initial begin
        $dumpfile("dump.vcd");// Nombre del archivo de volcado
        $dumpvars(0, uut); // volcar todas las señales en el scope
    end



  initial begin
    clk = 0;
    rstn = 1;
    val_in = 0;
    x = 0;
    y = 0;

    #(5 * PER) @(posedge clk) #(PER / 10) rstn = 0;
    @(posedge clk) #(PER / 10) rstn = 1;


    for (int i = 0; i < 30; i++) begin
      #(5 * PER) sendAndAssertGCD($urandom_range(1, 2 ** N - 1), $urandom_range(1, 2 ** N - 1));
    end

    $display("Simulation finished. Error count: %d", error_count);
    #(10 * PER) $stop;

  end

  task automatic sendAndAssertGCD(input logic [N-1:0] x_in, input logic [N-1:0] y_in);
    @(posedge clk) #(PER / 10) val_in = 1;
    x = x_in;
    y = y_in;
    @(posedge clk) #(PER / 10) val_in = 0;


    @(posedge val_out);

    res_gcd_model = gcd_model(x_in, y_in);

    assert (gcd == res_gcd_model)
    else begin
      $error("gcd_1 != gcd_in. Expected: %d, Obtained: %d", res_gcd_model, gcd);
      error_count++;
    end

  endtask  //

  function automatic logic [N-1:0] gcd_model(input logic [N-1:0] x, input logic [N-1:0] y);
    logic [N-1:0] x_aux, y_aux;
    x_aux = x;
    y_aux = y;
    while (x_aux != y_aux) begin
      if (x_aux > y_aux) x_aux = x_aux - y_aux;
      else y_aux = y_aux - x_aux;
    end
    return x_aux;

  endfunction
endmodule
