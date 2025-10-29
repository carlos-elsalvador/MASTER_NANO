module rom (rdaddr, rddata);

parameter w=32,d=1024,file="rom.txt";
localparam a=$clog2(d);

input [a-1:0] rdaddr;
output [w-1:0] rddata;
	
logic [w-1:0] mem [d];
	
initial $readmemh(file,mem);
assign rddata = mem[rdaddr];

endmodule
