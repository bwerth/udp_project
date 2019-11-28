`timescale 1ns / 1ps
`include "crc.v"
`include "ring_buffer_64.v"
`include "udp_receiver.v"
`include "udp_transmitter.v"

module crc_ring_buffer_rx(
	input [7:0] udp_rx,
	input udp_rx_valid,
	input udp_rx_first,
	input udp_rx_last,
	input wr_clk,
	input rd_clk,
	input rd_en,
	output [7:0] rddata,
	output rd_first,
	output rd_last,
	output empty
);

	// Inter-module connection wires
	wire [7:0] wrdata;
	wire wr_en, wr_first, wr_last;

	// Null wires for test bench control signals
	wire [2:0] state_null;
	wire crc_valid_null, crc_check_null, empty;
	wire [6:0] rd_null, wr_null;
	
	crc_rx crcrx(.udp_rx(udp_rx),.udp_rx_valid(udp_rx_valid),.udp_rx_first(udp_rx_first),.udp_rx_last(udp_rx_last),.clk(wr_clk),.to_udp(wrdata),.to_udp_valid(wr_en),.to_udp_first(wr_first),.to_udp_last(wr_last),.state_null(state_null),.crc_valid_rx(crc_valid_null),.crc_check_rx(crc_check_null));

	ring_buffer_64 rb64(.rd_clk(rd_clk),.wr_clk(wr_clk),.rd_en(rd_en),.wr_en(wr_en),.wr_first(wr_first),.wr_last(wr_last),.wrdata(wrdata),.rddata(rddata),.rd_first(rd_first),.rd_last(rd_last),.empty(empty),.rd_pointer(rd_null),.wr_pointer(wr_null));

endmodule

module crc_ring_buffer_tx(
	input rd_clk,
	input wr_clk,
	input wr_en,
	input wr_first,
	input wr_last,
	input [7:0] wrdata,
	output [7:0] udp_tx,
	output udp_tx_valid,
	output udp_tx_first,
	output udp_tx_last
);

	// Inter-module connection wires
	wire rd_valid, rd_first, rd_last, empty;
	wire [7:0] rddata;

	// Null wires for test bench control signals
	wire [6:0] wr_null, rd_null;

	assign rd_en = ~empty;

	ring_buffer_64_tx rb64(.rd_clk(rd_clk),.wr_clk(wr_clk),.wr_en(wr_en),.wr_first(wr_first),.wr_last(wr_last),.wrdata(wrdata),.rddata(rddata),.rd_first(rd_first),.rd_last(rd_last),.rd_valid(rd_valid),.rd_pointer(rd_null),.wr_pointer(wr_null));

	crc_tx crctx(.from_udp(rddata),.from_udp_valid(rd_valid),.from_udp_first(rd_first),.from_udp_last(rd_last),.clk(rd_clk),.udp_tx(udp_tx),.udp_tx_valid(udp_tx_valid),.udp_tx_first(udp_tx_first),.udp_tx_last(udp_tx_last));

endmodule

module udp_rx_full(
	input rd_clk,
	input wr_clk,
	input udp_rx_first,
	input udp_rx_last,
	input udp_rx_valid,
	input [7:0] udp_rx,
	output [7:0] rx_out,
	output rx_out_valid,
	output rx_out_first,
	output rx_out_last
);

	// Inter-module connection wires
	wire [7:0] wrdata;
	wire wr_en, wr_first, wr_last;
	wire rd_valid, rd_first, rd_last;
	wire [7:0] rddata;


	// Null wires for test bench control signals
	wire [2:0] state_null;
	wire crc_valid_null, crc_check_null;
	wire [6:0] rd_null, wr_null;
	wire [31:0] ip_null;
	wire [15:0] packet_null,ip_index_null,udp_index_null,ipv4_received_null,udp_received_null;
	wire [3:0] version_null;

	crc_rx crcrx(.udp_rx(udp_rx),.udp_rx_valid(udp_rx_valid),.udp_rx_first(udp_rx_first),.udp_rx_last(udp_rx_last),.clk(wr_clk),.to_udp(wrdata),.to_udp_valid(wr_en),.to_udp_first(wr_first),.to_udp_last(wr_last),.state_null(state_null),.crc_valid_rx(crc_valid_null),.crc_check_rx(crc_check_null));

	ring_buffer_64_tx rb64(.rd_clk(rd_clk),.wr_clk(wr_clk),.wr_en(wr_en),.wr_first(wr_first),.wr_last(wr_last),.wrdata(wrdata),.rddata(rddata),.rd_first(rd_first),.rd_last(rd_last),.rd_valid(rd_valid),.rd_pointer(rd_null),.wr_pointer(wr_null));

	udpip_receiver receiver(.rddata(rddata),.rd_first(rd_first),.rd_last(rd_last),.rd_valid(rd_valid),.clk(rd_clk),.rx_out(rx_out),.rx_out_valid(rx_out_valid),.rx_out_first(rx_out_first),.rx_out_last(rx_out_last),.state(state_null),.ipv4_checksum(ip_null),.packet_ceiling(packet_null),.ipv4_checksum_index(ip_index_null),.udp_checksum_index(udp_index_null),.ipv4_received_checksum(ipv4_received_null),.ip_version(version_null),.udp_received_checksum(udp_received_null));

	always @ (negedge rd_clk) begin
		//$display("WINNING %d %b %b %b",rddata,rd_en,rd_first,rd_last);
	end

endmodule

module udp_tx_full(
	input rd_clk,
	input wr_clk,
	input [7:0] tx_in,
	input tx_in_valid,
	input tx_in_first,
	input tx_in_last,
	output [7:0] udp_tx,
	output udp_tx_valid,
	output udp_tx_first,
	output udp_tx_last,
	output [7:0] rddata,
	output rd_valid,
	output rd_first,
	output rd_last
);

	// Inter-module connection wires
	wire rd_valid, rd_first, rd_last, wr_en, wr_first, wr_last;
	wire [7:0] rddata, wrdata;

	// Null wires for test bench control signals
	wire [6:0] wr_null, rd_null;
	wire [2:0] state, out_state;
	wire [31:0] source_ip, udp_checksum, ip_checksum;
	wire [1:0] udp_state, ip_state;
	wire [15:0] udp_index, out_index;
	wire [159:0] ip_header;
	wire [7:0] input_test;
	wire [63:0] udp_header;

	udpip_transmitter transmitter(.clk(wr_clk),.tx_in(tx_in),.tx_in_valid(tx_in_valid),.tx_in_first(tx_in_first),.tx_in_last(tx_in_last),.wr_valid(wr_en),.wrdata(wrdata),.wr_first(wr_first),.wr_last(wr_last),.state(state),.source_ip(source_ip),.udp_checksum(udp_checksum),.udp_state(udp_state),.udp_index(udp_index),.ip_checksum(ip_checksum),.ip_state(ip_state),.ip_header(ip_header),.input_test(input_test),.out_state(out_state),.out_index(out_index),.udp_header(udp_header));

	ring_buffer_64_tx rb64(.rd_clk(rd_clk),.wr_clk(wr_clk),.wr_en(wr_en),.wr_first(wr_first),.wr_last(wr_last),.wrdata(wrdata),.rddata(rddata),.rd_first(rd_first),.rd_last(rd_last),.rd_valid(rd_valid),.rd_pointer(rd_null),.wr_pointer(wr_null));

	crc_tx crctx(.from_udp(rddata),.from_udp_valid(rd_valid),.from_udp_first(rd_first),.from_udp_last(rd_last),.clk(rd_clk),.udp_tx(udp_tx),.udp_tx_valid(udp_tx_valid),.udp_tx_first(udp_tx_first),.udp_tx_last(udp_tx_last));

endmodule