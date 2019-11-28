`timescale 1 ns / 1 ps

module udpip_receiver(
	input [7:0] rddata,
	input rd_first,
	input rd_last,
	input rd_valid,
	input clk,
	output [7:0] rx_out,
	output rx_out_valid,
	output rx_out_first,
	output rx_out_last,
	output [2:0] state,
	output [31:0] ipv4_checksum,
	output [15:0] packet_ceiling,
	output [15:0] ipv4_checksum_index,
	output [15:0] udp_checksum_index,
	output [15:0] ipv4_received_checksum,
	output [3:0] ip_version,
	output [15:0] udp_received_checksum
);

reg [15:0] calculated_ipv4_checksum;
reg [2:0] state = 3'b0;
reg [1:0] ip_state = 2'b0;
reg [15:0] ipv4_checksum_index = 0;
reg [15:0] udp_checksum_index = 0;
reg [15:0] packet_ceiling = 0;
reg [7:0] input_buffer [0:255];
reg [31:0] ipv4_checksum = 0;
reg [31:0] ipv4_checksum_carryover = 0;
reg [15:0] ipv4_received_checksum;
reg [3:0] ip_version;
reg [31:0] source_ip;
reg [31:0] destination_ip;
reg [7:0] udp_protocol = 8'd17;
reg [15:0] udp_packet_length;
reg [7:0] rx_out;
reg rx_out_valid, rx_out_first, rx_out_last;
wire rd_valid;
wire [15:0] udp_received_checksum;

always @ (negedge clk) begin
	if (state == 3'b0 && rd_valid) begin
		state = 3'b1;
		input_buffer[packet_ceiling] = rddata;
		packet_ceiling = packet_ceiling + 1;
	end else if (state == 3'b1 && rd_last == 1'b1 && rd_valid) begin
		input_buffer[packet_ceiling] = rddata;
		state = 3'd2;
	end else if (state == 3'b1 && rd_last == 1'b0 && rd_valid) begin
		input_buffer[packet_ceiling] = rddata;
		packet_ceiling = packet_ceiling + 1;
	//Begin ipv4 checksum calculation
	end else if (state == 3'd2 && ip_state == 2'b0 && ipv4_checksum_index == 16'd20 && ipv4_checksum[31:16] > 16'b0) begin
		ipv4_checksum_carryover = {16'b0,ipv4_checksum[31:16]};
		ipv4_checksum = {16'b0,ipv4_checksum[15:0]};
		ipv4_checksum = ipv4_checksum + ipv4_checksum_carryover;
	end else if (state == 3'd2 && ip_state == 2'd0 && ipv4_checksum_index == 16'd20) begin
		ipv4_checksum_index = 16'b0;
		ip_state = 2'd1;
		ipv4_received_checksum = {input_buffer[10],input_buffer[11]};
		ip_version = input_buffer[0][7:4];
	end else if (state == 3'd2 && ip_state == 2'd0 && ipv4_checksum_index == 16'd8) begin
		ipv4_checksum = {16'b0,input_buffer[ipv4_checksum_index],input_buffer[ipv4_checksum_index+1]} + ipv4_checksum;
		ipv4_checksum_index = ipv4_checksum_index + 4;
	end else if (state == 3'd2 && ip_state == 2'd0) begin
		ipv4_checksum = {16'b0,input_buffer[ipv4_checksum_index],input_buffer[ipv4_checksum_index+1]} + ipv4_checksum;
		ipv4_checksum_index = ipv4_checksum_index + 2;
	end else if (state == 3'd2 && ip_state == 2'd1 && ipv4_received_checksum == ipv4_checksum[15:0] && packet_ceiling > 16'd20 && ip_version == 4'd4) begin
		state = 3'd3;
		ip_state = 2'b0;
		ipv4_checksum = 16'b0;
		source_ip = {input_buffer[12],input_buffer[13],input_buffer[14],input_buffer[15]};
		destination_ip = {input_buffer[16],input_buffer[17],input_buffer[18],input_buffer[19]};
		udp_packet_length = {input_buffer[24],input_buffer[25]};
	end else if (state == 3'd2 && ip_state == 2'd1) begin
		state = 3'b0;
		ip_state = 2'b0;
		ipv4_checksum = 16'b0;
		packet_ceiling = 16'b0;
	end else if (state == 3'd3 && udp_checksum_index == 0) begin
		ipv4_checksum = {16'b0,source_ip[31:16]} + {16'b0,source_ip[15:0]} + {16'b0,destination_ip[31:16]} + {16'b0,destination_ip[15:0]} + {24'b0,udp_protocol} + {16'b0,udp_packet_length};
		udp_checksum_index = udp_checksum_index + 1;
	end else if (state == 3'd3 && udp_checksum_index < (packet_ceiling-19) && udp_checksum_index == 16'd7) begin
		udp_checksum_index = udp_checksum_index + 2;
	end else if (state == 3'd3 && udp_checksum_index < (packet_ceiling-19)) begin
		ipv4_checksum = ipv4_checksum + {16'b0,input_buffer[19+udp_checksum_index],input_buffer[20+udp_checksum_index]};
		udp_checksum_index = udp_checksum_index + 2;
	end else if (state == 3'd3 && udp_checksum_index >= (packet_ceiling-19) && ipv4_checksum[31:16] > 16'b0) begin
		ipv4_checksum_carryover = {16'b0,ipv4_checksum[31:16]};
		ipv4_checksum = {16'b0,ipv4_checksum[15:0]};
		ipv4_checksum = ipv4_checksum + ipv4_checksum_carryover;
	end else if (state == 3'd3 && udp_checksum_index >= (packet_ceiling-19) && ipv4_checksum == {input_buffer[26],input_buffer[27]}) begin
		state = 3'd4;
		ipv4_checksum = 0;
		udp_checksum_index = 16'd28;
	//Drop the packet and reset
	end else if (state == 3'd3 && udp_checksum_index >= (packet_ceiling-19)) begin
		state = 3'b0;
		ipv4_checksum = 0;
		udp_checksum_index = 0;
		packet_ceiling = 16'b0;
	end else if (state == 3'd4 && udp_checksum_index == 16'd28) begin
		rx_out = input_buffer[udp_checksum_index];
		rx_out_valid = 1'd1;
		rx_out_first = 1'd1;
		rx_out_last = 1'd0;
		udp_checksum_index = udp_checksum_index + 1;
	end else if (state == 3'd4 && udp_checksum_index < packet_ceiling) begin
		rx_out = input_buffer[udp_checksum_index];
		rx_out_valid = 1'd1;
		rx_out_first = 1'd0;
		udp_checksum_index = udp_checksum_index + 1;
	end else if (state == 3'd4 && udp_checksum_index == packet_ceiling) begin
		rx_out = input_buffer[udp_checksum_index];
		rx_out_valid = 1'd1;
		rx_out_last = 1'd1;
		udp_checksum_index = udp_checksum_index + 1;
	end else if (state == 3'd4 && udp_checksum_index == packet_ceiling + 1) begin
		rx_out_valid = 1'd0;
		rx_out_last = 1'd0;
		rx_out_first = 1'd0;
		udp_checksum_index = 0;
		state = 3'd0;
		packet_ceiling = 16'd0;
	end
end 
endmodule












