`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.12.2020 11:23:07
// Design Name: 
// Module Name: AXI_tb2
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

//Connect the real CORTEXM3 with AXI_Mem; cpu tries to boot reading the memory
module AXI_tb2();

    parameter HALF_CLK_PERIOD       =   10; // @ 50MHz

    logic           clk;
    logic           rst;

    logic AWVALID = 0;
    logic AWREADY = 0;
    logic [31:0]AWADDR;
    logic [2:0]AWPROT;
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
    logic [2:0]ARPROT;
    logic RVALID = 0;
    logic RREADY = 0;
    logic [31:0]RDATA;
    logic [1:0]RRESP;
    
    
    logic [1:0] CFGITCMEN;
    logic SYSRESETREQ;
    logic DBGRESTARTED;
    logic LOCKUP;
    logic HALTED;
    logic JTAGTOP;
    logic TDO;
    logic nTDOEN;
    logic SWV;
    

    always #HALF_CLK_PERIOD clk =~ clk;

    AXI_Mem mem (.ACLK(clk), .ARESETn(rst), .AWVALID(AWVALID), .AWREADY(AWREADY), .AWADDR(AWADDR),
                          .AWPROT(AWPROT), .WVALID(WVALID), .WREADY(WREADY), .WDATA(WDATA), .WSTRB(WSTRB),
                          .BVALID(BVALID), .BREADY(BREADY), .BRESP(BRESP), .ARVALID(ARVALID), .ARREADY(ARREADY), 
                          .ARADDR(ARADDR), .ARPROT(ARPROT), .RVALID(RVALID), .RREADY(RREADY), .RDATA(RDATA), .RRESP(RRESP));
    
    //Instantiating the cpu
    CORTEXM3_AXI_0 cpu(.HCLK(clk), .SYSRESETn(~rst), .DBGRESETn(~rst), .nTRST(~rst), .CFGITCMEN(CFGITCMEN),
                          .SYSRESETREQ(SYSRESETREQ), .DBGRESTARTED(DBGRESTARTED), .LOCKUP(LOCKUP), .HALTED(HALTED),
                          .JTAGTOP(JTAGTOP), .TDO(TDO), .nTDOEN(nTDOEN), .SWV(SWV),
                          .AWVALIDC(AWVALID), .AWREADYC(AWREADY), .AWADDRC(AWADDR),
                          .AWPROTC(AWPROT), .WVALIDC(WVALID), .WREADYC(WREADY), .HWDATAC(WDATA), .WSTRBC(WSTRB),
                          .BVALIDC(BVALID), .BREADYC(BREADY), .BRESPC(BRESP), .ARVALIDC(ARVALID), .ARREADYC(ARREADY), 
                          .ARADDRC(ARADDR), .ARPROTC(ARPROT), .RVALIDC(RVALID), .RREADYC(RREADY), .HRDATAC(RDATA), .RRESPC(RRESP));

    initial
    begin
        CFGITCMEN = 2'b00;
        rst <=  0;
        clk <=  0;
        repeat(10) @(posedge clk);
        rst =   1;
        repeat(10) @(posedge clk);
        rst <=  0;
        repeat(50) @(posedge clk);
        $finish;
    end

endmodule
