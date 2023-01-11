`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.01.2021 11:44:30
// Design Name: 
// Module Name: tb_AHB
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

//Connect fake cpu with two AHI_Mems to copy what is in address 1 of the first to address 1023 of the second
module tb_AHB();
    parameter HALF_CLK_PERIOD       =   10; // @ 50MHz

    logic           clk;
    logic           rst;

    logic [31:0] HRDATA;
    logic HREADY;
    logic HRESP;
    logic [31:0] HADDR;
    logic HBURST;
    logic HMASTLOCK;
    logic [3:0]HPROT;
    logic [2:0]HSIZE;
    logic [1:0]HTRANS;
    logic [31:0]HWDATA;
    logic HWRITE;

    logic HSEL1;
    logic HSEL2;
    logic HMULTSEL;
    
    logic [31:0]HRDATA1;
    logic HREADYOUT1;
    logic HRESP1;
    logic [31:0]HRDATA2;
    logic HREADYOUT2;
    logic HRESP2;

    always #HALF_CLK_PERIOD clk =~ clk;

    AHB_Mem mem1( .HCLK(clk), .HRESETn(rst), .HADDR(HADDR), .HBURST(HBURST), .HMASTLOCK(HMASTLOCK), .HPROT(HPROT),
    .HREADY(HREADY), .HSIZE(HSIZE), .HTRANS(HTRANS), .HWDATA(HWDATA), .HWRITE(HWRITE), .HSELx(HSEL1),
    .HRDATA(HRDATA1), .HREADYOUT(HREADYOUT1), .HRESP(HRESP1)
    );

    AHB_Mem mem2( .HCLK(clk), .HRESETn(rst), .HADDR(HADDR), .HBURST(HBURST), .HMASTLOCK(HMASTLOCK), .HPROT(HPROT),
    .HREADY(HREADY), .HSIZE(HSIZE), .HTRANS(HTRANS), .HWDATA(HWDATA), .HWRITE(HWRITE), .HSELx(HSEL2),
    .HRDATA(HRDATA2), .HREADYOUT(HREADYOUT2), .HRESP(HRESP2)
    );
    
    AHB_CPU cpu( .HCLK(clk), .HRESETn(rst), .HRDATA(HRDATA), .HREADY(HREADY), .HRESP(HRESP), .HADDR(HADDR),
    .HBURST(HBURST), .HMASTLOCK(HMASTLOCK), .HPROT(HPROT), .HSIZE(HSIZE), .HTRANS(HTRANS), .HWDATA(HWDATA), .HWRITE(HWRITE)
    );
    
    Decoder dec( .HADDR(HADDR), .HSEL1(HSEL1), .HSEL2(HSEL2), .HMULTSEL(HMULTSEL)
    );

    Multiplexor mul( .MSEL(HMULTSEL), .HRDATA1(HRDATA1), .HREADYOUT1(HREADYOUT1), .HRESP1(HRESP1), .HRDATA2(HRDATA2),
    .HREADYOUT2(HREADYOUT2), .HRESP2(HRESP2), .HRDATA(HRDATA), .HREADY(HREADY), .HRESP(HRESP)
    );
    
    
    initial
    begin
        rst <=  0;
        clk <=  0;
        repeat(3) @(posedge clk);
        rst =   1;
        repeat(3) @(posedge clk);
        rst <=  0;
    end
    
        always@(posedge clk)
        if (cpu.ss == 3'b110)begin
            repeat(3) @(posedge clk);
            $finish;                    //The CPU has completed its operations SUCCESS!!
        end
endmodule
