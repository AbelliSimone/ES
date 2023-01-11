`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.01.2021 11:20:53
// Design Name: 
// Module Name: Decoder
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

//Just a decoder ;) : selects the right slave
module Decoder(
    HADDR, HSEL1, HSEL2, HMULTSEL
    );
    
    //////Decoder input///////
    input [31:0]HADDR;
    //////Decoder output///////
    output logic HSEL1;
    output logic HSEL2;
    output logic HMULTSEL;

    always@(HADDR)
    begin
        if(HADDR[9] == 0) begin
            HSEL1 = 1;
            HSEL2 = 0;
            HMULTSEL = 0;
        end
        if(HADDR[9] == 1) begin
            HSEL1 = 0;
            HSEL2 = 1;
            HMULTSEL = 1;
        end
    end
endmodule
