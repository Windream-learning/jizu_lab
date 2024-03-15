`define EXT_CTRL_ITYPE_SHAMT 3'b011
`define EXT_CTRL_ITYPE 3'b010
`define EXT_CTRL_STYPE 3'b001
`define EXT_CTRL_BTYPE 3'b100
`define EXT_CTRL_UTYPE 3'b101
// `define EXT_CTRL_JTYPE 3'b

module EXT( 
    input [4:0] iimm_shamt,
    input [11:0]	iimm, //instr[31:20], 12 bits
    input [11:0]	simm, //instr[31:25, 11:7], 12 bits
    input [11:0]	bimm, //instrD[31],instrD[7], instrD[30:25], instrD[11:8], 12 bits
    input [19:0]	uimm,
    // input [19:0]	jimm,
    input [2:0]	 EXTOp,
    output reg [31:0] immout
    );

always @(*)
    case (EXTOp)
        `EXT_CTRL_ITYPE_SHAMT:   immout<={27'b0,iimm_shamt[4:0]};
        `EXT_CTRL_ITYPE:	if (iimm[11]>0) immout<={20'b11111111111111111111,iimm[11:0]};
                                else immout<={20'b0,iimm[11:0]};
        `EXT_CTRL_STYPE:	if (simm[11]>0) immout<={20'b11111111111111111111,simm[11:0]};
                                else immout<={20'b0,simm[11:0]};
        `EXT_CTRL_BTYPE:    if (bimm[11]>0) immout<={19'b1111111111111111111,bimm[11:0],1'b0};
                                 else immout<={19'b0,bimm[11:0],1'b0};
        `EXT_CTRL_UTYPE:	immout <= {uimm[19:0], 12'b0};

        // `EXT_CTRL_JTYPE:	if (jimm[19]>0) immout<={11'b11111111111,jimm[19:0],1'b0};
        //                         else immout<={11'b0,jimm[19:0],1'b0};
        default:	        immout <= 32'b0;
    endcase

endmodule