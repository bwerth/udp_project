`timescale 1 ns / 1 ps

module udpip_transmitter(
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

module udpip_transmitter(
	input clk,
	input [7:0] tx_in,
	input tx_in_valid,
	input tx_in_first,
	input tx_in_last,
	output wr_valid,
	output [7:0] wrdata,
	output wr_first,
	output wr_last
)

reg [2:0] state = 3'b0;
reg [1:0] udp_state = 2'b0;
reg [1:0] ip_state = 2'b0;
reg [2:0] out_state = 2'b0;
reg [7:0] input_buffer [255:0]
reg [15:0] packet_ceiling = 16'b0;
reg [31:0] udp_checksum = 16'b0;
reg [15:0] ip_checksum = 16'b0;
reg [63:0] udp_header;
reg [159:0] ip_header;
reg [15:0] udp_index = 0;
reg [31:0] udp_checksum_carryover;
reg [31:0] ip_checksum = 0;
reg [31:0] ip_checksum_carryover;
reg [


always @ (posedge clk) begin
	if (state == 3'b0 && tx_in_valid == 1'b1) begin
		state == 3'b1;
		input_buffer[0] = tx_in;
		packet_ceiling = packet_ceiling + 1;
	end else if (state == 3'b1 && tx_in_valid == 1'b1 && tx_in_last == 1'b0) begin
		input_buffer[packet_ceiling] = tx_in;
		packet_ceiling = packet_ceiling + 1;
	end else if (state == 3'b1 && tx_in_valid == 1'b1 && tx_in_last == 1'b1) begin
		input_buffer[packet_ceiling] = tx_in;
		state == 3'b2;
		total_length = {input_buffer[2],input_buffer[1]};
		ID = {input_buffer[4],input_buffer[3]};
		flafrag = {input_buffer[6],input_buffer[5]};
		source_ip = {input_buffer[12],input_buffer[11],input_buffer[10],input_buffer[9]};
		dest_ip = {input_buffer[16],input_buffer[15],input_buffer[14],input_buffer[13]};
		source_port = {input_buffer[18],input_buffer[17]};
		dest_port = {input_buffer[20],input_buffer[19]};
		udp_length = {input_buffer[22],input_buffer[21]};
	//begin generating UDP header
	end else if (state == 3'b2 && udp_state == 2'b0) begin
		udp_checksum = {24'b0,input_buffer[8]} + {16'b0,udp_length} + {16'b0,source_ip[31:16]} + {16'b0,source_ip[15:0]} + {16'b0,dest_ip[31:16]} + {16'b0,dest_ip[15:0]} + {16'b0,source_port} + {16'b0,dest_port} + {16'b0,udp_length};
		udp_state == 2'b1;
	end else if (state == 3'b2 && udp_state == 2'b1 && udp_index < packet_ceiling-24) begin
		udp_checksum = udp_checksum + {16'b0,input_buffer[24+udp_index],input_buffer[23+udp_index]};
		udp_index = udp_index + 1;
	end else if (state == 3'b2 && udp_state == 2'b1 && udp_index == packet_ceiling-26 && udp_checksum[31:16]>16'b0) begin
		udp_checksum_carryover = {16'b0,udp_checksum[31:16]};
		udp_checksum[31:16] = 16'b0;
		udp_checksum = udp_checksum_carryover + udp_checksum;
	end else if (state == 3'b2 && udp_state == 2'b1 && udp_index == packet_ceiling-26) begin
		udp_header = {source_port,dest_port,udp_length,udp_checksum[15:0]}
		udp_index = 16'b0;
		udp_state = 2'b0;
		state = 3'b3;
	end else if (state == 3'b3 && ip_state == 2'b0) begin
		ip_checksum = {16'b0,input_buffer[0],8'b0} + {16'b0,total_length} + {16'b0,ID} + {16'b0,flafrag} + {16'b0,input_buffer[8],input_buffer[7]} + {16'b0,source_ip[31:16]} + {16'b0,source_ip[15:0]} + {16'b0,dest_ip[31:16]} + {16'b0,dest_ip[15:0]};
		ip_state == 2'b1;
	end else if (state == 3'b3 && ip_state == 2'b1 && ip_checksum[31:16] > 16'b0) begin
		ip_checksum_carryover = {16'b0,ip_checksum[31:16]};
		ip_checksum[31:16] = 16'b0;
		ip_checksum = ip_checksum_carryover + ip_checksum;
	end else if (state == 3'b3 && ip_state == 2'b1) begin
		ip_header = {input_buffer[0],8'b0,total_length,ID,flafrag,input_buffer[8],input_buffer[7],ip_checksum,source_ip,dest_ip};
		ip_state = 2'b0;
		state = 3'b4;
	end else if (state == 3'b4 && out_state == 3'b0) begin
		out_state = 3'b1;
		wr_data = ip_header[159:152];
		wr_valid = 1'b1;
		wr_first = 1'b1;
		out_index = 16'b1;
	end else if (state == 3'b4 && out_state == 3'b1 && out_index < 19) begin
		ip_header = {ip_header[151:0],8'b0};
		wr_data = ip_header[159:152];
		wr_valid = 1'b1;
		wr_first = 1'b0;
	end else if (state == 3'b4 && out_state == 3'b1 && out_index < 20) begin
		ip_header = {ip_header[151:0],8'b0};
		wr_data = ip_header[159:152];
		wr_valid = 1'b1;
		wr_first = 1'b0;
		out_state = 3'b2;
		out_index = 16'b0;
	end else if (state == 3'b4 && out_state == 3'b2 && out_index < 7) begin
		wr_data = udp_header[63:54];
		udp_header = {udp_header[53:0],8'b0};
		wr_valid = 1'b1;
	end else if (state == 3'b4 && out_state == 3'b2 && out_index < 8) begin
		wr_data = udp_header[63:54];
		wr_valid = 1'b1;
		out_state = 3'b3;
		out_index = 16'b23;
	end else if (state == 3'b4 && out_state == 3'b3 && out_index < packet_ceiling) begin
		wr_data = input_buffer[out_index];
		wr_valid = 1'b1;
		out_index = out_index + 1;
	end else if (state == 3'b4 && out_state == 3'b3 && out_index == packet_ceiling) begin
		wr_data = input_buffer[out_index];
		wr_valid = 1'b1;
		wr_last = 1'b1;
		out_index = out_index + 1;
	end else if (state == 3'b4 && out_state == 3'b3 && out_index == packet_ceiling + 1) begin
		wr_data = 8'b0;
		wr_valid = 1'b0;
		wr_last = 1'b0;
		out_index = 16'b0;
		state = 3'b0;
		out_state = 3'b0;
	end 
end
endmodule



//Things to fix
//order of incoming packet pieces needs to be clarified (how do we want to format output buffer)
//fix crc data streaming





