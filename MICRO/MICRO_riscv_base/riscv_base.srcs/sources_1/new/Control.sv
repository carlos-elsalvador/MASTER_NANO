//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2024 12:34:22 PM
// Design Name: 
// Module Name: control
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
`define R_FORMAT_OP  7'b0110011
`define I_LOAD_OP    7'b0000011
`define I_ARITH_OP   7'b0010011
`define I_JALR_OP    7'b1100111
`define S_FORMAT_OP  7'b0100011
`define SB_FORMAT_OP 7'b1100011
`define U_LUI_OP     7'b0110111
`define U_AUIPC_OP   7'b0010111
`define UJ_JAL_OP    7'b1101111


module control(
    input  logic[6:0] instruction,
    output logic      branch,
    output logic      mem_read,
    output logic      mem_to_reg,
    output logic[1:0] alu_op,
    output logic      mem_write,
    output logic      alu_src,
    output logic      reg_write,
    output logic      branchJALR    
    );
    
    // Determine outputs using Exercise 1 solution
always_comb
begin 
    case (instruction)
    `R_FORMAT_OP:
        begin 
            branch=1'b0;
            mem_read=1'b0;
            mem_to_reg=1'b0;
            alu_op=2'b10;
            mem_write=1'b0;
            alu_src=1'b0;
            reg_write=1'b1;
            branchJALR =0;
        end
    `I_ARITH_OP:
        begin 
            branch=1'b0;
            mem_read=1'b0;
            mem_to_reg=1'b0;
            alu_op=2'b11;
            mem_write=1'b0;
            alu_src=1'b1;
            reg_write=1'b1;
            branchJALR =0;
        end        
    `I_LOAD_OP:
        begin 
            branch=1'b0;
            mem_read=1'b1;
            mem_to_reg=1'b1;
            alu_op=2'b00;
            mem_write=1'b0;
            alu_src=1'b1;
            reg_write=1'b1;
            branchJALR =0;            
        end
    `S_FORMAT_OP:
        begin 
            branch=1'b0;
            mem_read=1'b0;
            mem_to_reg=1'b0;
            alu_op=2'b10;
            mem_write=1'b1;
            alu_src=1'b1;
            reg_write=1'b0;
            branchJALR =0;            
        end
    `SB_FORMAT_OP:
        begin 
            branch=1'b1;
            mem_read=1'b0;
            mem_to_reg=1'b0;
            alu_op=2'b10;
            mem_write=1'b0;
            alu_src=1'b0;
            reg_write=1'b0;
            branchJALR =0;            
        end      
    `I_JALR_OP:
        begin 
            branch=1'b0;
            mem_read=1'b0;
            mem_to_reg=1'b0;
            alu_op=2'b0;
            mem_write=1'b0;
            alu_src=1'b1;
            reg_write=1'b1;
            branchJALR =1'b1;            
        end      
    default :
        begin 
            branch=0;
            mem_read=0;
            mem_to_reg=0;
            alu_op=2'b10;
            mem_write=0;
            alu_src=0;
            reg_write=1;
            branchJALR =0;            
        end
        
endcase      
end
    
endmodule
