`timescale 1ns/100ps
`define PERIOD     (10000)
`define HPERIOD    (`PERIOD/2)

module tb_i2c_initializer(
    inout sda
);

    integer error = 0;

    logic clk, rst_n;
	logic start, fin;
    // wire  sda;
    logic scl;
    logic [23:0] data;
    logic wm8731_sda;
    logic transmit;
    logic [23:0] answer [0:6];

    assign answer[0] = 24'b001101000001111000000000; // RESET
    assign answer[1] = 24'b001101000000100000010101; // AAPC
    assign answer[2] = 24'b001101000000101000000000; // DAPC
    assign answer[3] = 24'b001101000000110000000000; // PDC
    assign answer[4] = 24'b001101000000111001000010; // DAIF
    assign answer[5] = 24'b001101000001000000011001; // SC
    assign answer[6] = 24'b001101000001001000000001; // AC

    assign sda = (wm8731_sda) ? 1'bz : 1'b0;
    pullup(sda);

	I2CInitializer initializer0 (
        .i_rst_n(rst_n),
	    .i_clk(clk),
	    .i_start(start),
	    .o_fin(fin),
	    .io_sda(sda),
	    .o_scl(scl)
	);

	initial begin
		$fsdbDumpfile("i2c_initializer.fsdb");
		$fsdbDumpvars;
		start      = 0;
		data       = 0;
        transmit   = 0;
        // sda        = 1'bz;
        wm8731_sda = 1'b1;
		rst_n      = 0;
		#(2*`PERIOD)
		rst_n      = 1;
	end

	initial clk = 0;
	always #(`HPERIOD) clk = ~clk;

	initial begin : top
		#(10*`PERIOD)
        @(posedge clk) start = 1;
        @(posedge clk) start = 0;
	end

	// WM8731
    always@(negedge sda) begin
        if (scl && !transmit)
            transmit = 1;
    end
    
    always@(posedge sda) begin
        if (scl && transmit)
            transmit = 0;
    end
    
	initial begin: WM8731
        #(10*`PERIOD)
        for (int i = 0; i < 7; i++) begin
            wait(transmit);
            wait(!scl);
            for (int j = 0; j < 3 && transmit; j++) begin
                for (int k = 0; k < 8 && transmit; k++) begin
                    wait(scl);
                    data[23-(8*j+k)] = sda;
                    wait(!scl);
                end
                if (transmit) begin
                    wm8731_sda = 0;
                    wait(scl);
                    wait(!scl);
                    wm8731_sda = 1;
                end
            end
            wait(!transmit);
            if (data !== answer[i]) begin
                error = error + 1;
                $display("Error! Expect: %24b, But Received: %24b", answer[i], data);
            end
        end
        if (error) begin
            $display("===============================");
            $display("=       FUCK YOU LAB3         =");
            $display("=     Error count = %1d         =", error);
            $display("===============================");
        end
        else begin
            $display("===============================");
            $display("=        ALL PASS ^_^         =");
            $display("===============================");
        end
        $finish;
	end

	initial begin
		#(500000*`PERIOD)
		$display("Too slow, abort.");
		$finish;
	end

endmodule
