`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.01.2021 11:19:34
// Design Name: 
// Module Name: AHB_Mem
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


module AHB_Mem(
    HCLK, HRESETn,                              //Global
    HADDR, HBURST, HMASTLOCK, HPROT, HREADY,    //input
    HSIZE, HTRANS, HWDATA, HWRITE, HSELx,
    HRDATA, HREADYOUT, HRESP                    //output
    );
    parameter MEM_NUM_LINE          =   1024;

    parameter VMEM_FILE             =   "C:/Users/Mauri/Desktop/AT426-BU-98000-r0p1-00rel0/hardware/m3_for_arty_a7/m3_for_arty_a7/bram_a7.hex";


    //////Global///////
    input HCLK;
    input HRESETn;
    //////Slave input///////
    input [31:0]HADDR;
    input HBURST;
    input HMASTLOCK;
    input [3:0]HPROT;
    input [2:0]HSIZE;
    input [1:0]HTRANS;
    input [31:0]HWDATA;
    input HWRITE;
    input HSELx;
    input HREADY;//??????
    //////Slave output///////
    output logic [31:0]HRDATA;
    output logic HREADYOUT;
    output logic HRESP;
   
        
    reg [31:0] MEMORY [0:MEM_NUM_LINE-1];       //store the data of the memory(using $readmemh)
    
    reg [1:0] ss, ss_next;                      //current and next states
    reg [31:0]addr;                             //the address of the current read/write operation
    int val;                                    //to convert addr int an integer in ordrder to use it in the array

    localparam S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
    localparam IDLE = 2'b00, BUSY = 2'b01, NONSEQ = 2'b10, SEQ = 2'b11;
    localparam OKAY = 1'b0, ERROR = 1'b1;

always@(posedge HCLK)
    begin
        if(HRESETn)                             //handles reset
        begin
            $readmemh(VMEM_FILE, MEMORY);
            HREADYOUT = 0;
            HRESP = OKAY;
            ss = S0;
        end
        else
            ss <= ss_next;       
    end
    
    always@(ss, HRESETn, HADDR, HBURST, HMASTLOCK, HPROT, HSIZE, HTRANS, HWDATA, HWRITE, HSELx, HREADY)
    begin
        ss_next = ss;
        case(ss)
            S0:begin                        //Initial state, the memory waits for the processor.
                HREADYOUT = 0;
                if(HTRANS == IDLE || HSELx == 0 || HREADY)
                    ss_next = S0;
                else begin
                    addr <= HADDR;
                    if(HWRITE)              //Master wants to write
                        ss_next = S2;
                    else                    //Master wants to read
                        ss_next = S1;
                end
            end
            S1:begin                        //Slave send data.
                val = addr;
                HRDATA <= MEMORY[val];
                HREADYOUT <= 1;
                HRESP = OKAY;
                ss_next = S0;
            end
            S2:begin                        //Master wants to write, Slave receives data.
                val = addr;
                MEMORY[val] <= HWDATA;
                HREADYOUT <= 1;
                HRESP = OKAY;
                ss_next = S0;
            end
        endcase
    end


endmodule