`define ALUOp_nop 5'b00000
`define ALUOp_lui 5'b00001
`define ALUOp_auipc 5'b00010
`define ALUOp_add 5'b00011
`define ALUOp_sub 5'b00100


module alu(
    input signed[31:0] A, B,
    input [4:0]ALUOp,
    output reg signed[31:0] C,
    output reg [7:0]Zero
    );
    
    initial begin
        C = 32'h00000000;
    end

    always @(A or B) begin
            case(ALUOp)
                `ALUOp_nop: C = C;
                `ALUOp_add: C = A + B;
                `ALUOp_auipc: C = B;
                `ALUOp_lui: C = B;
                `ALUOp_sub: C = A - B;
            endcase
            Zero = (C==0) ? 1 : 0;
    end
        
endmodule