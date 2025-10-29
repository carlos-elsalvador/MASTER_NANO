//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2024 02:32:31 PM
// Design Name: 
// Module Name: ph_alu
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

/*
SUPPORTED OPERATIONS
Operation |  Opcode
----------|--------
AND       |  0000
OR        |  0001
ADD       |  0010
SUBSTRACT |  0110
LessThan              | 0011
ShiftLeft             | 0100
LessThanUnsigned      | 0101
XOR                   | 0111
ShiftRightLogical     | 1000
ShiftRightArithmetic  | 1001
------------------
*/
module ph_alu(a,b,op,result, zero);
parameter w=32,o=4;
input [w-1:0] a,b;
input [o-1:0] op;
output logic [w-1:0] result;
output zero;
//Determine ALU result with inputs a and b. Opcode table is defined in practice-> ALUControl unit section
localparam logic [3:0] AND                = 4'b0000;
localparam logic [3:0] OR                 = 4'b0001;
localparam logic [3:0] ADD                = 4'b0010;
localparam logic [3:0] LESS_THAN          = 4'b0011;
localparam logic [3:0] SHIFT_LEFT         = 4'b0100;
localparam logic [3:0] LESS_THAN_UNSIGNED = 4'b0101;
localparam logic [3:0] SUB                = 4'b0110;
localparam logic [3:0] XOR                = 4'b0111;
localparam logic [3:0] SHIFT_RIGHT_LOGICAL= 4'b1000;
localparam logic [3:0] SHIFT_RIGH_ARITH   = 4'b1101;

always_comb begin
    case (op)
        ADD: result = a+b;
        SUB: result = a-b;
        AND: result = a & b;
        OR:  result = a | b;
        LESS_THAN:           result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
        SHIFT_LEFT:          result = a << b;
        LESS_THAN_UNSIGNED:  result = (a < b) ? 32'b1 : 32'b0;
        XOR:                 result = a ^ b;
        SHIFT_RIGHT_LOGICAL: result = a >> b;
        //SHIFT_RIGHT_ARITH:   result = signed'(a) >>> b;      
        default: result = 32'b0;
    endcase
    end
assign zero = (result == 32'b0);    

endmodule

