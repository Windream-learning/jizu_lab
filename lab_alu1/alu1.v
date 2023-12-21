`define ALUOp_add 5'b00001
`define ALUOp_sub 5'b00010

module alu(
    input signed[31:0] A, B,
    input [4:0]ALUOp,
    output reg signed[31:0] C,
    output reg [7:0]Zero
    );

    always @(ALUOp or A or B) begin
        case(ALUOp)
            `ALUOp_add: C = A + B;
            `ALUOp_sub: C = A - B;
        endcase
        Zero = (C==0) ? 1 : 0;
    end
        
endmodule

