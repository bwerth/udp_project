// Adder testbench
`timescale 1 ns / 1 ps
`include "crc.v"

module testCRC();
    reg [175:0] crc_rx;
    reg [31:0] sending_crc_rx;
    reg crc_rx_start, rx_clk;
    reg [5:0] fail_counter = 0;
    wire check_valid, check_passed;

    crc_validate rx_crc_test(.udp_rx(crc_rx),.sending_crc(sending_crc_rx),.udp_rx_start(crc_rx_start),.clk(rx_clk),.check_valid(check_valid),.check_passed(check_passed));

    always  
    	#5  rx_clk =  ! rx_clk;

    initial begin
        $dumpfile("crc.vcd");
    	$dumpvars();
    	fail_counter = 0;
    	$display("Beginning CRC_Validate Testing");
    	crc_rx = 176'h4c82ae9bf314c82ae9bf314c82ae9bf314c82ae9bf31; sending_crc_rx = 32'b10011100100101111100000011010100; crc_rx_start = 1'b1; #10
    	crc_rx_start = 1'b0; #2000
    	if(check_valid != 1'b1 && check_valid != 0) begin
    		fail_counter = fail_counter + 1;
    		$display("CRC_Validate %b %b",crc_rx,sending_crc_rx);
    	end
    	crc_rx = 176'h4c82ae9bf314c82ae9bf314c82ae9bf314c82ae9bf31; sending_crc_rx = 32'b01100011011010000011111100101011; crc_rx_start = 1'b1; #10
    	crc_rx_start = 1'b0; #2000
    	if(check_valid != 1'b1 && check_valid != 1) begin
    		fail_counter = fail_counter + 1;
    		$display("CRC_Validate %b %b",crc_rx,sending_crc_rx);
    	end
    	crc_rx = 176'h23beee6489223beee6489223beee6489223beee64892; sending_crc_rx = 32'b10011000111011100010011101000101; crc_rx_start = 1'b1; #10
    	crc_rx_start = 1'b0; #2000
    	if(check_valid != 1'b1 && check_valid != 0) begin
    		fail_counter = fail_counter + 1;
    		$display("CRC_Validate %b %b",crc_rx,sending_crc_rx);
    	end
    	crc_rx = 176'h23beee6489223beee6489223beee6489223beee64892; sending_crc_rx = 32'b01100111000100011101100010111010; crc_rx_start = 1'b1; #10
    	crc_rx_start = 1'b0; #2000
    	if(check_valid != 1'b1 && check_valid != 1) begin
    		fail_counter = fail_counter + 1;
    		$display("CRC_Validate %b %b",crc_rx,sending_crc_rx);
    	end
    	$display("%d of 4 Tests Passed",fail_counter);
    end
endmodule
