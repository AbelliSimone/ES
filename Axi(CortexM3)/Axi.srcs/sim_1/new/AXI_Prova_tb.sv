`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.12.2020 23:08:31
// Design Name: 
// Module Name: AXI_Prova_tb
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

//Connect fake cpu with AXI_Mem to copy what is in address 1 to address 2
module AXI_Prova_tb();

    parameter HALF_CLK_PERIOD       =   10; // @ 50MHz

    logic           clk;
    logic           rst;

    logic AWVALID = 0;
    logic AWREADY = 0;
    logic [31:0]AWADDR;
    logic AWPROT;
    logic WVALID = 0;
    logic WREADY = 0;
    logic [31:0]WDATA;
    logic [3:0]WSTRB;
    logic BVALID = 0;
    logic BREADY = 0;
    logic [1:0]BRESP;
    logic ARVALID = 0;
    logic ARREADY = 0;
    logic [31:0]ARADDR;
    logic ARPROT;
    logic RVALID = 0;
    logic RREADY = 0;
    logic [31:0]RDATA;
    logic [1:0]RRESP;

    always #HALF_CLK_PERIOD clk =~ clk;

    initial
    begin
        clk <=  0;
        rst =   1;

        repeat(5) @(posedge clk);
        rst <=  0;
        repeat(5) @(posedge clk);
    end

    AXI_Mem mem (.ACLK(clk), .ARESETn(rst), .AWVALID(AWVALID), .AWREADY(AWREADY), .AWADDR(AWADDR),
                          .AWPROT(AWPROT), .WVALID(WVALID), .WREADY(WREADY), .WDATA(WDATA), .WSTRB(WSTRB),
                          .BVALID(BVALID), .BREADY(BREADY), .BRESP(BRESP), .ARVALID(ARVALID), .ARREADY(ARREADY), 
                          .ARADDR(ARADDR), .ARPROT(ARPROT), .RVALID(RVALID), .RREADY(RREADY), .RDATA(RDATA), .RRESP(RRESP));
                          
    AXI_CPU cpu (.ACLK(clk), .ARESETn(rst), .AWVALID(AWVALID), .AWREADY(AWREADY), .AWADDR(AWADDR),
                          .AWPROT(AWPROT), .WVALID(WVALID), .WREADY(WREADY), .WDATA(WDATA), .WSTRB(WSTRB),
                          .BVALID(BVALID), .BREADY(BREADY), .BRESP(BRESP), .ARVALID(ARVALID), .ARREADY(ARREADY), 
                          .ARADDR(ARADDR), .ARPROT(ARPROT), .RVALID(RVALID), .RREADY(RREADY), .RDATA(RDATA), .RRESP(RRESP));

    always@(posedge clk)
        if (cpu.ss == 3'b101)
            $finish;            //fake processor has completed the operations: SUCCESS!!!
endmodule