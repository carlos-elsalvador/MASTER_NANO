module gcd #(
    parameter int N = 8 // Number of bits of the input and output
) (
    input logic [N-1:0] id_x,  // u[N 0]: Input x
    input logic [N-1:0] id_y,  // u[N 0]: Input y
    input logic ic_val,        // Valid input
    input logic ic_rstn,       // Active-low reset signal
    input logic ic_clk,        // Clock signal
    output logic [N-1:0] od_gcd, // u[N 0]: Output gcd
    output logic oc_val,       // Valid output
    output logic oc_busy       // Busy signal
);

    // Wires for control signals (Controller -> Datapath)
    logic ic_ld_x;
    logic ic_ld_y;
    logic ic_sel;
    logic ic_ld_o;
    
    // Wires for status signals (Datapath -> Controller)
    logic oc_gr;
    logic oc_eq;

    // Instantiate the Datapath
    gcd_dp #(
        .N (N)
    ) i_gcd_dp (
        .ic_clk     (ic_clk),
        .ic_rstn    (ic_rstn),
        .id_x       (id_x),
        .id_y       (id_y),
        .ic_ld_x    (ic_ld_x),
        .ic_ld_y    (ic_ld_y),
        .ic_sel     (ic_sel),
        .ic_ld_o    (ic_ld_o),
        .oc_gr      (oc_gr),
        .oc_eq      (oc_eq),
        .od_gcd     (od_gcd)
    );

    // Instantiate the Controller
    gcd_ctrl i_gcd_ctrl (
        .ic_clk     (ic_clk),
        .ic_rstn    (ic_rstn),
        .ic_val     (ic_val),
        .oc_gr      (oc_gr),
        .oc_eq      (oc_eq),
        .ic_ld_x    (ic_ld_x),
        .ic_ld_y    (ic_ld_y),
        .ic_sel     (ic_sel),
        .ic_ld_o    (ic_ld_o),
        .oc_val     (oc_val),
        .oc_busy    (oc_busy)
    );

endmodule

module gcd_ctrl (
    // Clock and Reset
    input logic ic_clk,
    input logic ic_rstn,
    
    // Global Inputs
    input logic ic_val,    // Valid input

    // Status Inputs (from Datapath)
    input logic oc_gr,     // Rx > Ry
    input logic oc_eq,     // Rx == Ry

    // Control Outputs (to Datapath - MUST be based only on current 'state' for Moore)
    output logic ic_ld_x,
    output logic ic_ld_y,
    output logic ic_sel,
    output logic ic_ld_o, // Load output register control

    // Global Outputs (MUST be based only on current 'state' for Moore)
    output logic oc_val,
    output logic oc_busy
);

    // State definitions
    typedef enum logic [2:0] {
        WAIT = 3'd0,
        START = 3'd1,
        CHECK = 3'd2,
        OP_X = 3'd3,
        OP_Y = 3'd4,
        GCD = 3'd5,
        GCD_V = 3'd6
    } state_t;

    state_t state, next_state;

    // ------------------------------------------------------------------
    // State Register (Sequential Logic)
    // ------------------------------------------------------------------
    always_ff @(posedge ic_clk or negedge ic_rstn) begin
        if (!ic_rstn)
            state <= WAIT;
        else
            state <= next_state;
    end

    // ------------------------------------------------------------------
    // Output Logic (Combinational - Moore Style)
    // ------------------------------------------------------------------
    always_comb begin
        // Default (set to 0)
        ic_ld_x = 1'b0;
        ic_ld_y = 1'b0;
        ic_sel = 1'b0;
        ic_ld_o = 1'b0;
        oc_val = 1'b0;
        oc_busy = 1'b0;
        
        case (state)
            WAIT: begin
                // All outputs are 0 (idle)
            end
            START: begin
                // Load initial values (ic_sel=0 selects id_x/id_y)
                ic_ld_x = 1'b1;
                ic_ld_y = 1'b1;
                oc_busy = 1'b1;
            end
            CHECK: begin
                // Outputs are 0, waiting for comparator results
                oc_busy = 1'b1;
            end
            OP_X: begin
                // Perform Rx = Rx - Ry (ic_sel=1 selects sub_Rx_res)
                ic_ld_x = 1'b1;
                ic_sel = 1'b1;
                oc_busy = 1'b1;
            end
            OP_Y: begin
                // Perform Ry = Ry - Rx (ic_sel=1 selects sub_Ry_res)
                ic_ld_y = 1'b1;
                ic_sel = 1'b1;
                oc_busy = 1'b1;
            end
            GCD: begin
                // Result found (Rx=Ry). ic_ld_o=1 loads Rx_reg into od_gcd_reg.
                ic_ld_o = 1'b1;
                oc_busy = 1'b1; // Still busy preparing output
            end
            GCD_V: begin
                // Valid output is asserted.
                oc_val = 1'b1;
                oc_busy = 1'b0; // *** MODIFICACIÓN APLICADA: No está ocupado calculando. ***
            end
            default: begin end
        endcase
    end

    // ------------------------------------------------------------------
    // Next State Logic (Combinational)
    // ------------------------------------------------------------------
    always_comb begin
        next_state = state; 

        case (state)
            WAIT: begin
                if (ic_val) next_state = START;
            end
            START: begin
                next_state = CHECK;
            end
            CHECK: begin
                if (oc_eq)
                    next_state = GCD; // X = Y, result found
                else if (oc_gr)
                    next_state = OP_X; // X > Y
                else
                    next_state = OP_Y; // X < Y
            end
            OP_X: begin
                next_state = CHECK;
            end
            OP_Y: begin
                next_state = CHECK;
            end
            GCD: begin
                next_state = GCD_V;
            end
            GCD_V: begin
                next_state = WAIT;
            end
            default: next_state = WAIT;
        endcase
    end

endmodule // gcd_ctrl


module gcd_dp #(
    parameter int N = 8
) (
    // Clock and Reset
    input logic ic_clk,
    input logic ic_rstn,
    
    // Data Inputs
    input logic [N-1:0] id_x,
    input logic [N-1:0] id_y,

    // Control Inputs (from Controller)
    input logic ic_ld_x, // Load control for Rx
    input logic ic_ld_y, // Load control for Ry
    input logic ic_sel,  // Select signal for MUXs
    input logic ic_ld_o, // Load output register control (NEW USE)
    
    // Status Output (to Controller)
    output logic oc_gr,    // Rx > Ry
    output logic oc_eq,    // Rx == Ry

    // Data Output
    output logic [N-1:0] od_gcd // Output GCD value (Rx)
);

    // Internal Registers
    logic [N-1:0] Rx_reg, Ry_reg;
    // NUEVA SEÑAL: Registro de salida (para usar ic_ld_o)
    logic [N-1:0] od_gcd_reg;      

    // Subtraction results (Combinational)
    logic [N-1:0] sub_Rx_res, sub_Ry_res;
    
    assign sub_Rx_res = Rx_reg - Ry_reg; // Rx - Ry
    assign sub_Ry_res = Ry_reg - Rx_reg; // Ry - Rx

    // MUX Outputs (determine the next value to be loaded into registers)
    logic [N-1:0] Mux_Rx_out;
    assign Mux_Rx_out = ic_sel ? sub_Rx_res : id_x;

    logic [N-1:0] Mux_Ry_out;
    assign Mux_Ry_out = ic_sel ? sub_Ry_res : id_y;
    
    // Comparator Outputs (Status Signals)
    assign oc_gr = (Rx_reg > Ry_reg); // gr: Rx > Ry
    assign oc_eq = (Rx_reg == Ry_reg); // eq: Rx = Ry

    // Data Register Update Logic (Sequential)
    always_ff @(posedge ic_clk or negedge ic_rstn) begin
        if (!ic_rstn) begin
            Rx_reg <= '0;
            Ry_reg <= '0;
            od_gcd_reg <= '0; // Resetting new register
        end else begin
            // Load or Update Rx
            if (ic_ld_x) begin
                Rx_reg <= Mux_Rx_out;
            end
            // Load or Update Ry
            if (ic_ld_y) begin
                Ry_reg <= Mux_Ry_out;
            end
            // Load final result from Rx_reg into output register (NEW USE)
            if (ic_ld_o) begin
                od_gcd_reg <= Rx_reg;
            end          
        end
    end
    
    // Final Output Assignment (from the output register)
    assign od_gcd = od_gcd_reg; 

endmodule // gcd_dp
