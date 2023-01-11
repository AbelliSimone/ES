`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.01.2021 11:19:05
// Design Name: 
// Module Name: AHB_CPU
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

//Fake cpu read from memory 1 and write it in memory 2 
module AHB_CPU(
    HCLK, HRESETn,                          //Global
    HRDATA, HREADY, HRESP,                  //input
    HADDR, HBURST, HMASTLOCK, HPROT,        //output
    HSIZE, HTRANS, HWDATA, HWRITE
    );

    //////Global///////
    input HCLK;
    input HRESETn;
    //////Master input///////
    input [31:0]HRDATA;
    input HREADY;
    input HRESP;
    //////Master output///////
    output logic [31:0]HADDR;
    output logic HBURST;
    output logic HMASTLOCK;
    output logic [3:0]HPROT;
    output logic [2:0]HSIZE;
    output logic [1:0]HTRANS;
    output logic [31:0]HWDATA;
    output logic HWRITE;

    reg [2:0] ss, ss_next;                      //current and next states
    reg [31:0]data;

    localparam S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100, S5 = 3'b101, S6 = 3'b110;
    localparam IDLE = 2'b00, BUSY = 2'b01, NONSEQ = 2'b10, SEQ = 2'b11;
    localparam OKAY = 1'b0, ERROR = 1'b1;
    
    always@(posedge HCLK)
    begin
        if(HRESETn) 
        begin
            HTRANS <= IDLE;
            ss = S0;
        end
        else
            ss <= ss_next;       
    end
    
    always@(ss, HRESETn, HRDATA, HREADY, HRESP)
    begin
        ss_next = ss;
        case(ss)
            S0:begin                        //Initial state, the processor is idle
                HTRANS <= IDLE;
                ss_next = S1;
            end
            S1:begin                        //the processor try to read the memory.
                HADDR <= 1'd1;
                HBURST <= 3'b000;
                HMASTLOCK <= 1'b0;
                HSIZE <= 3'b010;
                HTRANS <= NONSEQ;
                HWRITE <= 0;
                ss_next = S2;
            end
            S2:begin                        //Master waits for the slave.
                if(HRESP == OKAY) begin
                    if(HREADY)
                        ss_next = S3;
                    else
                        ss_next = S2;
                end
                else begin
                   if(HREADY)
                        ss_next = S1;
                    else begin
                        HTRANS <= IDLE;
                        ss_next = S2;
                    end
                end 
            end
            S3:begin                        //Master samples the data from the slave.
                data <= HRDATA;
                HTRANS <= IDLE;
                ss_next = S4;
            end
            S4:begin                        //Master wants to write.
                HADDR <= 10'd1023;
                HBURST <= 3'b000;
                HMASTLOCK <= 1'b0;
                HSIZE <= 3'b010;
                HTRANS <= NONSEQ;
                HWRITE <= 1;
                ss_next = S5;
            end
            S5:begin                        //Master sends data and wait for slave.
                HWDATA <= data;
                if(HRESP == OKAY) begin
                    if(HREADY)
                        ss_next = S6;
                    else
                        ss_next = S5;
                end
                else begin
                   if(HREADY)
                        ss_next = S4;
                    else begin
                        HTRANS <= IDLE;
                        ss_next = S5;
                    end
                end 
            end
            S6:begin                        //Master has completed its operations.
                HTRANS <= IDLE;
                ss_next = S6;
            end
        endcase
    end
endmodule
