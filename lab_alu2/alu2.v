`define ALUOp_add 5'b00000
`define ALUOp_sub 5'b00001

module alu(
    input clk,
    input rstn,
    input signed[31:0] A, B,
    input [4:0]ALUOp,
    output reg signed[31:0] C,
    output reg [7:0]Zero
    );

    always @(posedge clk, negedge rstn) begin
        if(!rstn) C = 32'h00000000;
        else begin
            case(ALUOp)
                `ALUOp_add: C = A + B;
                `ALUOp_sub: C = A - B;
            endcase
            Zero = (C==0) ? 1 : 0;
        end
    end
        
endmodule