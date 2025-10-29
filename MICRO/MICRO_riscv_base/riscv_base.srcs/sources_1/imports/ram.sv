module ram (clk,wren,daddr,rddata,wrdata);

parameter w=32,d=1024,file="ram.txt";
localparam a=$clog2(d);

input clk,wren;
input [a-1:0] daddr;
input [w-1:0] wrdata;
output [w-1:0] rddata;

logic [w-1:0] mem [d];
	
initial $readmemh(file,mem);

always @(posedge clk) if (wren) mem[daddr]<=wrdata;
assign rddata = mem[daddr];

endmodule
