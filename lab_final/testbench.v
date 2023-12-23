`timescale 1ns / 1ps

module testbench();
reg clk;
reg rstn;
wire [15:0]sw_i;
wire [7:0]seg;
wire [7:0]an;

SCPU_TOP U_CPU(clk, rstn, sw_i, seg, an);

initial begin
    rstn = 1;
    clk = 0;

    #30 rst = 0;
    #500 $stop;
end

always
    #20 clk = ~clk;

endmodule