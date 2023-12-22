`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/11/18 17:46:23
// Design Name: 
// Module Name: RF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RF(
    input clk,
    input rstn,
    input RFWr,
    input [15:0]sw_i,
    input [4:0]A1, A2, A3,
    input [31:0]WD,
    output [31:0]RD1, RD2
    );
    
    reg [31:0] rf[31:0];
    integer i;
    
    always @(A1 or A2 or WD)
        if (!rstn)
            for(i = 0; i < 32; i = i+1)
                rf[i] <= i;
        else if(RFWr && (!sw_i[1])) begin
            if(A3 != 5'b00000) rf[A3] <= WD;
            $display("r[%2d] = 0x%8X,", A3, WD);
        end
    assign RD1 = (A1 != 0) ? rf[A1] : 0;
    assign RD2 = (A2 != 0) ? rf[A2] : 0;
    
        
endmodule


