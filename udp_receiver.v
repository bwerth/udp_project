`timescale 1 ns / 1 ps

module udpip_receiver(
	input [7:0] rddata,
	input rd_first,
	input rd_last,
	input rx_empty,
	input clk,
	output rd_en,
	output [7:0] rx_out,
	output rx_out_valid,
	output rx_out_first,
	output rx_out_last
)

reg [15:0] calculated_ipv4_checksum;
reg [2:0] state;
reg [1:0] ip_state;
reg [15:0] ipv4_checksum_index = 0;
reg [15:0] udp_checksum_index = 0;
reg [15:0] packet_ceiling = 0;
reg [7:0] input_buffer [255:0];
reg [31:0] ipv4_checksum = 0;
reg [31:0] ipv4_checksum_carryover = 0;
reg [15:0] ipv4_received_checksum;
reg [3:0] ip_version;
reg [31:0] source_ip, destination_ip;
reg [7:0] udp_protocol = 8'b17;
reg [15:0] udp_packet_length;

always @ (posedge clk) begin
	if(rx_empty == 1'b0 && state == 2'b0) begin
		rd_en = 1'b1;
		state = 2'b1;
	end else if (rx_empty == 1'b1 && state == 2'b1) begin
		rd_en = 1'b1;
end

always @ (posedge clk) begin
	if (state == 3'b0 && rx_empty == 1'b0) begin
		state = 3'b1;
	end else if (state == 3'b1 && rx_out_last == 1'b1) begin
		input_buffer[packet_ceiling] = rddata;
		state = 3'b2;
	end else if (state == 3'b1 && rx_out_first != 1'b1 && rx_out_last != 1'b1) begin
		input_buffer[packet_ceiling] = rddata;
		packet_ceiling = packet_ceiling + 1;
	//Begin ipv4 checksum calculation
	end else if (state == 3'b2 && ip_state == 2'b0 && ipv4_checksum_index == 16'b20 && ipv4_checksum[31:16] > 16'b0) begin
		ipv4_checksum_carryover = {16'b0,ipv4_checksum[31:16]};
		ipv4_checksum = {16'b0,ipv4_checksum[15:0]};
		ipv4_checksum = ipv4_checksum + ipv4_checksum_carryover;
	end else if (state == 3'b2 && ip_state == 2'b0 && ipv4_checksum_index == 16'b20) begin
		ipv4_checksum_index = 16'b0;
		ip_state == 2'b1;
		ipv4_received_checksum = {input_buffer[11],input_buffer[10]};
		ip_version = input_buffer[0][3:0];
	end else if (state == 3'b2 && ip_state == 2'b0) begin
		ipv4_checksum = {16'b0,input_buffer[ipv4_checksum_index+1],input_buffer[ipv4_checksum_index]} + ipv4_checksum;
		ipv4_checksum_index = ipv4_checksum_index + 2;
	end else if (state == 3'b2 && ip_state == 2'b1 && ipv4_received_checksum == ipv4_checksum && packet_ceiling > 16'b20 && ip_version == 4'b4) begin
		state = 3'b3;
		ip_state = 2'b0;
		ipv4_checksum = 16'b0;
		source_ip = {input_address[15],input_address[14],input_address[13],input_address[12]};
		destination_ip = {input_address[19],input_address[18],input_address[17],input_address[16]};
		udp_packet_length = packet_ceiling-19;
	end else if (state == 3'b2 && ip_state == 2'b1) begin
		state = 3'b0;
		ip_state = 2'b0;
		ipv4_checksum = 16'b0;
		packet_ceiling = 16'b0;
	end else if (state == 3'b3 && udp_checksum_index == 0) begin
		ipv4_checksum = {16'b0,source_ip[31:16]} + {16'b0,source_ip[15:0]} + {16'b0,destination_ip[31:16]} + {16'b0,destination_ip[15:0]} + {24'b0,udp_protocol} + {16'b0,udp_packet_length};
		udp_checksum_index = udp_checksum_index + 1;
	end else if (state == 3'b3 && udp_checksum_index < (packet_ceiling-20)) begin
		ipv4_checksum = ipv4_checksum + {16'b0,input_buffer[20+udp_checksum_index],input_buffer[19+udp_checksum_index]};
		udp_checksum_index = udp_checksum_index + 1;
	end else if (state == 3'b3 && udp_checksum_index == (packet_ceiling-20) && ipv4_checksum[31:16] > 16'b0) begin
		ipv4_checksum_carryover = {16'b0,ipv4_checksum[31:16]};
		ipv4_checksum = {16'b0,ipv4_checksum[15:0]};
		ipv4_checksum = ipv4_checksum + ipv4_checksum_carryover;
	end else if (state == 3'b3 && udp_checksum_index == (packet_ceiling-20) && ipv4_checksum == {input_buffer[27],input_buffer[26]}) begin
		state = 3'b4;
		ipv4_checksum = 0;
		udp_checksum_index = 16'b28;
	//Drop the packet and reset
	end else if (state == 3'b3 && udp_checksum_index == (packet_ceiling-20)) begin
		state = 3'b0;
		ipv4_checksum = 0;
		udp_checksum_index = 0;
		packet_ceiling = 16'b0;
	end else if (state == 3'b4 && udp_checksum_index == 16'b28) begin
		rx_out = input_buffer[udp_checksum_index];
		rx_out_valid = 1'b1;
		rx_out_first = 1'b1;
		udp_checksum_index + 1;
	end else if (state == 3'b4 && udp_checksum_index < packet_ceiling - 1) begin
		rx_out = input_buffer[udp_checksum_index];
		rx_out_valid = 1'b1;
		rx_out_first = 1'b0;
		udp_checksum_index = udp_checksum_index + 1;
	end else if (state == 3'b4 && udp_checksum_index == packet_ceiling - 1) begin
		rx_out = input_buffer[udp_checksum_index];
		rx_out_valid = 1'b1;
		rx_out_last = 1'b1;
		udp_checksum_index = udp_checksum_index + 1;
	end else if (state == 3'b4 && udp_checksum_index == packet_ceiling) begin
		rx_out_valid = 1'b0;
		rx_out_last = 1'b0;
		rx_out_first = 1'b0;
		udp_checksum_index = 0;
		state = 3'b0;
		packet_ceiling = 16'b0;
	end
end 
endmodule










