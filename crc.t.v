// Adder testbench
`timescale 1 ns / 1 ps
`include "crc.v"

module testCRC();
    //CRC Validate I/O
    reg [0:479] crc_rx;
    reg [31:0] sending_crc_rx;
    reg [15:0] crc_ceiling;
    reg crc_rx_start;
    reg rx_clk;
    reg [5:0] fail_counter = 0;
    wire check_valid, check_passed;
    wire [31:0] checkCRC;
    wire [15:0] index;
    wire [1:0] state;


    //CRC Calculate I/O
    reg [0:479] udp_tx;
    reg udp_tx_start;
    wire [31:0] calculated_crc;
    wire tx_check_valid;
    wire [15:0] tx_index;
    wire [1:0] tx_state;
    wire [479:0] crc_to_check;
    reg [15:0] tx_crc_ceiling;

    //UDPIP_RX I/O
    reg [7:0] rx_udp;
    reg rx_udp_valid, rx_udp_first, rx_udp_last, rx_crc_check, rx_crc_valid;
    wire [479:0] rx_crc_in;
    wire [31:0] rx_received_crc;
    wire rx_crc_start;
    wire [15:0] rx_crc_ceiling;
    wire [7:0] rx_to_udp;
    wire rx_to_udp_valid;
    wire rx_to_udp_first;
    wire rx_to_udp_last; 
    wire [15:0] rx_udp_packet_ceiling;
    wire [2:0] rx_udp_state;

    //UDPIP_TX I/O
    reg [7:0] tx_from_udp;
    reg tx_from_udp_valid, tx_from_udp_first, tx_from_udp_last, tx_crc_valid;
    reg [31:0] tx_calculated_crc;
    wire [31:0] crc_calculated;
    wire [479:0] tx_crc_input;
    wire [15:0] tx_udp_crc_ceiling;
    wire tx_crc_start, tx_udp_valid, tx_udp_first, tx_udp_last;
    wire [7:0] tx_udp;
    wire [2:0] tx_udp_state;
    wire [543:0] output_buffer;
    wire [7:0] wait_counter;

    //CRC_TX I/O
    reg [7:0] crc_tx_from_udp;
    reg crc_tx_from_udp_first, crc_tx_from_udp_valid, crc_tx_from_udp_last;
    wire [7:0] crc_tx_udp_tx;
    wire crc_tx_udp_tx_first, crc_tx_udp_tx_valid, crc_tx_udp_tx_last;

    //CRC_RX I/O
    reg [7:0] crc_rx_udp_rx;
    reg crc_rx_udp_rx_valid, crc_rx_udp_rx_first, crc_rx_udp_rx_last;
    wire [7:0] crc_rx_to_udp;
    wire crc_rx_to_udp_valid, crc_rx_to_udp_first, crc_rx_to_udp_last;
    wire [2:0] state_null;
    wire crc_rx_crc_check, crc_rx_crc_valid;


    crc_validate rx_crc_test(.udp_rx(crc_rx),.sending_crc(sending_crc_rx),.crc_ceiling(crc_ceiling),.udp_rx_start(crc_rx_start),.clk(rx_clk),.check_valid(check_valid),.check_passed(check_passed),.checkCRC(checkCRC),.index(index),.state(state));

    crc_calculate tx_crc_test(.udp_tx(udp_tx),.crc_ceiling(tx_crc_ceiling),.udp_tx_start(udp_tx_start),.clk(rx_clk),.calculated_crc(calculated_crc),.check_valid(tx_check_valid),.index(tx_index),.state(tx_state),.crc_to_check(crc_to_check));

    udpip_rx testrx(.udp_rx(rx_udp),.udp_rx_valid(rx_udp_valid),.udp_rx_first(rx_udp_first),.udp_rx_last(rx_udp_last),.crc_check(rx_crc_check),.crc_valid(rx_crc_valid),.clk(rx_clk),.crc_in(rx_crc_in),.received_crc(rx_received_crc),.crc_start(rx_crc_start),.crc_ceiling(rx_crc_ceiling),.to_udp(rx_to_udp),.to_udp_valid(rx_to_udp_valid),.to_udp_first(rx_to_udp_first),.to_udp_last(rx_to_udp_last),.packet_ceiling(rx_udp_packet_ceiling),.state(rx_udp_state));

    udpip_tx testtx(.from_udp(tx_from_udp),.from_udp_valid(tx_from_udp_valid),.from_udp_first(tx_from_udp_first),.from_udp_last(tx_from_udp_last),.crc_valid(tx_crc_valid),.calculated_crc(tx_calculated_crc),.clk(rx_clk),.crc_input(tx_crc_input),.crc_ceiling(tx_udp_crc_ceiling),.crc_start(tx_crc_start),.udp_tx(tx_udp),.udp_tx_valid(tx_udp_valid),.udp_tx_first(tx_udp_first),.udp_tx_last(tx_udp_last),.state(tx_udp_state),.output_buffer(output_buffer),.crc_calculated(crc_calculated),.wait_counter(wait_counter));

    crc_tx crc_tx_test(.from_udp(crc_tx_from_udp),.from_udp_valid(crc_tx_from_udp_valid),.from_udp_first(crc_tx_from_udp_first),.from_udp_last(crc_tx_from_udp_last),.clk(rx_clk),.udp_tx(crc_tx_udp_tx),.udp_tx_valid(crc_tx_udp_tx_valid),.udp_tx_first(crc_tx_udp_tx_first),.udp_tx_last(crc_tx_udp_tx_last));

    crc_rx crc_rx_test(.udp_rx(crc_rx_udp_rx),.udp_rx_valid(crc_rx_udp_rx_valid),.udp_rx_first(crc_rx_udp_rx_first),.udp_rx_last(crc_rx_udp_rx_last),.clk(rx_clk),.to_udp(crc_rx_to_udp),.to_udp_valid(crc_rx_to_udp_valid),.to_udp_first(crc_rx_to_udp_first),.to_udp_last(crc_rx_to_udp_last),.state_null(state_null),.crc_valid_rx(crc_rx_crc_valid),.crc_check_rx(crc_rx_crc_check));

    initial begin
        rx_clk = 0;
    end

    always 
        #5 rx_clk = !rx_clk;

    initial begin
        //$dumpfile("crc.vcd");
    	//$dumpvars();
    	fail_counter = 0;

    	$display("Beginning CRC_Calculate Testing");
        udp_tx = {304'd0,176'h4c82ae9bf314c82ae9bf314c82ae9bf314c82ae9bf31}; tx_crc_ceiling = 16'd175; udp_tx_start = 1'b1; #10
        udp_tx_start = 1'b0;  #2500
        $display("%b %b",calculated_crc,tx_check_valid);

        $display("Beginning CRC Validate Testing");
        crc_rx = {304'd0,176'h4c82ae9bf314c82ae9bf314c82ae9bf314c82ae9bf31}; crc_ceiling = 16'd175; sending_crc_rx = 32'b00011000011000111001100110010110; crc_rx_start = 1'b1; #10
        crc_rx_start = 1'b0; #2500
        $display("%b %b %b %b %b",checkCRC,check_passed,check_valid, index, state);
        $display("Test 2: Intentionally wrong CRC");
        crc_rx = {304'd0,176'h4c82ae9bf314c82ae9bf314c82ae9bf314c82ae9bf31}; crc_ceiling = 16'd175; sending_crc_rx = 32'b10011000011000111001100110010110; crc_rx_start = 1'b1; #10
        crc_rx_start = 1'b0; #2500
        $display("%b %b %b %b %b",checkCRC,check_passed,check_valid, index, state);

        $display("Beginning UDP Rx Testing");
        rx_udp = 8'd12; rx_udp_valid = 1'b1; rx_udp_first = 1'b1; rx_udp_last = 1'b0; rx_crc_check = 1'b0; rx_crc_valid = 1'b0; #10
        rx_udp_first = 1'b0; rx_udp = 8'd1; #10
        rx_udp = 8'd28; #10
        rx_udp = 8'd14; #10
        rx_udp = 8'd7; #10
        rx_udp = 8'd23; #10
        rx_udp = 8'd57; #10
        rx_udp = 8'd53; #10
        rx_udp = 8'd33; #10
        rx_udp = 8'd101; rx_udp_last = 1'b1; #10
        rx_udp_last = 1'b0; #10
        $display("UDPIP: %b %b %b",rx_crc_ceiling,rx_received_crc, rx_udp_packet_ceiling); #110
        rx_crc_check = 1'b1; rx_crc_valid = 1'b1; #10
        $display("%b",rx_udp_state); #10
        $display("%b %b %b %b",rx_to_udp,rx_to_udp_valid,rx_to_udp_first,rx_to_udp_last); #10 //Expected to_udp: 00001100 to_udp_first: 1 to_udp_valid: 1 to_udp_last: 0 
        $display("%b %b %b %b",rx_to_udp,rx_to_udp_valid,rx_to_udp_first,rx_to_udp_last); #10 //Expected to_udp: 00000001 to_udp_first: 0 to_udp_valid: 1 to_udp_last: 0
        $display("%b %b %b %b",rx_to_udp,rx_to_udp_valid,rx_to_udp_first,rx_to_udp_last); #10 //Expected to_udp: 00011100 to_udp_first: 0 to_udp_valid: 1 to_udp_last: 0
        $display("%b %b %b %b",rx_to_udp,rx_to_udp_valid,rx_to_udp_first,rx_to_udp_last); #10 //Expected to_udp: 00001110 to_udp_first: 0 to_udp_valid: 1 to_udp_last: 0
        $display("%b %b %b %b",rx_to_udp,rx_to_udp_valid,rx_to_udp_first,rx_to_udp_last); #10 //Expected to_udp: 00000111 to_udp_first: 0 to_udp_valid: 1 to_udp_last: 0
        $display("%b %b %b %b",rx_to_udp,rx_to_udp_valid,rx_to_udp_first,rx_to_udp_last); #10 //Expected to_udp: 00010111 to_udp_first: 0 to_udp_valid: 1 to_udp_last: 1

        $display("Beginning UDP Tx Testing");
        //$display("%d",crc_calculated);
        tx_from_udp = 8'd12; tx_from_udp_valid = 1'b1; tx_from_udp_first = 1'b1; tx_from_udp_last = 1'b0; tx_crc_valid = 1'b0; #10
        tx_from_udp_first = 1'b0; tx_from_udp = 8'd1; #10
        tx_from_udp = 8'd28; #10
        tx_from_udp = 8'd14; #10
        tx_from_udp = 8'd7; #10
        tx_from_udp_last = 1'b1; 
        tx_from_udp = 8'd23; #10
        tx_from_udp_last = 1'b0; tx_from_udp_valid = 1'b0; #60
        tx_crc_valid = 1'b1; tx_calculated_crc = 32'd52; #10
        $display("TX: %b %b %b",tx_udp_crc_ceiling,wait_counter,tx_udp_state); #10//Expected wait_counter: 5 udp_state: 3
        $display("%b %b %b %b ",tx_udp,tx_udp_valid,tx_udp_first,tx_udp_last); #10 //Expected tx_udp: 12 tx_udp_valid: 1 tx_udp_first: 1 tx_udp_last: 0
        $display("%b %b %b %b ",tx_udp,tx_udp_valid,tx_udp_first,tx_udp_last); #10 //Expected tx_udp: 1 tx_udp_valid: 1 tx_udp_first: 0 tx_udp_last: 0
        $display("%b %b %b %b ",tx_udp,tx_udp_valid,tx_udp_first,tx_udp_last); #10 //Expected tx_udp: 28 tx_udp_valid: 1 tx_udp_first: 0 tx_udp_last: 0
        $display("%b %b %b %b ",tx_udp,tx_udp_valid,tx_udp_first,tx_udp_last); #10 //Expected tx_udp: 14 tx_udp_valid: 1 tx_udp_first: 0 tx_udp_last: 0
        $display("%b %b %b %b ",tx_udp,tx_udp_valid,tx_udp_first,tx_udp_last); #10 //Expected tx_udp: 7 tx_udp_valid: 1 tx_udp_first: 0 tx_udp_last: 0
        $display("%b %b %b %b ",tx_udp,tx_udp_valid,tx_udp_first,tx_udp_last); #10 //Expected tx_udp: 23 tx_udp_valid: 1 tx_udp_first: 0 tx_udp_last: 0
        $display("%b %b %b %b ",tx_udp,tx_udp_valid,tx_udp_first,tx_udp_last); #10 //Expected tx_udp: 0 tx_udp_valid: 1 tx_udp_first: 0 tx_udp_last: 0
        $display("%b %b %b %b ",tx_udp,tx_udp_valid,tx_udp_first,tx_udp_last); #10 //Expected tx_udp: 0 tx_udp_valid: 1 tx_udp_first: 0 tx_udp_last: 0
        $display("%b %b %b %b ",tx_udp,tx_udp_valid,tx_udp_first,tx_udp_last); #10 //Expected tx_udp: 0 tx_udp_valid: 1 tx_udp_first: 0 tx_udp_last: 0
        $display("%b %b %b %b ",tx_udp,tx_udp_valid,tx_udp_first,tx_udp_last); #10 //Expected tx_udp: 52 tx_udp_valid: 1 tx_udp_first: 0 tx_udp_last: 1
        $display("%b %b %b %b ",tx_udp,tx_udp_valid,tx_udp_first,tx_udp_last); #10 //Expected tx_udp: 52 tx_udp_valid: 0 tx_udp_first: 0 tx_udp_last: 0

        $display("Beginning CRC Tx Testing");
        crc_tx_from_udp = 8'd12; crc_tx_from_udp_valid = 1'b1; crc_tx_from_udp_first = 1'b1; crc_tx_from_udp_last = 1'b0; #10
        crc_tx_from_udp = 8'd1; crc_tx_from_udp_first = 1'b0; #10
        crc_tx_from_udp = 8'd8; #10
        crc_tx_from_udp = 8'd15; #10
        crc_tx_from_udp = 8'd28; #10
        crc_tx_from_udp = 8'd3; #10
        crc_tx_from_udp = 8'd21; #10
        crc_tx_from_udp_last = 1'b1; crc_tx_from_udp = 8'd35; #10
        crc_tx_from_udp_last = 1'b0; crc_tx_from_udp_valid = 1'b0; #540
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx: 8'd12 crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b1 crc_tx_udp_tx_last: 1'b0
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx: 8'd1 crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b0
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx: 8'd8 crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b0
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx: 8'd15 crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b0
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx: 8'd28 crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b0
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx: 8'd3 crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b0
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx: 8'd21 crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b0
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx: 8'd35 crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b0
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b0
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b0
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b0
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx_valid: 1'b1 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b1
        $display("%b %b %b %b",crc_tx_udp_tx,crc_tx_udp_tx_valid,crc_tx_udp_tx_first,crc_tx_udp_tx_last); #10 //Expected crc_tx_udp_tx_valid: 1'b0 crc_tx_udp_tx_first: 1'b0 crc_tx_udp_tx_last: 1'b0

        $display("Beginning CRC Rx Testing"); //64'hfe249112a8d90299 //
        crc_rx_udp_rx = 8'hfe; crc_rx_udp_rx_valid = 1'b1; crc_rx_udp_rx_first = 1'b1; crc_rx_udp_rx_last = 1'b0; #10
        crc_rx_udp_rx = 8'h24; crc_rx_udp_rx_first = 1'b0; #10
        crc_rx_udp_rx = 8'h91; #10
        crc_rx_udp_rx = 8'h12; #10
        crc_rx_udp_rx = 8'ha8; #10
        crc_rx_udp_rx = 8'hd9; #10
        crc_rx_udp_rx = 8'h02; #10
        crc_rx_udp_rx = 8'h99; #10
        crc_rx_udp_rx = 8'b11010010; #10
        crc_rx_udp_rx = 8'b10110001; #10
        crc_rx_udp_rx = 8'b11101010; #10
        crc_rx_udp_rx = 8'b11010010; crc_rx_udp_rx_last = 1'b1; #10
        crc_rx_udp_rx_last = 1'b0; crc_rx_udp_rx_valid = 1'b0; 
        #560
        $display("%b %b",crc_rx_crc_valid,crc_rx_crc_check); //Expected crc_valid: 1'b1 crc_check: 1'b1
        #10
        $display("%h %b %b %b",crc_rx_to_udp,crc_rx_to_udp_valid,crc_rx_to_udp_first,crc_rx_to_udp_last); #10 //Expected to_udp: fe udp_valid: 1'b1 to_udp_first: 1'b1 to_udp_last: 1'b0
        $display("%h %b %b %b",crc_rx_to_udp,crc_rx_to_udp_valid,crc_rx_to_udp_first,crc_rx_to_udp_last); #10 //Expected to_udp: 24 udp_valid: 1'b1 to_udp_first: 1'b0 to_udp_last: 1'b0
        $display("%h %b %b %b",crc_rx_to_udp,crc_rx_to_udp_valid,crc_rx_to_udp_first,crc_rx_to_udp_last); #10 //Expected to_udp: 91 udp_valid: 1'b1 to_udp_first: 1'b0 to_udp_last: 1'b0
        $display("%h %b %b %b",crc_rx_to_udp,crc_rx_to_udp_valid,crc_rx_to_udp_first,crc_rx_to_udp_last); #10 //Expected to_udp: 12 udp_valid: 1'b1 to_udp_first: 1'b0 to_udp_last: 1'b0
        $display("%h %b %b %b",crc_rx_to_udp,crc_rx_to_udp_valid,crc_rx_to_udp_first,crc_rx_to_udp_last); #10 //Expected to_udp: a8 udp_valid: 1'b1 to_udp_first: 1'b0 to_udp_last: 1'b0
        $display("%h %b %b %b",crc_rx_to_udp,crc_rx_to_udp_valid,crc_rx_to_udp_first,crc_rx_to_udp_last); #10 //Expected to_udp: d9 udp_valid: 1'b1 to_udp_first: 1'b0 to_udp_last: 1'b0
        $display("%h %b %b %b",crc_rx_to_udp,crc_rx_to_udp_valid,crc_rx_to_udp_first,crc_rx_to_udp_last); #10 //Expected to_udp: 02 udp_valid: 1'b1 to_udp_first: 1'b0 to_udp_last: 1'b0
        $display("%h %b %b %b",crc_rx_to_udp,crc_rx_to_udp_valid,crc_rx_to_udp_first,crc_rx_to_udp_last); #10 //Expected to_udp: 99 udp_valid: 1'b1 to_udp_first: 1'b0 to_udp_last: 1'b1



        $finish;
    end
endmodule

