`timescale 1ns/100ps
`define SAMPLE_NUM (20)
`define PERIOD     (84)
`define HPERIOD    (`PERIOD/2)
`define DELAY      (1 * `PERIOD/4)


module tb_player;
	integer error = 0;

	logic clk, bclk, rst_n;
	logic daclrck, start, aud_dacdat, fin;
	logic [15:0] dac_data, wm8731_data;
		
	AudPlayer player0 (
		.i_rst_n(rst_n),
		.i_bclk(bclk),
		.i_daclrck(daclrck),
		.i_start(start),
		.i_dac_data(dac_data), // 16bits
		.o_aud_dacdat(aud_dacdat),
		.o_fin(fin)
	);

	initial begin
		$fsdbDumpfile("player.fsdb");
		$fsdbDumpvars;
		start = 0;
		dac_data = 0;
		rst_n = 0;
		#(2*`PERIOD)
		rst_n = 1;
	end

	// DSP
	initial clk = 0;
	always #(`HPERIOD) clk = ~clk;
	initial begin : DSP
		#(10*`PERIOD)
		for(int i = 0; i < `SAMPLE_NUM; i++) begin
			wait(daclrck);
			dac_data = $random($stime);
			@(posedge clk) start = 1;
			@(posedge clk) start = 0;
			wait(fin);
			#(3*`PERIOD);
			dac_data = $random($stime);
			@(posedge clk) start = 1;
			@(posedge clk) start = 0;
			wait(fin);
			#(3*`PERIOD);
		end

		if(error) begin
			$display("===============================");
			$display("=       FUCK YOU LAB3         =");
			$display("=     Error count = %2d        =", error);
			$display("===============================");
		end
		else begin
			$display("===============================");
			$display("=        ALL PASS ^_^         =");
			$display("===============================");
		end

		$finish;
	end

	// WM8731
	initial begin
		bclk = 1;
		#(`DELAY) bclk = ~bclk;
		while (1) begin
			#(`HPERIOD) bclk = ~bclk;
		end
	end
	initial begin
		daclrck = 1;
		@(negedge bclk) daclrck = ~daclrck;
		while (1) begin
			#(25*`PERIOD) daclrck = ~daclrck;
		end
	end
	initial begin
		#(10*`PERIOD)
		for (int i = 0; i < `SAMPLE_NUM; i++) begin
			@(negedge daclrck);
			wm8731_data = 0;
			#(`PERIOD)
			for (int i = 0; i < 16; i++) begin
				@(posedge bclk) begin
					wm8731_data[15-i] = aud_dacdat;
				end
			end
			if (dac_data !== wm8731_data) begin
				$display("Error left! correct data: %16b , received data: %16b", dac_data, wm8731_data);
				error++;
			end

			@(posedge daclrck);
			#(`PERIOD)
			for (int i = 0; i < 16; i++) begin
				@(posedge bclk) begin
					wm8731_data[15-i] = aud_dacdat;
				end
			end
			if (dac_data !== wm8731_data) begin
				$display("Error right! correct data: %b , received data: %b", dac_data, wm8731_data);
				error++;
			end			
		end
	end

	initial begin
		#(500000*`PERIOD)
		$display("Too slow, abort.");
		$finish;
	end

endmodule
