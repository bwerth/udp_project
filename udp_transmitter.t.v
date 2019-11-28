// Receiver testbench
`timescale 1 ns / 1 ps
`include "udp_transmitter.v"

module testTransmitter();
    reg clk, tx_in_valid, tx_in_first, tx_in_last;
    reg [7:0] tx_in;
    wire wr_valid, wr_first, wr_last;
    wire [7:0] wrdata;
    wire [2:0] state;
    wire [31:0] source_ip, udp_checksum;
    wire [1:0] udp_state,ip_state;
    wire [15:0] udp_index;
    wire [31:0] ip_checksum;
    wire [159:0] ip_header;
    wire [7:0] input_test;
    wire [2:0] out_state;
    wire [15:0] out_index;
    wire [63:0] udp_header;

    udpip_transmitter test_transmitter(.clk(clk),.tx_in(tx_in),.tx_in_valid(tx_in_valid),.tx_in_first(tx_in_first),.tx_in_last(tx_in_last),.wr_valid(wr_valid),.wrdata(wrdata),.wr_first(wr_first),.wr_last(wr_last),.state(state),.source_ip(source_ip),.udp_checksum(udp_checksum),.udp_state(udp_state),.udp_index(udp_index),.ip_checksum(ip_checksum),.ip_state(ip_state),.ip_header(ip_header),.input_test(input_test),.out_state(out_state),.out_index(out_index),.udp_header(udp_header));

    initial begin
        clk = 0;
    end

    always 
        #5 clk = !clk;

    initial begin
        //$dumpfile("crc.vcd");
    	//$dumpvars();
        $display("Beginning Transmitter Testing");
        tx_in_valid = 1'b1;
        tx_in_last = 1'b0;
        tx_in = 8'd24; #10
        $display("%b",state);
        tx_in = 8'd49; #10 //Total Length
        tx_in = 8'd112; #10
        tx_in = 8'd57; #10 //ID
        tx_in = 8'd14; #10 
        tx_in = 8'd21; #10 // Flafrag
        tx_in = 8'd98; #10
        tx_in = 8'd100; #10
        tx_in = 8'd49; #10
        tx_in = 8'd48; #10 //Source IP
        tx_in = 8'd88; #10
        tx_in = 8'd11; #10
        tx_in = 8'd1; #10
        tx_in = 8'd79; #10 //Destination IP
        tx_in = 8'd81; #10 
        tx_in = 8'd44; #10
        tx_in = 8'd49; #10
        tx_in = 8'd91; #10 //Source Port
        tx_in = 8'd12; #10
        tx_in = 8'd21; #10 //Destination Port
        tx_in = 8'd65; #10
        tx_in = 8'd31; #10 //UDP Length
        tx_in = 8'd52; #10
        tx_in = 8'd107; #10 //Data
        tx_in = 8'd98; #10 
        tx_in = 8'd84; #10
        tx_in = 8'd42; #10
        tx_in = 8'd107; #10
        tx_in_last = 8'd1; 
        $display("%b",state);
        tx_in = 8'd98; #10
        tx_in_last = 8'd0;
        $display("%b %b",state,source_ip); #10 // Expected Source_IP: 00110000010110000000101100000001
        $display("%b %b %b %b",state,udp_state,udp_checksum,udp_index); #40// Expected udp_checksum: 10110010111000001
        $display("%b %b %b %b",state,udp_state,udp_checksum,udp_index); #30 //Expected udp_checksum: 1001000010110001
        $display("%b %b %b",state,ip_state,ip_checksum); #20 //Expected ip_checksum: 1011001011101101
        $display("%b %b %b %b",wrdata, wr_valid, wr_first, wr_last); #10 //Expected wrdata: 00011000
        $display("%b %b %b %b",wrdata, wr_valid, wr_first, wr_last); #70 //Expected wrdata: 00000000
        $display("%b %b %b %b %b %b %b",state, out_state, out_index, wrdata, wr_valid, wr_first, wr_last); #120 //Expected wrdata: 01100100
        $display("%b %b %b %b %b %b %b",state, out_state, out_index, wrdata, wr_valid, wr_first, wr_last); #70 //Expected wrdata: 01011011
        $display("%b %b %b %b %b %b %b",state, out_state, out_index, wrdata, wr_valid, wr_first, wr_last); #60 //Expected wrdata: 10110001
        $display("%b %b %b %b %b %b %b",state, out_state, out_index, wrdata, wr_valid, wr_first, wr_last); #10 //Expected wrdata: 01100010
        $display("%b %b %b %b %b %b %b",state, out_state, out_index, wrdata, wr_valid, wr_first, wr_last); //Expected wrdata: 01100010 wr_valid: 0 wr_last: 0
        $finish;
    end

endmodule

//0000000000110001 + 0001111100110100 + 0011000001011000 + 0000101100000001 + 0100111101010001 + 0010110000110001 + 0101101100001100 + 0001010101000001 + 0001111100110100
//0110101101100010 + 0101010000101010 + 0110101101100010

//0001100000000000 + 0011000101110000 + 0011100100001110 + 0001010101100010 + 0110010000110001 + 0011000001011000 + 0000101100000001 + 0100111101010001 + 0010110000110001

