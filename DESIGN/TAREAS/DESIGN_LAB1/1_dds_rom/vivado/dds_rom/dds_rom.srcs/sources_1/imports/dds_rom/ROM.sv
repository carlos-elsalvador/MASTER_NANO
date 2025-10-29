module ROM #(
    parameter int ADDR_WIDTH = 8,
    parameter int DATA_WIDTH = 12
)(
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] data
);
    logic [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

    // Load sine table from file
    initial begin
        $readmemh("sin_lut.mem", mem);
    end

    assign data = mem[addr];
endmodule

