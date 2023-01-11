`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.12.2020 17:40:03
// Design Name: 
// Module Name: AXI_Mem
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


module AXI_Mem(
    ACLK, ARESETn,                          //Global
    AWVALID, AWREADY, AWADDR, AWPROT,       //Write address channel
    WVALID, WREADY, WDATA, WSTRB,           //Write data channel
    BVALID, BREADY, BRESP,                  //Write response channel
    ARVALID, ARREADY, ARADDR, ARPROT,       //Read address channel
    RVALID, RREADY, RDATA, RRESP,           //Read data channel
    );
    parameter MEM_NUM_LINE          =   1024;

    parameter VMEM_FILE             =   "C:/Users/Mauri/Desktop/AT426-BU-98000-r0p1-00rel0/hardware/m3_for_arty_a7/m3_for_arty_a7/bram_a7.hex";


    //////Global///////
    input ACLK;
    input ARESETn;
    //////Write Address///////
    input AWVALID;
    output logic AWREADY;
    input [31:0]AWADDR;
    input [2:0]AWPROT;//?
    //////Write Data///////
    input WVALID;
    output logic WREADY;
    input [31:0]WDATA;
    input [3:0]WSTRB;
    //////Write Response///////
    output logic BVALID;
    input BREADY;
    output logic [1:0]BRESP;
    //////Read Address///////
    input ARVALID;
    output logic ARREADY;
    input [31:0]ARADDR;
    input [2:0]ARPROT;//?
    //////Raed Data///////
    output logic RVALID;
    input RREADY;
    output logic [31:0]RDATA;
    output logic [1:0]RRESP;
    
    reg [31:0] MEMORY [0:MEM_NUM_LINE-1];       //store the data of the memory(using $readmemh)
    
    reg [1:0] ss, ss_next;                      //current and next states
    reg [31:0]addr;                             //the address of the current read/write operation
    int val;                                    //used to convert addr to an integer in order to use it as index in the MEMORY array
    
    localparam S0 = 2'b00, S1 = 2'b01, S2 = 2'b10,S3 = 2'b11;
    localparam OKAY = 2'b00, EXOKAY = 2'b01, SLVERR = 2'b10,DECERR = 2'b11; //EXOKAY is not present in AXI4 lite    
    
    always@(posedge ACLK)
    begin
        if(ARESETn)                             //handles reset
        begin
            $readmemh(VMEM_FILE, MEMORY);
            RVALID <= 0;
            BVALID <= 0;
            ss = S0;
        end
        else
            ss <= ss_next;                      //go to next state
    end
    
    always@(ss, ARESETn, AWVALID, WVALID, BREADY, ARVALID, RREADY)
    begin
        ss_next = ss;
        case(ss)
            S0:begin                            //Initial state, all value set to default.
                AWREADY <= 1;
                WREADY <= 1;
                BVALID <= 0;
                ARREADY <= 1;
                RVALID <= 0;
                if(AWVALID) begin               //the master wants to write
                    ss_next = S1;
                    addr <= AWADDR;
                    end
                else if (ARVALID) begin         //the master wants to read
                    ss_next = S3;
                    addr <= ARADDR;
                    end
                else ss_next = S0;
            end
            S1:begin                            //Master asked to write, slave waits for data.
                AWREADY <= 0;
                WREADY <= 1;
                BVALID <= 0;
                ARREADY <= 0;
                RVALID <= 0;
                if(WVALID) begin                //master has sent data
                    ss_next = S2;
                    val = addr;
                    MEMORY[val] <= WDATA;
                    end
                else ss_next = S1;
            end
            S2:begin                            //Master has sent data, slave acknownledges on response channel.
                AWREADY <= 0;
                WREADY <= 0;
                BVALID <= 1;
                BRESP <= OKAY;
                ARREADY <= 0;
                RVALID <= 0;
                if(BREADY) ss_next = S0;        //master received the response
                else ss_next = S2;
            end
            S3:begin                            //Master asked to read, slave puts data on read data channel.
                AWREADY <= 0;
                WREADY <= 0;
                BVALID <= 0;
                ARREADY <= 0;
                RVALID <= 1;
                RRESP <= OKAY;
                val = addr;
                RDATA <= MEMORY[val];
                if(RREADY) ss_next = S0;        //master received data
                else ss_next = S3;
            end
        endcase
    end
    
endmodule