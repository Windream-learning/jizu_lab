`timescale 1ns / 1ps

module testbench();
reg clk;
reg rstn;
wire [15:0]sw_i;
wire [7:0]seg;
wire [7:0]an;

SCPU_TOP U_CPU(clk, rstn, sw_i, seg, an);

assign sw_i[13:0] = 14'h0000;
assign sw_i[14] = 1'b1;
assign sw_i[15] = 1'b0;

initial begin
    rstn = 0;
    #40 clk = 0;

    #30 rstn = 1;
    #500 $stop;
end

always
    #100 clk = ~clk;

endmodule