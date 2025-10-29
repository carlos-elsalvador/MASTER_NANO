//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2024 01:11:04 PM
// Design Name: 
// Module Name: alu_control
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


module alu_control(
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    input  logic [1:0] aluop,
    output logic [3:0] alu_control_output
    );
    //Determine outputs using Exercise 2 table
always_comb
begin 
    case (aluop)
    2'b00:
        alu_control_output=4'b0010;
    2'b01:
        alu_control_output=4'b0110;    
    2'b10:
        case ({funct7,funct3})
            10'b0000000000: alu_control_output=4'b0010;
            10'b0100000000: alu_control_output=4'b0110;
            10'b0000000111: alu_control_output=4'b0000;                        
            10'b0000000110: alu_control_output=4'b0001;            
            default: alu_control_output=4'b0110;
         endcase
    2'b11:
        case ({funct7,funct3})
            10'b0000000000: alu_control_output=4'b0010;
            10'b0000000111: alu_control_output=4'b0000;                        
            10'b0000000110: alu_control_output=4'b0001;            
            default: alu_control_output=4'b0110;
         endcase
         
     default: alu_control_output=4'b0110;             
    endcase
end         
 
endmodule
