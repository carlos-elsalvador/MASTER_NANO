`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2024 03:23:21 PM
// Design Name: 
// Module Name: riscv_core
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


module riscv_core(clk,rstn,pc,inst,wra,wr,wrd,dat);


parameter w=32,d=1024,r=32;
localparam o=4;
localparam a=$clog2(d);
parameter from="rom.txt";
parameter fram="ram.txt";
parameter fregs="regs.txt";

input clk,rstn;
output logic [w-1:0] pc = 0;
output wr;
output [w-1:0]wra,wrd;
output [w-1:0] inst;
input [w-1:0] dat;

logic branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write, branch_val, branch_jalr, lui, pc_alu; //mem_read is not used
logic [1:0] aluop;
logic aluz; logic [3:0] alu_cont_input; //alu zero result and alu_op input
logic [w-1:0] imm1; //immediate from ImmGen
logic [w-1:0] rin; //data to write into registers
logic [w-1:0] rd1;
logic [w-1:0] rd2; //data read from registers
logic [w-1:0] alu_r; //alu result
logic [w-1:0] rd1_pc_or_reg; //result of mux driven by PCALU
logic [w-1:0] alu_src1; // result of mux driven by LUI
logic [w-1:0] alu_src2;  // result of mux ALUSRC

assign wra = alu_r;
assign wrd = rd2;
assign wr = mem_write;

//BVgen
always@(*)begin
    casex(inst[14:12])
        'b000: branch_val = 'b0; //BEQ
        'b001: branch_val = 'b1; //BNE
        'b100: branch_val = 'b1; //BLT
        'b101: branch_val = 'b0; //BGE
        'b110: branch_val = 'b1; //BLTU
        'b111: branch_val = 'b0; //BGEU
        default branch_val= 'b0;
    endcase
end



logic branch_val_xor_zero, branch_and_taken, branch_jalr_or_branch;
assign branch_val_xor_zero = branch_val ^ aluz;
assign branch_and_taken = branch & branch_val_xor_zero;
assign branch_jalr_or_branch = branch_and_taken | branch_jalr;

always @(posedge clk, negedge rstn) 
	if (~rstn) pc <= {w{1'b0}};
	else pc <= branch_jalr_or_branch ? (branch_jalr ? alu_r:pc+imm1):pc+4;

rom #(.w(w),.d(d),.file(from)) inst_mem 
(
	.rdaddr(pc[(a-1)+2:2]),
	.rddata(inst)
);

control control(
    .instruction(inst[6:0]),
    .branch     (branch),
    .mem_read   (mem_read),
    .mem_to_reg (mem_to_reg),
    .alu_op     (aluop),
    .mem_write  (mem_write),
    .alu_src    (alu_src),
    .reg_write  (reg_write),
    .branch_jalr(branch_jalr),
    .lui        (lui),
    .pc_alu     (pc_alu)
    );

regs #(.w(r),.file(fregs)) regs 
(
	.clk(clk),
	.rstn(rstn),
	.wren(reg_write),
	.wraddr(inst[11:7]),
	.rdaddr1(inst[19:15]),
	.rdaddr2(inst[24:20]),
	.wrdata(rin),
	.rddata1(rd1),
	.rddata2(rd2)
);

imm #(.w(w)) imm
(
	.inst(inst),
	.imm(imm1),
	.i()
);


assign rd1_pc_or_reg = pc_alu? pc:rd1;
assign alu_src1 = lui? 0: rd1_pc_or_reg;
assign alu_src2 = alu_src ? imm1:rd2;
alu_control alu_control (
    .funct3(inst[14:12]),
    .funct7(inst[31:25]),
    .aluop(aluop),
    .alu_control_output(alu_cont_input)
);

ph_alu #(.w(w),.o(o)) alu
(
	.a(alu_src1),
	.b(alu_src2),
	.op(alu_cont_input),
	.result(alu_r),
	.zero(aluz)
);
logic [w-1:0] pc_or_alu;
assign pc_or_alu = branch_jalr? pc+4:alu_r;
assign rin = mem_to_reg? dat:pc_or_alu;

endmodule
