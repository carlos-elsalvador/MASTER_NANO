`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2024 03:39:07 PM
// Design Name: 
// Module Name: mymap
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


module mymap(wren,daddr,rddata,wrdata,wren_mem,daddr_mem,rddata_mem,wrdata_mem,wren_gpio,daddr_gpio,rddata_gpio,wrdata_gpio);
parameter w=32,d=1024;
localparam a=$clog2(d);

input wren; //When a write is performed in memory sw/sh/sb
input [w-1:0] daddr; //address of memory access
input [w-1:0] wrdata; //data to write to memory
output logic [w-1:0] rddata; //data read from memory???
output logic wren_mem; //write enable memory
output logic [a-1:0] daddr_mem; 
output logic [w-1:0] wrdata_mem;
input [w-1:0] rddata_mem;
output logic wren_gpio;
output logic [a-1:0] daddr_gpio;
output logic [w-1:0] wrdata_gpio;
input [w-1:0] rddata_gpio;

assign daddr_mem = daddr[(a-1):0];
assign wren_mem = (daddr<d)? wren:0;
assign wrdata_mem = wrdata;
assign rddata = daddr<d? rddata_mem:rddata_gpio;
assign wren_gpio = daddr>=d? wren:0;
assign wrdata_gpio = wrdata;
assign daddr_gpio = daddr[(a-1)+2:2];

endmodule