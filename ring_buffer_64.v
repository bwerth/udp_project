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
	output empty,
	output [6:0] rd_pointer,
	output [6:0] wr_pointer
);

reg [7:0] input_buffer [127:0];
reg [1:0] control_buffer [127:0];
reg [6:0] rd_pointer = 7'd126;
reg [6:0] wr_pointer = 7'd126;
wire [7:0] wrdata;
reg [7:0] rddata = 8'b0;
reg rd_first = 0, rd_last = 0;
reg empty = 0;

always @ (*) begin
	if(rd_pointer == wr_pointer) begin
		empty = 1'b1;
	end else begin
		empty = 1'b0;
	end
end

always @ (posedge rd_clk) begin
	if(rd_en && empty == 1'b0 && control_buffer[rd_pointer] == 2'b1) begin
		rddata = input_buffer[rd_pointer];
		rd_first = 1'b1;
		rd_last = 1'b0;
		rd_pointer = rd_pointer + 1;
	end else if (rd_en && empty == 1'b0 && control_buffer[rd_pointer] == 2'd2) begin
		rddata = input_buffer[rd_pointer];
		rd_first = 1'b0;
		rd_last = 1'b1;
		rd_pointer = rd_pointer + 1;
	end else if (rd_en && empty == 1'b0) begin
		rddata = input_buffer[rd_pointer];
		rd_first = 1'b0;
		rd_last = 1'b0;
		rd_pointer = rd_pointer + 1;
	end else begin
		rd_last = 1'b0;
		rd_first = 1'b0;
	end
end
//verilator
always @ (negedge wr_clk) begin
	if(wr_en && wr_first) begin
		input_buffer[wr_pointer] = wrdata;
		control_buffer[wr_pointer] = 2'b1;
		wr_pointer = wr_pointer + 1;
		$display("WRITING FIRST: %d %b %b %b",wrdata,wr_en,wr_first,wr_last);
	end else if (wr_en && wr_last) begin
		input_buffer[wr_pointer] = wrdata;
		control_buffer[wr_pointer] = 2'd2;
		wr_pointer = wr_pointer + 1;
		$display("WRITING LAST: %d %b %b %b %b %b",wrdata,wr_en,wr_first,wr_last,empty,rd_en);
	end else if (wr_en) begin
		input_buffer[wr_pointer] = wrdata;
		control_buffer[wr_pointer] = 2'b0;
		wr_pointer = wr_pointer + 1;
		$display("WRITING: %d %b %b %b",wrdata,wr_en,wr_first,wr_last);
	end
end
endmodule

module ring_buffer_64_tx(
	input rd_clk,
	input wr_clk,
	input wr_en,
	input wr_first,
	input wr_last,
	input [7:0] wrdata,
	output [7:0] rddata,
	output rd_first,
	output rd_last,
	output rd_valid,
	output [6:0] rd_pointer,
	output [6:0] wr_pointer
);

reg [7:0] input_buffer [127:0];
reg [1:0] control_buffer [127:0];
reg [6:0] rd_pointer = 7'd126;
reg [6:0] wr_pointer = 7'd126;
wire [7:0] wrdata;
reg [7:0] rddata = 8'b0;
reg rd_first = 0, rd_last = 0, rd_valid = 0;
reg empty = 0;

always @ (*) begin
	if(rd_pointer == wr_pointer) begin
		empty = 1'b1;
	end else begin
		empty = 1'b0;
	end
end

always @ (posedge rd_clk) begin
	if(empty == 1'b0 && control_buffer[rd_pointer] == 2'b1) begin
		rddata = input_buffer[rd_pointer];
		rd_first = 1'b1;
		rd_last = 1'b0;
		rd_valid = 1'b1;
		rd_pointer = rd_pointer + 1;
	end else if (empty == 1'b0 && control_buffer[rd_pointer] == 2'd2) begin
		rddata = input_buffer[rd_pointer];
		rd_first = 1'b0;
		rd_last = 1'b1;
		rd_valid = 1'b1;
		rd_pointer = rd_pointer + 1;
	end else if (empty == 1'b0) begin
		rddata = input_buffer[rd_pointer];
		rd_first = 1'b0;
		rd_last = 1'b0;
		rd_valid = 1'b1;
		rd_pointer = rd_pointer + 1;
	end else begin
		rd_last = 1'b0;
		rd_first = 1'b0;
		rd_valid = 1'b0;
	end
end
//verilator
always @ (negedge wr_clk) begin
	if(wr_en && wr_first) begin
		input_buffer[wr_pointer] = wrdata;
		control_buffer[wr_pointer] = 2'b1;
		wr_pointer = wr_pointer + 1;
	end else if (wr_en && wr_last) begin
		input_buffer[wr_pointer] = wrdata;
		control_buffer[wr_pointer] = 2'd2;
		wr_pointer = wr_pointer + 1;
	end else if (wr_en) begin
		input_buffer[wr_pointer] = wrdata;
		control_buffer[wr_pointer] = 2'b0;
		wr_pointer = wr_pointer + 1;
	end
end
endmodule