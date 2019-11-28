// Receiver testbench
`timescale 1 ns / 1 ps
`include "ring_buffer_64.v"

module testRing();
	reg rd_clk, wr_clk, rd_en, wr_en, wr_first, wr_last;
	reg [7:0] wrdata;
	wire rd_first, rd_last, empty;
	wire [7:0] rddata;
	wire [6:0] rd_pointer,wr_pointer;

    ring_buffer_64 test_buffer(.rd_clk(rd_clk),.wr_clk(wr_clk),.rd_en(rd_en),.wr_en(wr_en),.wr_first(wr_first),.wr_last(wr_last),.wrdata(wrdata),.rddata(rddata),.rd_first(rd_first),.rd_last(rd_last),.empty(empty),.rd_pointer(rd_pointer),.wr_pointer(wr_pointer));

    initial begin
        wr_clk = 0;
        rd_clk = 0;
    end

    always 
        #5 wr_clk = !wr_clk;

    always 
    	#8 rd_clk = !rd_clk;

    initial begin
        //$dumpfile("crc.vcd");
    	//$dumpvars();
        $display("Beginning Ring Buffer Testing");
     	$display("%b %b",empty,rddata); //Expected empty: 1'b1 rddata: 8'b0
     	wr_en = 1'b1; wr_first = 1'b1; wr_last = 1'b0; wrdata = 8'd17; #10
     	$display("%b %b",empty,rddata); //Expected empty: 1'b0 rddata: 8'b0
     	wr_first = 1'b0; wrdata = 8'd8; #10
     	wrdata = 8'd100; #10
     	wrdata = 8'd42; wr_last = 1'b1; #10
     	wr_last = 1'b0; wr_en = 1'b0;
     	$display("%b %b",empty,rddata);  //Expected empty: 1'b0 rddata: 8'b0
     	rd_en = 1'b1; #16
     	$display("%b %b %b %b %b %b",rddata,rd_first,rd_last,empty,wr_pointer,rd_pointer); #16
		$display("%b %b %b %b %b %b",rddata,rd_first,rd_last,empty,wr_pointer,rd_pointer); #16
		$display("%b %b %b %b %b %b",rddata,rd_first,rd_last,empty,wr_pointer,rd_pointer); #16
		$display("%b %b %b %b %b %b",rddata,rd_first,rd_last,empty,wr_pointer,rd_pointer); #16
		$display("%b %b %b %b %b %b",rddata,rd_first,rd_last,empty,wr_pointer,rd_pointer); #16
        $finish;
    end

endmodule