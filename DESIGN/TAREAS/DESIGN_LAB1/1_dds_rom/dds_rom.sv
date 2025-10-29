module dds_rom (
    input  [7:0] id_step,    // u[8 0]: Step input
    input  [7:0] id_addr,    // u[8 0]: Address input
    input        ic_rst,     // Active-high synchronous reset
    input        ic_val,     // Control input for data validation
    input        ic_clk,     // Clock signal
    input        ic_sel,     // Mux select signal
    output [7:0] od_signal,  // u[8 0]: Registered output signal from ROM
    output       oc_val      // Control output for data validation
);

  /*  1. Declaration zone */
// b0: Accumulator and mux signals
logic [7:0] b0_counter;
logic [7:0] b0_mux;
// b1: ROM and its output register
logic [7:0] b1_rom;
logic [7:0] b1_rom_r;
// b2: Validation signal registers
logic b2_val_r, b2_val_rr;

/* 2. Description zone */
// b0: Accumulator and mux block
  always_ff @ (posedge ic_clk) begin
    if (ic_rst)
      b0_counter <= 8'd0;
    else
      b0_counter <= b0_counter + id_step;
  end
// b0: Mux logic (select between accumulator and address)
assign b0_mux = ic_sel ? id_addr : b0_counter;
  // b1: ROM instantiation
ROM b1_memmory(
    .ic_addr(b0_mux), 
    .od_rom(b1_rom)
    );
// b1: Register ROM output
  always_ff @(posedge ic_clk) begin
    if (ic_rst)
      b1_rom_r <= 8'd0;
    else
      b1_rom_r <= b1_rom;
  end
  // b3: Double register ic_val
  always_ff @(posedge ic_clk) begin
    if (ic_rst) begin
      b2_val_r  <= 1'b0;
      b2_val_rr <= 1'b0;
    end else begin
      b2_val_r  <= ic_val;
      b2_val_rr <= b2_val_r;
    end
  end

  /* 3. Output assignment */
  assign od_signal = b1_rom_r;  // Registered ROM output
  assign oc_val    = b2_val_rr; // Double-registered validation signal


endmodule

module ROM (
    input  [7:0] ic_addr,
    output [7:0] od_rom
);

endmodule

