`timescale 1ns/1ps

module riscv_gpio_tb();

parameter T=20;
parameter w=32;

// Paths are relative to the project_1.sim/sim_2/behav/xsim folder
parameter from="../../../../riscv_txt/rom_fibonacci.txt"; 
parameter fram="../../../../riscv_txt/ram_fibonacci.txt";


reg clk,rstn;
wire [w-1:0] pc;    // program counter
wire [w-1:0] inst;  // instruction from rom
wire [w-1:0] dat;    // read data (from ram or from gpio)
wire [w-1:0] dout;  // data writen to gpio 
logic [w-1:0] din = 0;    // data read from gpio 

localparam d = 64;
logic [w-1:0] ram_mem [d/4];
logic [31:0][w-1:0] regs;

riscv_gpio  #(.from(from),.fram(fram),.d(d),.r(32)) riscv_gpio (.*);
always @(riscv_gpio.ram.mem) for (i=0;i<d/4;i++) ram_mem[i]={riscv_gpio.ram.mem[i*4+3],riscv_gpio.ram.mem[i*4+2],riscv_gpio.ram.mem[i*4+1],riscv_gpio.ram.mem[i*4]};
assign regs=riscv_gpio.riscv_core.regs.regs;

int i=0;
int n=0;
int n1=0;
int n2=1;

always #T clk=~clk;


initial 
begin
	clk='b0;
	rstn='b0;
	repeat(2)@(negedge clk);
	rstn='b1;
	repeat(10) 
	begin
        wait (inst=='hfe0006e3); // final program fibonacci
        n=n1+n2;n1=n2;n2=n;i=i+1;
        $info("Iteracion %d: %d",i,n);
        repeat(2)@(negedge clk);
    end
	$stop;
end

endmodule
