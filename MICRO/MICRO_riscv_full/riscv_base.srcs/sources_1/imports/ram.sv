module ram (clk,wren,op,daddr,rddata,wrdata);

parameter w=32,d=1024,file="ram.txt";
localparam a=$clog2(d);

input clk,wren;
input [2:0] op;
input [a-1:0] daddr;
input [w-1:0] wrdata;
output [w-1:0] rddata;

logic [7:0] mem [d];
logic [w-1:0] data;
	
initial $readmemh(file,mem);

always @(posedge clk) begin
    if (wren) begin
        casex(op[1:0])
            2'b00: 
	        mem[daddr]   <= wrdata[7:0];
            2'b01: begin
                mem[daddr]   <= wrdata[7:0];
                mem[daddr+1] <= wrdata[16:8];
            end
            2'b1?: begin
                mem[daddr]   <= wrdata[7:0];
                mem[daddr+1] <= wrdata[15:8];
                mem[daddr+2] <= wrdata[23:16];
                mem[daddr+3] <= wrdata[31:24];
            end
        endcase
    end
end
always @(*)begin
    //if (ren) begin
        casex(op)
            3'b000: begin
                data[7:0]    <= mem[daddr];
                data[w-1:8]  <= {24{data[7]}};
                end
            3'b100: begin
                data[7:0]    <= mem[daddr];
                data[w-1:8]  <= 0;
                end
            3'b001: begin
                data[7:0]    <= mem[daddr];
                data[15:8]   <= mem[daddr+1];
                data[w-1:16] <= {16{data[15]}};
            	end
            3'b101: begin
                data[7:0]    <= mem[daddr];
                data[15:8]   <= mem[daddr+1];
                data[w-1:16] <= 0;
            end
            default: begin
                data[7:0]   <= mem[daddr];
                data[15:8]  <= mem[daddr+1];
                data[23:16] <= mem[daddr+2];
                data[31:24] <= mem[daddr+3];
            end
        endcase
    //end
end
assign rddata = data;

endmodule
