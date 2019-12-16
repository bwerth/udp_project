`timescale 1ns / 1ps

module crc_validate(
	input [479:0] udp_rx,
	input [31:0] sending_crc,
	input [15:0] crc_ceiling,
	input udp_rx_start,
	input clk,
	output check_valid,
	output check_passed,
	output [31:0] checkCRC,
	output [15:0] index,
	output [1:0] state
);

//construct pseudo header, calculate checksum, and add to one's complement of header and data. If the result is zero, pass the check
	reg [15:0] index;
	reg [1:0] state;
	reg [31:0] checkCRC;
	reg [479:0] crc_to_check;
	reg check_valid, check_passed;
	reg [31:0] crc_polynomial = 32'h973afb51;
	wire [15:0] crc_ceiling;

	always @ (posedge clk) begin
		if(udp_rx_start) begin
			check_valid = 1'b0;
			index = crc_ceiling-32;
			state = 2'b1;
			crc_to_check = udp_rx;
		end else if (state == 2'd2) begin
			checkCRC = ~(sending_crc + crc_to_check[31:0]);
			check_passed = !checkCRC ? 1'b1 : 1'b0;
			check_valid = 1'b1;
			index = 8'b0;
			state = 2'b0;
		end else if (state == 2'b1 && index == 16'd31) begin
			state = 2'd2;
		end else if (crc_to_check[index] == 1'd0 && state == 2'b1) begin
			index = index - 1;
		end else if (state == 2'b1) begin
			crc_to_check[index-:32] = crc_to_check[index-:32] ^ crc_polynomial;
		end
	end
endmodule

//CRC Receives the entire received packet at once, instead of streaming. CRC_Ceiling indicates the size of the received packet for indexing the udp_tx input
module crc_calculate(
	input [479:0] udp_tx,
	input [15:0] crc_ceiling,
	input udp_tx_start,
	input clk,
	output [31:0] calculated_crc,
	output check_valid,
	output [15:0] index,
	output [1:0] state,
	output [479:0] crc_to_check
);

//construct pseudo header, calculate checksum, and add to one's complement of header and data. If the result is zero, pass the check
	reg [15:0] index;
	reg [1:0] state = 2'b0;
	reg [479:0] crc_to_check;
	wire udp_tx_start;
	reg check_valid;
	reg [31:0] calculated_crc;
	reg [31:0] crc_polynomial = 32'h973afb51;
	wire [15:0] crc_ceiling;

	always @ (posedge clk) begin
		if(udp_tx_start) begin
			check_valid = 1'b0;
			index = crc_ceiling;
			state = 2'b1;
			crc_to_check = udp_tx;
		end else if (state == 2'd2) begin
			calculated_crc = ~crc_to_check[31:0];
			check_valid = 1'b1;
			index = 8'b0;
			state = 2'b0;
		end else if (state == 2'b1 && index == 16'd31) begin
			state = 2'd2;
		end else if (crc_to_check[index] == 1'd0 && state == 2'b1) begin
			index = index - 1;
		end else if (state == 2'b1) begin
			crc_to_check[index-:32] = crc_to_check[index-:32] ^ crc_polynomial;
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
	input clk,
	output [479:0] crc_in,
	output [31:0] received_crc,
	output crc_start,
	output [15:0] crc_ceiling,
	output [7:0] to_udp,
	output to_udp_valid,
	output to_udp_first,
	output to_udp_last,
	output [15:0] packet_ceiling,
	output [2:0] state
);

	//reg [207:0] input_buffer;
	reg [511:0] input_buffer;
	reg [15:0] packet_ceiling;
	reg [15:0] crc_ceiling;
	reg [2:0] state = 3'b0;
	reg [6:0] index = 0;
	reg [7:0] wait_counter = 0;
	reg [7:0] output_counter = 0;
	reg crc_start;
	reg [479:0] crc_in;
	reg [31:0] received_crc;
	reg [7:0] to_udp;
	reg to_udp_valid, to_udp_first, to_udp_last = 0;

always @ (posedge clk) begin
	if(state == 3'b0 && udp_rx_first) begin
		state = 3'b1;
		//input_buffer = {input_buffer[199:0],udp_rx};
		input_buffer = {input_buffer[503:0],udp_rx};
		packet_ceiling = 16'd7;
		$display("HIT_START");
	end else if (state == 3'b1 && udp_rx_valid && udp_rx_last) begin
		//input_buffer = {input_buffer[199:0],udp_rx};
		input_buffer = {input_buffer[503:0],udp_rx};
		packet_ceiling = packet_ceiling + 8;
		state = 3'd2;
		crc_start = 1'b1;
		crc_in = input_buffer[511:32];
		received_crc = input_buffer[31:0];
		crc_ceiling = packet_ceiling;
	end else if (state == 3'b1 && udp_rx_valid) begin
		input_buffer = {input_buffer[503:0],udp_rx};
		packet_ceiling = packet_ceiling + 8;
	end else if (state == 3'd2 && wait_counter == 4) begin
		wait_counter = wait_counter + 1;
		crc_start = 1'b0;
	end else if (state == 3'd2 && wait_counter<5) begin
		wait_counter = wait_counter + 1;
	end else if (state == 3'd2 && wait_counter == 5 && crc_valid) begin
		state = crc_check ? 3'd3 : 3'b0;
	end else if (state == 3'd3 && wait_counter == 5) begin
		to_udp = input_buffer[packet_ceiling-:8];
		wait_counter = 0;
		to_udp_valid = 1'b1;
		to_udp_first = 1'b1;
		packet_ceiling = packet_ceiling-8;
	end else if (state == 3'd3 && packet_ceiling>16'd39) begin
		to_udp = input_buffer[packet_ceiling-:8];
		packet_ceiling = packet_ceiling-8;
		to_udp_valid = 1'b1;
		to_udp_first = 1'b0;
	end else if (state == 3'd3 && packet_ceiling==16'd39) begin
		to_udp_last = 1'b1;
		to_udp_valid = 1'b1;
		to_udp = input_buffer[39:32];
		packet_ceiling = 16'b0;
	end else if (state == 3'd3 && packet_ceiling == 16'b0) begin
		state = 3'b0;
		to_udp_last = 1'b0;
		to_udp_valid = 1'b0;
	end
end
endmodule

//Check CRC and destination MAC-address, discarding if things don't match

module udpip_tx(
	input [7:0] from_udp,
	input from_udp_valid,
	input from_udp_first,
	input from_udp_last,
	input crc_valid,
	input [31:0] calculated_crc,
	input clk,
	output [479:0] crc_input,
	output [15:0] crc_ceiling,
	output crc_start,
	output [7:0] udp_tx,
	output udp_tx_valid,
	output udp_tx_first,
	output udp_tx_last,
	output [2:0] state,
	output [543:0] output_buffer,
	output [31:0] crc_calculated,
	output [7:0] wait_counter
);

	reg [511:0] input_buffer = 512'b0;
	reg [543:0] output_buffer = 544'b0;
	reg [15:0] packet_ceiling;
	reg [15:0] crc_ceiling;
	reg [2:0] state = 3'b0;
	reg [6:0] index = 0;
	reg [7:0] wait_counter = 0;
	reg crc_start;
	reg [479:0] crc_input;
	reg [7:0] udp_tx;
	reg udp_tx_valid = 0, udp_tx_first = 0, udp_tx_last = 0;
	wire [31:0] crc_calculated;

always @ (negedge clk) begin
	if(state == 3'b0 && from_udp_first) begin
		state = 3'b1;
		input_buffer = {input_buffer[471:0],from_udp};
		packet_ceiling = 16'd7;
		//$display("BEGINNING");
	end else if (state == 3'b1 && from_udp_valid && from_udp_last) begin
		input_buffer = {input_buffer[503:0],from_udp};
		packet_ceiling = packet_ceiling + 8;
		crc_input = input_buffer;
		crc_ceiling = packet_ceiling;
		state = 3'd2;
		crc_start = 1'b1;
		//$display("ENDING");
	end else if (state == 3'b1 && from_udp_valid) begin
		input_buffer = {input_buffer[503:0],from_udp};
		packet_ceiling = packet_ceiling + 8;
		//$display("CONTINUING");
	end else if (state == 3'd2 && wait_counter<5) begin
		wait_counter = wait_counter + 1;
		crc_start = 1'b0;
	end else if (state == 3'd2 && wait_counter == 8'd5 && crc_valid) begin
		state = 3'd3;
		output_buffer = {input_buffer, calculated_crc};
		packet_ceiling = packet_ceiling + 32;
	end else if (state == 3'd3 && wait_counter > 0) begin
		udp_tx = output_buffer[packet_ceiling-:8];
		packet_ceiling = packet_ceiling - 8;
		udp_tx_valid = 1'b1;
		udp_tx_first = 1'b1;
		wait_counter = 0;
	end else if (state == 3'd3 && packet_ceiling > 7) begin
		udp_tx = output_buffer[packet_ceiling-:8];
		packet_ceiling = packet_ceiling - 8;
		udp_tx_valid = 1'b1;
		udp_tx_first = 1'b0;
	end else if (state == 3'd3 && packet_ceiling == 7) begin
		udp_tx = output_buffer[7:0];
		udp_tx_valid = 1'b1;
		udp_tx_last = 1'b1;
		packet_ceiling = 0;
	end else if (state == 3'd3 && packet_ceiling == 0) begin
		udp_tx_valid = 1'b0;
		udp_tx_last = 1'b0;
		state = 3'b0;
	end
end
endmodule

//Assemble the full CRC oriented transmitter
module crc_tx(
	input [7:0] from_udp,
	input from_udp_valid,
	input from_udp_first,
	input from_udp_last,
	input clk,
	output [7:0] udp_tx,
	output udp_tx_valid,
	output udp_tx_first,
	output udp_tx_last
);

    // Inter-module connection wires
	wire crc_valid;
	wire [31:0] calculated_crc;
	wire [479:0] crc_input;
	wire [15:0] crc_ceiling;
	wire crc_start;

	// Null wires for test bench control signals
	wire [2:0] null_state;
	wire [543:0] buffer_null;
	wire [31:0] calculated_null;
	wire [7:0] wait_null;
	wire [15:0] index_null;
	wire [1:0] state_null;
	wire [479:0] check_null;

	udpip_tx crc_prep(.from_udp(from_udp),.from_udp_valid(from_udp_valid),.from_udp_first(from_udp_first),.from_udp_last(from_udp_last),.crc_valid(crc_valid),.calculated_crc(calculated_crc),.clk(clk),.crc_input(crc_input),.crc_ceiling(crc_ceiling),.crc_start(crc_start),.udp_tx(udp_tx),.udp_tx_valid(udp_tx_valid),.udp_tx_first(udp_tx_first),.udp_tx_last(udp_tx_last),.state(null_state),.output_buffer(buffer_null),.crc_calculated(calculated_null),.wait_counter(wait_null));

	crc_calculate crc_calc(.udp_tx(crc_input),.crc_ceiling(crc_ceiling),.udp_tx_start(crc_start),.clk(clk),.calculated_crc(calculated_crc),.check_valid(crc_valid),.index(index_null),.state(state_null),.crc_to_check(check_null));

endmodule

//Assemble the full CRC oriented receiver
module crc_rx(
	input [7:0] udp_rx,
	input udp_rx_valid,
	input udp_rx_first,
	input udp_rx_last,
	input clk,
	output [7:0] to_udp,
	output to_udp_valid,
	output to_udp_first,
	output to_udp_last,
	output [2:0] state_null,
	output crc_valid_rx,
	output crc_check_rx
);

	wire crc_check_rx, crc_valid_rx, crc_start_rx;
	wire [479:0] crc_in;
	wire [31:0] received_crc_rx, crc_null;
	wire [15:0] crc_ceiling_rx, ceiling_null, index_null;
	wire [2:0] state_null;
	wire [1:0] null_state;

	udpip_rx crc_prep(.udp_rx(udp_rx),.udp_rx_valid(udp_rx_valid),.udp_rx_first(udp_rx_first),.udp_rx_last(udp_rx_last),.crc_check(crc_check_rx),.crc_valid(crc_valid_rx),.clk(clk),.crc_in(crc_in),.received_crc(received_crc_rx),.crc_start(crc_start_rx),.crc_ceiling(crc_ceiling_rx),.to_udp(to_udp),.to_udp_valid(to_udp_valid),.to_udp_first(to_udp_first),.to_udp_last(to_udp_last),.packet_ceiling(ceiling_null),.state(state_null));

	crc_validate crc_vald(.sending_crc(received_crc_rx),.crc_ceiling(crc_ceiling_rx),.udp_rx_start(crc_start_rx),.udp_rx(crc_in),.clk(clk),.check_valid(crc_valid_rx),.check_passed(crc_check_rx),.checkCRC(crc_null),.index(index_null),.state(null_state));

	always @ (posedge clk) begin
		//$display("CRC SENDING: %b %b %b",to_udp,to_udp_first,to_udp_last);
	end


endmodule