`timescale 1ns / 1ps

	input [79:0] udp_rx,
	input [175:0] ip_rx,
	input udp_rx_is_valid,
	input udp_rx_start,
	input ip_rx_is_valid,
	input ip_rx_start,
	input clk

module crc_validate(
	input [175:0] udp_rx,
	input [31:0] sending_crc,
	input udp_rx_start,
	input clk,
	output check_valid,
	output check_passed
);

//construct pseudo header, calculate checksum, and add to one's complement of header and data. If the result is zero, pass the check
	reg [7:0] index;
	reg [1:0] state;
	reg [31:0] checkCRC;
	reg [175:0] crc_to_check;

	always @ (posedge clk) begin
		if(udp_rx_start) begin
			check_valid = 1'b0;
			index = 8'b0;
			crc_to_check = udp_rx;
		end else if (state == 2'b2) begin
			checkCRC = sending_crc + crc_to_check[144:175];
			check_passed = !checkCRC ? 1'b1 : 1'b0;
			check_valid = 1'b1;
			index = 8'b0;
			state = 2'b0;
		end else if (state == 2'b1 && index == 8'b144) begin
			state = 2'b2;
		end else if (udp_rx[index] != 1'b1 && state == 1'b1) begin
			index = index + 1;
		end else if (state == 1'b1) begin
			crc_to_check[index:index+15] = crc_to_check[index:index+31] ^ checkCRC;
		end
	end
endmodule

module crc_calculate(
	input [175:0] udp_tx,
	input udp_tx_start,
	input clk,
	output [32:0] calculated_crc,
	output check_valid
);

//construct pseudo header, calculate checksum, and add to one's complement of header and data. If the result is zero, pass the check
	reg [7:0] index;
	reg [1:0] state;
	reg [175:0] crc_to_check;

	always @ (posedge clk) begin
		if(udp_rx_start) begin
			check_valid = 1'b0;
			index = 8'b0;
			crc_to_check = udp_rx;
		end else if (state == 2'b2) begin
			calculated_crc = ~crc_to_check[144:175];
			check_valid = 1'b1;
			index = 8'b0;
			state = 2'b0;
		end else if (state == 2'b1 && index == 8'b144) begin
			state = 2'b2;
		end else if (udp_rx[index] != 1'b1 && state == 1'b1) begin
			index = index + 1;
		end else if (state == 2'b1) begin
			crc_to_check[index:index+15] = crc_to_check[index:index+31] ^ checkCRC;
		end
	end
endmodule

//construct pseudo header, calculate checksum, and perform one's complement. Append to header

module udpip_rx(
	input [7:0] udp_rx,
	input udp_rx_valid,
	input udp_rx_first,
	input udp_rx_last,
	input crc_check,
	input crc_valid,
	output [175:0] crc_in,
	output [31:0] received_crc,
	output crc_start,
	output [7:0] to_udp
);

	reg [207:0] input buffer;
	reg [2:0] state;
	reg [6:0] index = 0;
	reg [7:0] wait_counter = 0;
	reg [7:0] output_counter = 0;

always @ (posedge clk) begin
	if(state == 3'b0 && udp_rx_first) begin
		state = 3'b1;
		input_buffer = {input_buffer[199:0],udp_rx};
		index = index + 1;
	end else if (state == 3'b1 && index<26 && udp_rx_valid) begin
		input_buffer = {input_buffer[199:0],udp_rx};
		index = index + 1;
	end else if (state == 3'b1 && index == 26) begin
		crc_start = 1'b1;
		crc_in = input_buffer[207:32];
		received_crc = input_buffer[31:0];
		state = 3'b2;
	end else if (state == 3'b2 && wait_counter<2) begin
		wait_counter = wait_counter + 1;
	end else if (state == 3'b2 && wait_counter == 5 && crc_valid) begin
		wait_counter = 0;
		state = crc_check ? 3'b3 : 3'b0;
	end else if (state == 3'b3 && output_counter == 8'b0) begin
		input_buffer = {input_buffer[207:32],32'b0};
		to_udp = input_buffer[207:199];
		output_counter = output_counter + 1;
	end else if (state == 3'b3 && output_counter < 22) begin
		input_buffer = {input_buffer[199:0],8'b0};
		to_udp = input_buffer[207:199];
		output_counter = output_counter + 1;
	end else if (state == 3'b3 && output_counter == 8''b22) begin
		state = 3'b0;
		output_counter = 0;
	end
end
endmodule




//Check CRC and destination MAC-address, discarding if things don't match

module udpip_tx(
	input [7:0] from_udp,
	input udp_tx_valid,
	input udp_tx_first,
	input udp_tx_last,
	input [31:0] calculated_crc,
	output [175:0] crc_input,
	output crc_start,
	output [7:0] udp_tx
);

	reg [175:0] input_buffer;
	reg [207:0] output_buffer
	reg [2:0] state;
	reg [6:0] index = 0;
	reg [7:0] wait_counter = 0;
	reg [7:0] output_counter = 0;

always @ (posedge clk) begin
	if(state == 3'b0 && udp_tx_first) begin
		state = 3'b1;
		input_buffer = {input_buffer[167:0],from_udp};
		index = index + 1;
	end else if (state == 3'b1 && index<22 && udp_tx_valid) begin
		input_buffer = {input_buffer[199:0],udp_rx};
		index = index + 1;
	end else if (state == 3'b1 && index == 22) begin
		crc_start = 1'b1;
		crc_input = input_buffer; 
		state = 3'b2;
	end else if (state == 3'b2 && wait_counter<2) begin
		wait_counter = wait_counter + 1;
	end else if (state == 3'b2 && wait_counter == 5 && crc_valid) begin
		wait_counter = 0;
		state = 3'b3;
		output_buffer = {input_buffer, calculated_crc};
	end else if (state == 3'b3 && output_counter == 8'b0) begin
		input_buffer = {input_buffer[207:32],32'b0};
		to_udp = input_buffer[207:199];
		output_counter = output_counter + 1;
	end else if (state == 3'b3 && output_counter < 26) begin
		input_buffer = {input_buffer[199:0],8'b0};
		to_udp = input_buffer[207:199];
		output_counter = output_counter + 1;
	end else if (state == 3'b3 && output_counter == 8'b26) begin
		state = 3'b0;
		output_counter = 0;
	end
end
endmodule


