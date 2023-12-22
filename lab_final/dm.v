`define dm_word 3'b000
`define dm_halfword 3'b001
`define dm_halfword_unsigned 3'b010
`define dm_byte 3'b011
`define dm_byte_unsigned 3'b100

module dm(
    input DMWr,
    input [5:0]addr,
    input [31:0]din,
    input [2:0]DMType,
    output reg [31:0]dout
);

reg [7:0] dmem[6:0];

always @(addr or din)
    if(DMWr == 1'b1)
        case(DMType)
            `dm_byte: dmem[addr] <= din[7:0];
            `dm_halfword: begin
                dmem[addr] <= din[7:0];
                dmem[addr+1] <= din[15:8];
            end
            `dm_word: begin
                dmem[addr] <= din[7:0];
                dmem[addr+1] <= din[15:8];
                dmem[addr+2] <= din[23:16];
                dmem[addr+3] <= din[31:24];
            end
        endcase
    else
        case(DMType)
            `dm_byte: dout = {{24{dmem[addr][7]}}, dmem[addr][7:0]};
            `dm_byte_unsigned: dout = {{24{1'b0}}, dmem[addr][7:0]};
            `dm_halfword: dout = {{16{dmem[addr+1][7]}}, dmem[addr+1][7:0], dmem[addr][7:0]};
            `dm_halfword_unsigned: dout = {{16{1'b0}}, dmem[addr+1][7:0], dmem[addr][7:0]};
            `dm_word: dout = {dmem[addr+3][7:0], dmem[addr+2][7:0], dmem[addr+1][7:0], dmem[addr][7:0]};
        endcase

endmodule