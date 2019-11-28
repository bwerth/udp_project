// Adder testbench
`timescale 1 ns / 1 ps
`include "full.v"

module testCRC();

    //CRC_RING_BUFFER_RX I/O
    reg [7:0] udp_rx;
    reg udp_rx_valid, udp_rx_first, udp_rx_last, rd_en;
    reg wr_clk, rd_clk;
    wire [7:0] rddata;
    wire rd_first, rd_last, empty;

    //CRC_RING_BUFFER_TX I/O
    reg wr_en, wr_first, wr_last;
    reg [7:0] wrdata;
    wire [7:0] udp_tx;
    wire udp_tx_valid, udp_tx_first, udp_tx_last;

    //FULL RX I/O
    wire full_udp_rx_first, full_udp_rx_last, full_udp_rx_valid, full_rx_out_valid, full_rx_out_first, full_rx_out_last;
    wire [7:0] full_udp_rx, full_rx_out;

    //FULL TX I/O
    reg full_tx_in_valid, full_tx_in_first, full_tx_in_last;
    wire full_udp_tx_valid, full_udp_tx_first, full_udp_tx_last;
    reg [7:0] full_tx_in;
    wire [7:0] full_udp_tx, full_rddata;
    wire full_rd_valid, full_rd_first, full_rd_last;


    crc_ring_buffer_rx testRingBufferRx(.udp_rx(udp_rx),.udp_rx_valid(udp_rx_valid),.udp_rx_first(udp_rx_first),.udp_rx_last(udp_rx_last),.wr_clk(rd_clk),.rd_clk(rd_clk),.rd_en(rd_en),.rddata(rddata),.rd_first(rd_first),.rd_last(rd_last),.empty(empty));

    crc_ring_buffer_tx testRingBufferTx(.rd_clk(rd_clk),.wr_clk(wr_clk),.wr_en(wr_en),.wr_first(wr_first),.wr_last(wr_last),.wrdata(wrdata),.udp_tx(udp_tx),.udp_tx_valid(udp_tx_valid),.udp_tx_first(udp_tx_first),.udp_tx_last(udp_tx_last));

    udp_tx_full testFullTx(.rd_clk(rd_clk),.wr_clk(wr_clk),.tx_in(full_tx_in),.tx_in_valid(full_tx_in_valid),.tx_in_first(full_tx_in_first),.tx_in_last(full_tx_in_last),.udp_tx(full_udp_tx),.udp_tx_valid(full_udp_tx_valid),.udp_tx_first(full_udp_tx_first),.udp_tx_last(full_udp_tx_last),.rddata(full_rddata),.rd_valid(full_rd_valid),.rd_first(full_rd_first),.rd_last(full_rd_last));

    udp_rx_full testFullRx(.rd_clk(rd_clk),.wr_clk(wr_clk),.udp_rx_first(full_udp_tx_first),.udp_rx_last(full_udp_tx_last),.udp_rx_valid(full_udp_tx_valid),.udp_rx(full_udp_tx),.rx_out(full_rx_out),.rx_out_valid(full_rx_out_valid),.rx_out_first(full_rx_out_first),.rx_out_last(full_rx_out_last));

    initial begin
        wr_clk = 0;
        rd_clk = 0;
    end

    always 
        #5 wr_clk = !wr_clk;

    always
        #5 rd_clk = !rd_clk;

    initial begin
        //$dumpfile("crc.vcd");
    	//$dumpvars();

        $display("Begin Tx Testing");
    	udp_rx = 8'hfe; udp_rx_valid = 1'b1; udp_rx_first = 1'b1; udp_rx_last = 1'b0; #10
        udp_rx = 8'h24; udp_rx_first = 1'b0; #10
        udp_rx = 8'h91; #10
        udp_rx = 8'h12; #10
        udp_rx = 8'ha8; #10
        udp_rx = 8'hd9; #10
        udp_rx = 8'h02; #10
        udp_rx = 8'h99; #10
        udp_rx = 8'b11010010; #10
        udp_rx = 8'b10110001; #10
        udp_rx = 8'b11101010; #10
        udp_rx = 8'b11010010; udp_rx_last = 1'b1; #10
        udp_rx_last = 1'b0; udp_rx_valid = 1'b0; 
        #700
        $display("EMPTY? %b",empty); //Expected empty: 0
        rd_en = 1'b1; #10
        $display("%h %b %b",rddata,rd_first,rd_last); #10 //Expected rddata: fe rd_first: 1
        $display("%h %b %b",rddata,rd_first,rd_last); #10 //Expected rddata: 24
        $display("%h %b %b",rddata,rd_first,rd_last); #10 //Expected rddata: 91
        $display("%h %b %b",rddata,rd_first,rd_last); #10 //Expected rddata: 12
        $display("%h %b %b",rddata,rd_first,rd_last); #10 //Expected rddata: a8
        $display("%h %b %b",rddata,rd_first,rd_last); #10 //Expected rddata: d9
        $display("%h %b %b %b",rddata,rd_first,rd_last,empty); #10 //Expected rddata: 02 empty: 0
        //$display("%h %b %b %b",rddata,rd_first,rd_last,empty); #10 //Expected rddata: 99 rd_last: 1 empty: 1

        $display("Begin Rx Testing");
        wr_first = 1'b1; wr_last = 1'b0; wr_en = 1'b1; wrdata = 8'hfe; #10
        wr_first = 1'b0; wrdata = 8'h24; #10
        wrdata = 8'h91; #10
        wrdata = 8'h12; #10
        wrdata = 8'ha8; #10
        wrdata = 8'hd9; #10
        wrdata = 8'h02; #10
        wrdata = 8'h99; wr_last = 1'b1; #10
        wr_last = 1'b0; wr_en = 1'b0; #550
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 //Expected udp_tx: fe udp_tx_valid: 1 udp_tx_first: 1 
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 //Expected udp_tx: 24 udp_tx_valid: 1
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 //Expected udp_tx: 91 udp_tx_valid: 1  
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 //Expected udp_tx: 12 udp_tx_valid: 1
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 //Expected udp_tx: a8 udp_tx_valid: 1
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 //Expected udp_tx: d9 udp_tx_valid: 1
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 //Expected udp_tx: 02 udp_tx_valid: 1
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 //Expected udp_tx: 99 udp_tx_valid: 1
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 // udp_tx_valid: 1
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 // udp_tx_valid: 1
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 // udp_tx_valid: 1
        $display("%h %b %b %b",udp_tx,udp_tx_valid,udp_tx_first,udp_tx_last); #10 // udp_tx_valid: 1 udp_tx_last: 1

        $display("Begin Full Tx Testing");
        full_tx_in_valid = 1'b1;
        full_tx_in_first = 1'b1;
        full_tx_in_last = 1'b0;
        full_tx_in = 8'b01001010; #10
        //$display("%b",state);
        full_tx_in_first = 1'b0;
        full_tx_in = 8'd49; #10 //Total Length
        full_tx_in = 8'd112; #10
        full_tx_in = 8'd57; #10 //ID
        full_tx_in = 8'd14; #10 
        full_tx_in = 8'd21; #10 // Flafrag
        full_tx_in = 8'd98; #10
        full_tx_in = 8'd100; #10
        full_tx_in = 8'd49; #10
        full_tx_in = 8'd48; #10 //Source IP
        full_tx_in = 8'd88; #10
        full_tx_in = 8'd11; #10
        full_tx_in = 8'd1; #10
        full_tx_in = 8'd79; #10 //Destination IP
        full_tx_in = 8'd81; #10 
        full_tx_in = 8'd44; #10
        full_tx_in = 8'd49; #10
        full_tx_in = 8'd91; #10 //Source Port
        full_tx_in = 8'd12; #10
        full_tx_in = 8'd21; #10 //Destination Port
        full_tx_in = 8'd65; #10
        full_tx_in = 8'd31; #10 //UDP Length
        full_tx_in = 8'd52; #10
        full_tx_in = 8'd107; #10 //Data
        full_tx_in = 8'd98; #10 
        full_tx_in = 8'd84; #10
        full_tx_in = 8'd42; #10
        full_tx_in = 8'd107; #10
        full_tx_in_last = 8'd1; 
        full_tx_in = 8'd98; #10
        full_tx_in_last = 8'd0;
        full_tx_in_valid = 1'b0; #4050
        $display("%b %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 24 udp_tx_valid: 1 udp_tx_first: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 0 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 49 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 112 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 57 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 14 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 21 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 98 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 100 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 49 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 48 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 88 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 11 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 1 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 79 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 81 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 44 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 49 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 91 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 12 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 21 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 65 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 31 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #30 //Expected udp_tx: 52 udp_tx_valid: 1 #10
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 107 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 98 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 84 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 42 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx: 107 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #40 //Expected udp_tx: 98 udp_tx_valid: 1
        $display("%d %b %b %b",full_udp_tx,full_udp_tx_valid,full_udp_tx_first,full_udp_tx_last); #10 //Expected udp_tx_valid: 1 udp_tx_last: 1

        $display("Begin Full Rx Testing"); #4370
        $display("%d %b %b %b",full_rx_out,full_rx_out_valid,full_rx_out_first,full_rx_out_last); #10 //Expected: rx_out: 107 rx_out_valid: 1 rx_out_first: 1
        $display("%d %b %b %b",full_rx_out,full_rx_out_valid,full_rx_out_first,full_rx_out_last); #10 //Expected: rx_out: 98 rx_out_valid: 1
        $display("%d %b %b %b",full_rx_out,full_rx_out_valid,full_rx_out_first,full_rx_out_last); #10 //Expected: rx_out: 84 rx_out_valid: 1
        $display("%d %b %b %b",full_rx_out,full_rx_out_valid,full_rx_out_first,full_rx_out_last); #10 //Expected: rx_out: 42 rx_out_valid: 1
        $display("%d %b %b %b",full_rx_out,full_rx_out_valid,full_rx_out_first,full_rx_out_last); #10 //Expected: rx_out: 107 rx_out_valid: 1
        $display("%d %b %b %b",full_rx_out,full_rx_out_valid,full_rx_out_first,full_rx_out_last); #10 //Expected: rx_out: 98 rx_out_valid: 1 rx_out_last: 1


        $finish;

    end
endmodule