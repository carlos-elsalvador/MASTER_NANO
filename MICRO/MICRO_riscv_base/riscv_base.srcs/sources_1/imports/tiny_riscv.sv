//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2024 02:39:35 PM
// Design Name: 
// Module Name: tiny_riscv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tiny_riscv(
    input clk_100MHz,
    input [0:0] BTN,
    input [15:0] SW,
    output [7:0] D1_SEG,
    output [7:0] D0_SEG,
    output reg [3:0] D1_AN,
    output reg [3:0] D0_AN
);
parameter from="../../../riscv_txt/rom_7seg.txt";
parameter fram="../../../riscv_txt/ram_7seg.txt";
parameter w=32,d=128,r=32;
logic[31:0] seven_seg_values;
logic clk10;

riscv_gpio #(.from(from), .fram(fram),.w(w),.d(d),.r(r)) riscv_gpio
(
    .clk(clk10),
    .rstn(!BTN), //1'b1
    .inst(), //Open
    .dat(),  //Open
    .pc(),   //Open
    .din({16'h0, SW}),
    .dout(seven_seg_values)
);

 clk_wiz_0 inst
  (
  // Clock out ports  
  .clk_out1(clk10),
  // Status and control signals               
  .reset(BTN),  //1'b0
  .locked(),
 // Clock in ports
  .clk_in1(clk_100MHz)
  );

top_hex_decoder #() seven_seg_decoder(
    .data_hex(seven_seg_values),
    .clk_100MHz(clk10),
    .BTN(BTN), //1'b0
    .D1_SEG(D1_SEG),
    .D0_SEG(D0_SEG),
    .D1_AN(D1_AN),
    .D0_AN(D0_AN)
);
endmodule
