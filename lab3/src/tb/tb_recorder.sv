`timescale 1ns/100ps
`define SAMPLE_NUM (20)
`define PERIOD     (84)
`define HPERIOD    (`PERIOD/2)
`define DELAY      (1 * `PERIOD/4)

module tb_player;
	integer error = 0;

	logic clk, bclk, rst_n;
	logic adclrck, start, aud_adcdat, fin;
	logic [15:0] wm8731_data, adc_data;
		
	AudRecorder recorder0 (
		.i_rst_n(rst_n),
		.i_bclk(bclk),
		.i_adclrck(adclrck),
		.i_start(start),
		.i_aud_adcdat(aud_adcdat),
		.o_adc_data(adc_data), // 16bits
		.o_fin(fin)
	);

	initial begin
		$fsdbDumpfile("recorder.fsdb");
		$fsdbDumpvars;
		start = 0;
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
			wait(adclrck);
			@(posedge clk) start = 1;
			@(posedge clk) start = 0;
			wait(fin);
			if (adc_data !== wm8731_data) begin
				$display("Error left! correct data: %16b , received data: %16b", adc_data, wm8731_data);
				error++;
			end
			#(3*`PERIOD);
			// @(posedge clk) start = 1;
			// @(posedge clk) start = 0;
			// wait(fin);
			// if (adc_data !== wm8731_data) begin
			// 	$display("Error right! correct data: %b , received data: %b", adc_data, wm8731_data);
			// 	error++;
			// end	
			// #(3*`PERIOD);
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
		adclrck = 1;
		@(negedge bclk) adclrck = ~adclrck;
		while (1) begin
			#(25*`PERIOD) adclrck = ~adclrck;
		end
	end
	initial begin
		#(10*`PERIOD)
		for (int i = 0; i < `SAMPLE_NUM; i++) begin
			@(negedge adclrck);
			wm8731_data = $random($stime);
			#(`HPERIOD)
			for (int i = 0; i < 16; i++) begin
				@(negedge bclk) begin
					aud_adcdat = wm8731_data[15-i];
				end
			end

			// @(posedge adclrck);
			// wm8731_data = $random($stime);
			// #(`HPERIOD)
			// for (int i = 0; i < 16; i++) begin
			// 	@(negedge bclk) begin
			// 		aud_adcdat = wm8731_data[15-i];
			// 	end
			// end
		end
	end

	initial begin
		#(500000*`PERIOD)
		$display("Too slow, abort.");
		$finish;
	end

endmodule
