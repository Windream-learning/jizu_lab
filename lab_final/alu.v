`define ALUOp_nop 5'b00000
`define ALUOp_lui 5'b00001
`define ALUOp_auipc 5'b00010
`define ALUOp_add 5'b00011


module alu(
    input rstn,
    input signed[31:0] A, B,
    input [4:0]ALUOp,
    output reg signed[31:0] C,
    output reg [7:0]Zero
    );

    always @(A or B) begin
        if(!rstn) C = 32'h00000000;
        else begin
            case(ALUOp)
                `ALUOp_nop: C = C;
                `ALUOp_add: C = A + B;
                `ALUOp_auipc: C = A + B;
                `ALUOp_lui: C = A + B;
            endcase
            Zero = (C==0) ? 1 : 0;
        end
    end
        
endmodule