module gpio(clk,wren,rstn,daddr,rddata,wrdata,din,dout);

parameter w=32,d=1024;
localparam a=$clog2(d);

input clk,wren, rstn;
input [a-1:0] daddr;
input [w-1:0] wrdata;
output logic [w-1:0] rddata;
input [w-1:0] din;
output logic [w-1:0] dout;


always @(posedge clk)begin
    if(!rstn) begin
        dout <= 0;
        rddata <= 0;
    end
    else if (wren) dout<=wrdata;
    else rddata<=din;
end
endmodule
