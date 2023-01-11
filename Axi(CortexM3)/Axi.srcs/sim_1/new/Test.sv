`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.12.2020 11:29:34
// Design Name: 
// Module Name: Test
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

//Just testing stuff
module Test();
    begin
        logic [31:0]addr;
        logic [7:0]vec [31:0];
        int address;
        int data;

        
        initial begin
            addr = 31'd7;
            vec[6] = 31'd4;
            
            address = addr;
            data  = vec[6] + 5;
            vec[addr] <= data;
            vec[addr + 1] <= addr;
            
            
        end
    end
endmodule
