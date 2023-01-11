`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.12.2020 22:36:29
// Design Name: 
// Module Name: AXI_CPU
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

//Fake CPU: it tries to read data in addres 1 and copies it in assress 2
module AXI_CPU(
    ACLK, ARESETn,                          //Global
    AWVALID, AWREADY, AWADDR, AWPROT,       //Write address channel
    WVALID, WREADY, WDATA, WSTRB,           //Write data channel
    BVALID, BREADY, BRESP,                  //Write response channel
    ARVALID, ARREADY, ARADDR, ARPROT,       //Read address channel
    RVALID, RREADY, RDATA, RRESP,           //Read data channel
    );

    //////Global///////
    input ACLK;
    input ARESETn;
    //////Write Address///////
    output logic AWVALID;
    input AWREADY;
    output logic [31:0] AWADDR;
    output logic AWPROT;//?
    //////Write Data///////
    output logic WVALID;
    input WREADY;
    output logic [31:0]WDATA;
    output logic [3:0]WSTRB;
    //////Write Response///////
    input BVALID;
    output logic BREADY;
    input [1:0]BRESP;
    //////Read Address///////
    output logic ARVALID;
    input ARREADY;
    output logic [31:0]ARADDR;
    output logic ARPROT;//?
    //////Raed Data///////
    input RVALID;
    output logic RREADY;
    input [31:0]RDATA;
    input [1:0]RRESP;
        
    reg [2:0] ss, ss_next;                      //current and next states
    reg [31:0]data;
    
    localparam S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100, S5 = 3'b101;
    localparam OKAY = 2'b00, EXOKAY = 2'b01, SLVERR = 2'b10,DECERR = 2'b11; //EXOKAY is not present in AXI4 lite
    
    always@(posedge ACLK)
    begin
        if(ARESETn)                             //handles reset
        begin
            ARVALID <= 0;
            AWVALID <= 0;
            WVALID <= 0;
            ss = S0;
        end
        else
            ss <= ss_next;                      //go to next state
    end
    
    always@(ss, ARESETn, AWREADY, WREADY, BVALID, ARREADY, RVALID)
    begin
        ss_next = ss;
        case(ss)
            S0:begin                            //Initial state, the processor tries to read the memory.
                AWVALID <= 0;
                WVALID <= 0;
                BREADY <= 0;
                ARVALID <= 1;
                ARADDR <= 1'd1;
                RREADY <= 0;
                if(ARREADY)
                    ss_next = S1;
                else ss_next = S0;
            end
            S1:begin                            //Slave sends data.
                AWVALID <= 0;
                WVALID <= 0;
                BREADY <= 0;
                ARVALID <= 0;
                RREADY <= 1;
                if(RVALID) begin
                    ss_next = S2;
                    data <= RDATA;
                    end
                else ss_next = S1;
            end
            S2:begin                            //Master wants to write.
                AWVALID <= 1;
                AWADDR <= 2'd2;
                WVALID <= 0;
                BREADY <= 0;
                ARVALID <= 0;
                RREADY <= 0;
                if(AWREADY)
                    ss_next = S3;
                else ss_next = S2;
            end
            S3:begin                            //Master sends data.
                AWVALID <= 0;
                WVALID <= 1;
                WDATA <= data;
                BREADY <= 0;
                ARVALID <= 0;
                RREADY <= 0;
                if(WREADY)
                    ss_next = S4;
                else ss_next = S3;
            end
            S4:begin                            //Slave acknownledges on response channel.
                AWVALID <= 0;
                WVALID <= 0;
                BREADY <= 1;
                ARVALID <= 0;
                RREADY <= 0;
                if(BVALID)
                    if(BRESP == OKAY) ss_next = S5;
                    else ss_next = S2;
                else ss_next = S4;
            end
            S5:begin                            //Master has completed its operations.
                AWVALID <= 0;
                WVALID <= 0;
                BREADY <= 0;
                ARVALID <= 0;
                RREADY <= 0;
                ss_next = S5;
            end
        endcase
    end  
endmodule