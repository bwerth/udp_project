`timescale 1ns / 1ps

module ring_buffer_64(
	input rd_clk,
	input wr_clk,
	input rd_en,
	input wr_en,
	input wr_first,
	input wr_last,
	input [7:0] wrdata,
	output [7:0] rddata,
	output rd_first,
	output rd_last,
	output empty
)

reg [7:0] input_buffer [127:0];
reg [1:0] control_buffer [127:0];
reg [5:0] rd_pointer = 0;
reg [5:0] wr_pointer = 0;
reg empty;

always @ (*) begin
	if(rd_pointer == wr_pointer) begin
		empty = 1'b1;
	else begin
		empty = 1'b0;
end

always @ (posedge rd_clk) begin
	if(rd_en && control_buffer[rd_pointer] == 2'b1) begin
		rddata = input_buffer[rd_pointer];
		rd_first = 1'b1;
		rd_last = 1'b0;
		rd_pointer = rd_pointer + 1;
	end else if (rd_en && control_buffer[rd_pointer] == 2'b2) begin
		rddata = input_buffer[rd_pointer];
		rd_first = 1'b0;
		rd_last = 1'b1;
		rd_pointer = rd_pointer + 1;
	end else if (rd_en) begin
		rddata = input_buffer[rd_pointer];
		rd_first = 1'b0;
		rd_last = 1'b0;
		rd_pointer = rd_pointer + 1;
end

always @ (posedge wr_clk) begin
	if(wr_en && wr_first) begin
		input_buffer[wr_pointer] = wrdata;
		control_buffer[wr_pointer] = 2'b1;
		wr_pointer = wr_pointer + 1;
	end else if (wr_en && wr_last) begin
		input_buffer[wr_pointer] = wrdata;
		control_buffer[wr_pointer] = 2'b2;
		wr_pointer = wr_pointer + 1;
	end else if (wr_en) begin
		input_buffer[wr_pointer] = wr_data;
		control_buffer[wr_pointer] = 2'b0;
		wr_pointer = wr_pointer + 1;
	end
end
endmodule