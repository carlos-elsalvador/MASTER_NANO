module imm(inst,imm,i);

parameter w=32;

input [w-1:0] inst;
output logic [w-1:0] imm;
output logic i; //not used

//To be filled in the lab session 1
always_comb 
begin
    case (inst[6:0])
        7'b0000011: imm = {{20{inst[31]}}, inst[31:20]}; //I_lw
        7'b0010011: imm = {{20{inst[31]}}, inst[31:20]}; //I_arith
        7'b1100111: imm = {{20{inst[31]}}, inst[31:20]}; //I_jalr
        7'b0100011: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}; //S
        7'b1100011: imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}; //SB (copilot)        
        7'b0110011: imm = 32'b0; //R        
        //default:    imm = 32'b0;
        default: imm={{21{inst[31]}}, inst[30:20]};
    endcase
end

endmodule

// B-type (SB) immediate
//default imm={{21{inst[31]}}, inst[30:20]}
// iload
// jalr
