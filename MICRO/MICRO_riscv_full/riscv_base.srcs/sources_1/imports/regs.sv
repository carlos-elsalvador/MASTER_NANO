module regs (clk,rstn,wren,wraddr,rdaddr1,rdaddr2,wrdata,rddata1,rddata2);

parameter w=32,d=32,file="regs.txt";
localparam a=$clog2(d);

input clk,rstn,wren;
input [a-1:0] wraddr,rdaddr1,rdaddr2;
input [w-1:0] wrdata;
output [w-1:0] rddata1,rddata2;

logic [0:d-1][w-1:0] regs;

always @(posedge clk, negedge rstn) 
	if (~rstn) regs <= '0;
	else if (wren&&wraddr) regs[wraddr]<=wrdata;

assign rddata1 = regs[rdaddr1];
assign rddata2 = regs[rdaddr2];

endmodule
