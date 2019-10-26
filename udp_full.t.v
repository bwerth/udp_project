/*

   UDP/IP I/O:

  //IP Layer signals
  in udp_tx_start
  in udp_txi
  out udp_tx_result (1:0)
  out udp_tx_data_out_ready
  out udp_rx_start
  out udp_rxo

  //system signals
  in rx_clk
  in tx_clk
  in reset
  in our_ip_address (31:0)
  in our_mac_address (47:0)
  //status signals
  out arp_pkt_count (7:0)
  out ip_pkt_count (7:0)
  //MAC Transmitter
  out mac_tx_tdata (7:0)
  out mac_tx_tvalid 
  in mac_tx_tready
  out mac_tx_tfirst
  out mac_tx_tlast
  //MAC Receiver
  in mac_rx_tdata (7:0)
  in mac_rx_tvalid
  out mac_rx_tready
  in mac_rx_tlast
*/

module udptestbench();

	reg udp_tx_start;
	wire udp_tx_data_out_ready, udp_rx_start;
	reg [63:0] udp_txi;
	wire [63:0] udp_rxo;
	wire [1:0] udp_tx_result;

	reg rx_clk, tx_clk, reset;
	reg [31:0] our_ip_address;
	reg [47:0] our_mac_address;
	wire [7:0] arp_pkt_count, ip_pkt_count, mac_tx_tdata;
	wire mac_tx_tvalid, mac_tx_tfirst, mac_tx_tlast, mac_rx_tready;
	reg mac_tx_tready, mac_rx_tvalid, mac_rx_tlast;
	reg [7:0] mac_rx_tdata;

	udpip_full udp_test(udp_tx_start, udp_txi, udp_tx_result, udp_tx_data_out_ready, udp_rx_start, udp_rxo, rx_clk, tx_clk, reset, our_ip_address, our_mac_address, arp_pkt_count, ip_pkt_count, mac_tx_tdata, mac_tx_tvalid, mac_tx_tready, mac_tx_tfirst, mac_tx_tlast, mac_rx_tdata, mac_rx_tvalid, mac_rx_tready, mac_rx_tlast);

	always begin
		#5 rx_clk = !rx_clk;
		tx_clk = !tx_clk;
	end

	initial begin
		our_ip_address = 32'ha0dea0de;
		our_mac_address = 48'h1f2b1f2b1f2b;
		ip_tx_start = 1'b0;
		mac_tx_tready = 1'b0;
		reset = 1'b1; #100
		reset = 1'b0; #50
		if(udp_tx_start != 2'b00 || udp_tx_data_out_ready != 1'b0 || mac_tx_tvalid != 0 || mac_tx_tlast != 1'b0 || arp_pkt_count != 8'b0 || ip_pkt_count != 8'b0 || udp_rx_start != 1'b0 || udp_rxo != 64'h0000000000000000) begin
			$display("Reset test failed");
		endif
	    mac_rx_tvalid = 1'b1;
		//dst MAC (bc)
		mac_rx_tdata = 8'h1f; #10
		mac_rx_tdata = 8'h2b; #10
		mac_rx_tdata = 8'h1f; #10
		mac_rx_tdata = 8'h2b; #10
		mac_rx_tdata = 8'h1f; #10
		mac_rx_tdata = 8'h2b; #10
		//src MAC
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h1f; #10
		mac_rx_tdata = 8'h23; #10
		mac_rx_tdata = 8'h3d; #10
		mac_rx_tdata = 8'hcd; #10
		mac_rx_tdata = 8'h45; #10
		//type
		mac_rx_tdata = 8'h08; #10
		mac_rx_tdata = 8'h00; #10
		//ver & HL / service type
		mac_rx_tdata = 8'h45; #10
		mac_rx_tdata = 8'h00; #10
		//total len
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h21; #10
		//ID
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h7a; #10
		//flags & frag
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h00; #10
		//TTL
		mac_rx_tdata = 8'h80; #10
		//Protocol
		mac_rx_tdata = 8'h11; #10
		//Header CKS
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h00; #10
		-- SRC IP
		mac_rx_tdata = 8'hc0; #10
		mac_rx_tdata = 8'ha8; #10
		mac_rx_tdata = 8'h05; #10
		mac_rx_tdata = 8'h01; #10
		-- DST IP
		mac_rx_tdata = 8'ha0; #10
		mac_rx_tdata = 8'hde; #10
		mac_rx_tdata = 8'ha0; #10
		mac_rx_tdata = 8'hde; #10
		-- SRC port
		mac_rx_tdata = 8'hf4; #10
		mac_rx_tdata = 8'h9a; #10
		-- DST port
		mac_rx_tdata = 8'h26; #10
		mac_rx_tdata = 8'h94; #10
		-- length
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h0d; #10
		-- cks
		mac_rx_tdata = 8'h8b; #10
		mac_rx_tdata = 8'h79; #10
		-- user data
		mac_rx_tdata = 8'h68; #10
		mac_rx_tdata = 8'h65; #10
		mac_rx_tdata = 8'h6c; #10
		mac_rx_tdata = 8'h6c; #10
		mac_rx_tdata = 8'h6f; mac_rx_tlast = 1'b1; #10
		mac_rx_tdata = 8'h00;
		mac_rx_tlast = 1'b0;
		mac_rx_tvalid = 1'b0; #250

		mac_rx_tvalid = 1'b1;
		//dst MAC (bc)
		mac_rx_tdata = 8'h1f; #10
		mac_rx_tdata = 8'h2b; #10
		mac_rx_tdata = 8'h1f; #10
		mac_rx_tdata = 8'h2b; #10
		mac_rx_tdata = 8'h1f; #10
		mac_rx_tdata = 8'h2b; #10
		//src MAC
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h1f; #10
		mac_rx_tdata = 8'h23; #10
		mac_rx_tdata = 8'h3d; #10
		mac_rx_tdata = 8'hcd; #10
		mac_rx_tdata = 8'h45; #10
		//type
		mac_rx_tdata = 8'h08; #10
		mac_rx_tdata = 8'h00; #10
		//ver & HL / service type
		mac_rx_tdata = 8'h45; #10
		mac_rx_tdata = 8'h00; #10
		//total len
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h21; #10
		//ID
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h7a; #10
		//flags & frag
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h00; #10
		//TTL
		mac_rx_tdata = 8'h80; #10
		//Protocol
		mac_rx_tdata = 8'h11; #10
		//Header CKS
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h00; #10
		-- SRC IP
		mac_rx_tdata = 8'hc0; #10
		mac_rx_tdata = 8'ha8; #10
		mac_rx_tdata = 8'h05; #10
		mac_rx_tdata = 8'h01; #10
		-- DST IP
		mac_rx_tdata = 8'ha0; #10
		mac_rx_tdata = 8'hde; #10
		mac_rx_tdata = 8'ha0; #10
		mac_rx_tdata = 8'hde; #10
		-- SRC port
		mac_rx_tdata = 8'hf4; #10
		mac_rx_tdata = 8'h9a; #10
		-- DST port
		mac_rx_tdata = 8'h26; #10
		mac_rx_tdata = 8'h94; #10
		-- length
		mac_rx_tdata = 8'h00; #10
		mac_rx_tdata = 8'h0d; #10
		-- cks
		mac_rx_tdata = 8'h8b; #10
		mac_rx_tdata = 8'h79; #10
		-- user data
		mac_rx_tdata = 8'h42; #10
		mac_rx_tdata = 8'h65; #10
		mac_rx_tdata = 8'h6c; #10
		mac_rx_tdata = 8'h6c; #10
		mac_rx_tdata = 8'h6f; mac_rx_tlast = 1'b1; #10
		mac_rx_tdata = 8'h00;
		mac_rx_tlast = 1'b0;
		mac_rx_tvalid = 1'b0; #250
	end
endmodule

