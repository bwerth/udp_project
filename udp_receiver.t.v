// Receiver testbench
`timescale 1 ns / 1 ps
`include "udp_receiver.v"

module testReceiver();
    reg [7:0] rddata;
    reg rd_first, rd_last, rd_valid, clk;
    reg pass_counter;
    wire rx_out_valid, rx_out_first, rx_out_last;
    wire [7:0] rx_out;
    wire [2:0] state;
    wire [31:0] ipv4_checksum;
    wire [15:0] packet_ceiling, ipv4_checksum_index, udp_checksum_index, ipv4_received_checksum, udp_received_checksum;
    wire [3:0] ip_version;

    udpip_receiver test_receiver(.rddata(rddata),.rd_first(rd_first),.rd_last(rd_last),.rd_valid(rd_valid),.clk(clk),.rx_out(rx_out),.rx_out_valid(rx_out_valid),.rx_out_first(rx_out_first),.rx_out_last(rx_out_last),.state(state),.ipv4_checksum(ipv4_checksum),.packet_ceiling(packet_ceiling),.ipv4_checksum_index(ipv4_checksum_index),.udp_checksum_index(udp_checksum_index),.ipv4_received_checksum(ipv4_received_checksum),.ip_version(ip_version),.udp_received_checksum(udp_received_checksum));

    initial begin
        clk = 0;
    end

    always 
        #5 clk = !clk;

    initial begin
        //$dumpfile("crc.vcd");
    	//$dumpvars();
        pass_counter = 0;
        $display("Beginning Receiver Testing");
        rd_valid = 1'b1;
        $display("%b",state);
        rddata = 8'b01001011;
        rd_first = 1'b1; 
        rd_last = 1'b0; #10
        rddata = 8'd27;
        rd_first = 1'b0; #10
        rddata = 8'd123; #10
        rddata = 8'd57; #10
        rddata = 8'd42; #10
        rddata = 8'd83; #10
        rddata = 8'b00000010; #10
        rddata = 8'd23; #10
        rddata = 8'd127; #10 //TTL
        rddata = 8'd17; #10 //protocol
        rddata = 8'b00101000; #10 //Header Checksum
        rddata = 8'b11100001 ; #10 
        rddata = 8'd15; #10 //Source IP
        rddata = 8'd42; #10 
        rddata = 8'd84; #10
        rddata = 8'd100; #10
        rddata = 8'd32; #10 //Destination IP
        rddata = 8'd29; #10 
        rddata = 8'd51; #10
        rddata = 8'd101; #10
        rddata = 8'd42; #10 //Start UDP Packet Header // Source Port
        rddata = 8'd25; #10
        rddata = 8'd101; #10 //Destination Port
        rddata = 8'd85; #10
        rddata = 8'd77; #10 // UDP Length
        rddata = 8'd66; #10 
        rddata = 8'b10100000; #10 //UDP Checksum
        rddata = 8'b00011010; #10
        rddata = 8'b00001111; #10 //Data
        rddata = 8'b01111011; #10
        rddata = 8'b01010111; #10
        rddata = 8'b11000101; #10
        rddata = 8'b01010111; #10
        rd_last = 1'b1;
        rddata = 8'b11000101; #10
        rd_last = 1'b0;
        $display("%b",packet_ceiling); #110
        $display("%b %b %b %b %b",state,ipv4_checksum[15:0],ipv4_received_checksum,ipv4_checksum_index,ip_version); #100
        $display("%b %b %b %b",state,ipv4_checksum[15:0],udp_received_checksum,udp_checksum_index); #10
        $display("%b",state); #10
        $display("%b %b %b %b",rx_out,rx_out_valid,rx_out_first,rx_out_last); #10
        $display("%b %b %b %b",rx_out,rx_out_valid,rx_out_first,rx_out_last); #10
        $display("%b %b %b %b",rx_out,rx_out_valid,rx_out_first,rx_out_last); #10
        $display("%b %b %b %b",rx_out,rx_out_valid,rx_out_first,rx_out_last); #10
        $display("%b %b %b %b",rx_out,rx_out_valid,rx_out_first,rx_out_last); #10
        $display("%b %b %b %b",rx_out,rx_out_valid,rx_out_first,rx_out_last); #10
        $finish;
    end

endmodule

//0010101100011011 + 0111101100111001 + 0010101001010011 + 0000001000010111 + 0111111100010001 + //0000111100101010 + 0101010001100100 + 0010000000011101 + 0011001101100101 + 0000100011100001

//0000111100101010 + 0101010001100100 + 0010000000011101 + 0011001101100101 + 0000000000010001 + 0100110101000010 + 0010101000011001 + 0110010101010101 + 0000111101111011 + 0100110101000010
