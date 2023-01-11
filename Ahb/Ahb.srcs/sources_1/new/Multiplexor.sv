`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.01.2021 11:20:53
// Design Name: 
// Module Name: Multiplexor
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

//Just a mux ;) : send the output of the right slave to the master
module Multiplexor(
        MSEL, HRDATA1, HREADYOUT1, HRESP1,
        HRDATA2, HREADYOUT2, HRESP2,
        HRDATA, HREADY, HRESP
    );
    
    //////Multiplexor input///////
    input MSEL;
    input [31:0]HRDATA1;
    input HREADYOUT1;
    input HRESP1;
    input [31:0]HRDATA2;
    input HREADYOUT2;
    input HRESP2;
    //////Multiplexor output///////
    output logic [31:0]HRDATA;
    output logic HREADY;
    output logic HRESP;
    
    always@(MSEL, HRDATA1, HREADYOUT1, HRESP1, HRDATA2, HREADYOUT2, HRESP2)
    begin
    if(MSEL == 0) begin
        HRDATA = HRDATA1;
        HREADY = HREADYOUT1;
        HRESP = HRESP1;
        end
    if(MSEL == 1) begin
        HRDATA = HRDATA2;
        HREADY = HREADYOUT2;
        HRESP = HRESP2;
        end
    end
endmodule
