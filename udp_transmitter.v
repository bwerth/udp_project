`timescale 1 ns / 1 ps

module udpip_transmitter(
	input clk,
	input [7:0] tx_in,
	input tx_in_valid,
	input tx_in_first,
	input tx_in_last,
	output wr_valid,
	output [7:0] wrdata,
	output wr_first,
	output wr_last,
	output [2:0] state,
	output [31:0] source_ip,
	output [31:0] udp_checksum,
	output [1:0] udp_state,
	output [15:0] udp_index,
	output [31:0] ip_checksum,
	output [1:0] ip_state,
	output [159:0] ip_header,
	output [7:0] input_test,
	output [2:0] out_state,
	output [15:0] out_index,
	output [63:0] udp_header
);

reg [2:0] state = 3'b0;
reg [1:0] udp_state = 2'b0;
reg [1:0] ip_state = 2'b0;
reg [2:0] out_state = 2'b0;
reg [7:0] input_buffer [255:0];
reg [15:0] packet_ceiling = 16'b0;
reg [31:0] udp_checksum = 32'b0;
reg [31:0] ip_checksum = 32'b0;
reg [63:0] udp_header;
reg [159:0] ip_header;
reg [15:0] udp_index = 0;
reg [31:0] udp_checksum_carryover;
reg [31:0] ip_checksum_carryover;
reg [15:0] total_length, ID, flafrag, source_port, dest_port, udp_length, out_index;
reg [31:0] source_ip, dest_ip;
reg [7:0] wrdata;
reg wr_first, wr_valid;
reg wr_last = 1'b0;
wire [7:0] input_test;

assign input_test = input_buffer[0];


always @ (posedge clk) begin
	if (state == 3'b0 && tx_in_valid == 1'b1) begin
		state = 3'b1;
		input_buffer[0] = tx_in;
		packet_ceiling = packet_ceiling + 1;
	end else if (state == 3'b1 && tx_in_valid == 1'b1 && tx_in_last == 1'b0) begin
		input_buffer[packet_ceiling] = tx_in;
		packet_ceiling = packet_ceiling + 1;
	end else if (state == 3'b1 && tx_in_valid == 1'b1 && tx_in_last == 1'b1) begin
		input_buffer[packet_ceiling] = tx_in;
		state = 3'd2;
		total_length = {input_buffer[1],input_buffer[2]};
		ID = {input_buffer[3],input_buffer[4]};
		flafrag = {input_buffer[5],input_buffer[6]};
		source_ip = {input_buffer[9],input_buffer[10],input_buffer[11],input_buffer[12]};
		dest_ip = {input_buffer[13],input_buffer[14],input_buffer[15],input_buffer[16]};
		source_port = {input_buffer[17],input_buffer[18]};
		dest_port = {input_buffer[19],input_buffer[20]};
		udp_length = {input_buffer[21],input_buffer[22]};
	//begin generating UDP header
	end else if (state == 3'd2 && udp_state == 2'b0) begin
		udp_checksum = {24'b0,8'd17} + {16'b0,udp_length} + {16'b0,source_ip[31:16]} + {16'b0,source_ip[15:0]} + {16'b0,dest_ip[31:16]} + {16'b0,dest_ip[15:0]} + {16'b0,source_port} + {16'b0,dest_port} + {16'b0,udp_length};
		$display("UDP CHECKSUM GENERATION: %b",udp_checksum);
		udp_state = 2'b1;
	end else if (state == 3'd2 && udp_state == 2'd1 && udp_index < packet_ceiling-23) begin
		udp_checksum = udp_checksum + {16'b0,input_buffer[23+udp_index],input_buffer[24+udp_index]};
		udp_index = udp_index + 2;
	end else if (state == 3'd2 && udp_state == 2'b1 && udp_index >= packet_ceiling-23 && udp_checksum[31:16]>16'b0) begin
		udp_checksum_carryover = {16'b0,udp_checksum[31:16]};
		udp_checksum[31:16] = 16'b0;
		udp_checksum = udp_checksum_carryover + udp_checksum;
	end else if (state == 3'd2 && udp_state == 2'b1 && udp_index >= packet_ceiling-23) begin
		udp_header = {source_port,dest_port,udp_length,udp_checksum[15:0]};
		udp_index = 16'b0;
		udp_state = 2'b0;
		state = 3'd3;
	end else if (state == 3'd3 && ip_state == 2'b0) begin
		ip_checksum = {16'b0,input_buffer[0],8'b0} + {16'b0,total_length} + {16'b0,ID} + {16'b0,flafrag} + {16'b0,input_buffer[7],input_buffer[8]} + {16'b0,source_ip[31:16]} + {16'b0,source_ip[15:0]} + {16'b0,dest_ip[31:16]} + {16'b0,dest_ip[15:0]};
		ip_state = 2'b1;
	end else if (state == 3'd3 && ip_state == 2'b1 && ip_checksum[31:16] > 16'b0) begin
		ip_checksum_carryover = {16'b0,ip_checksum[31:16]};
		ip_checksum[31:16] = 16'b0;
		ip_checksum = ip_checksum_carryover + ip_checksum;
	end else if (state == 3'd3 && ip_state == 2'b1) begin
		ip_header = {input_buffer[0],8'b0,total_length,ID,flafrag,input_buffer[7],input_buffer[8],ip_checksum[15:0],source_ip,dest_ip};
		ip_state = 2'b0;
		state = 3'd4;
	end else if (state == 3'd4 && out_state == 3'b0) begin
		out_state = 3'b1;
		wrdata = ip_header[159:152];
		wr_valid = 1'b1;
		wr_first = 1'b1;
		out_index = 16'b1;
	end else if (state == 3'd4 && out_state == 3'b1 && out_index < 16'd19) begin
		ip_header = {ip_header[151:0],8'b0};
		wrdata = ip_header[159:152];
		wr_valid = 1'b1;
		wr_first = 1'b0;
		out_index = out_index + 1;
	end else if (state == 3'd4 && out_state == 3'b1 && out_index == 16'd19) begin
		ip_header = {ip_header[151:0],8'b0};
		wrdata = ip_header[159:152];
		wr_valid = 1'b1;
		wr_first = 1'b0;
		out_state = 3'd2;
		out_index = 16'b0;
	end else if (state == 3'd4 && out_state == 3'd2 && out_index < 7) begin
		wrdata = udp_header[63:56]; //63:56 55:48 47:40 39:32 31:24 23:16 15:8
		udp_header = {udp_header[55:0],8'b0};
		wr_valid = 1'b1;
		out_index = out_index + 1;
	end else if (state == 3'd4 && out_state == 3'd2 && out_index < 8) begin
		wrdata = udp_header[63:56];
		wr_valid = 1'b1;
		out_state = 3'd3;
		out_index = 16'd23;
	end else if (state == 3'd4 && out_state == 3'd3 && out_index < packet_ceiling) begin
		wrdata = input_buffer[out_index];
		wr_valid = 1'b1;
		out_index = out_index + 1;
	end else if (state == 3'd4 && out_state == 3'd3 && out_index == packet_ceiling) begin
		wrdata = input_buffer[out_index];
		wr_valid = 1'b1;
		wr_last = 1'b1;
		out_index = out_index + 1;
	end else if (state == 3'd4 && out_state == 3'd3 && out_index == packet_ceiling + 1) begin
		wrdata = 8'b0;
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

