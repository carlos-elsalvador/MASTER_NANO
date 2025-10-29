//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2024 03:20:16 PM
// Design Name: 
// Module Name: riscv_gpio
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


module riscv_gpio(clk,rstn,pc,inst,dat,din,dout);

parameter from="../../../riscv_txt/rom_7seg.txt";
parameter fram="../../../riscv_txt/ram_7seg.txt";
parameter w=32,d=128,r=32;
localparam a=$clog2(d);

input clk,rstn;
output logic [w-1:0] inst,dat,pc;
input logic [w-1:0] din;
output logic [w-1:0] dout;

logic wr,wr_mem,wr_gpio;
logic [w-1:0] wra;
logic [a-1:0] wra_mem,wra_gpio;
logic [w-1:0] wrd,wrd_mem,wrd_gpio;
logic [w-1:0] dat_mem,dat_gpio;

riscv_core #(.w(w),.d(d),.r(r), .from(from), .fram(fram)) riscv_core
(
	.clk(clk),
	.rstn(rstn),
	.pc(pc),
	.inst(inst),
	.wr(wr),
	.wrd(wrd),
	.wra(wra),
	.dat(dat)
);

mymap #(.w(w),.d(d)) mymap
(
	.wren(wr),
	.daddr(wra),
	.rddata(dat),
	.wrdata(wrd),
	.wren_mem(wr_mem),
	.daddr_mem(wra_mem),
	.rddata_mem(dat_mem),
	.wrdata_mem(wrd_mem),
	.wren_gpio(wr_gpio),
	.daddr_gpio(wra_gpio),
	.rddata_gpio(dat_gpio),
	.wrdata_gpio(wrd_gpio)
);

ram #(.w(w),.d(d),.file(fram)) ram
(
	.clk(clk),
	.wren(wr_mem),
	.daddr(wra_mem),
	.rddata(dat_mem),
	.wrdata(wrd_mem),
	.op (inst[14:12])
);

gpio #(.w(w),.d(d)) gpio
(
	.clk(clk),
	.wren(wr_gpio),
	.rstn(rstn),
	.daddr(wra_gpio),
	.rddata(dat_gpio),
	.wrdata(wrd_gpio),
	.din(din),
	.dout(dout)
);

endmodule
