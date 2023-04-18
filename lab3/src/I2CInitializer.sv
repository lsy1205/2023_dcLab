module I2CInitializer (
    input  i_rst_n,
	input  i_clk,
	input  i_start,
	output o_fin,
	inout  io_sda,
	output o_scl
	// output o_oen // you are outputing (you are not outputing only when you are "ack"ing.)
);

// state
localparam S_IDLE  = 3'd0;
localparam S_START = 3'd1;
localparam S_TRANS = 3'd2;
localparam S_ACK   = 3'd3;
localparam S_TER   = 3'd4;
localparam S_FIN   = 3'd5;

// command
localparam COMMON  =        12'b0011_0100_1_000;
localparam RESET   = 16'b1_1110_1_0000_0000_1_0;
localparam AAPC    = 16'b0_1000_1_0001_0101_1_0;
localparam DAPC    = 16'b0_1010_1_0000_0000_1_0;
localparam PDC     = 16'b0_1100_1_0000_0000_1_0;
localparam DAIF    = 16'b0_1110_1_0100_0010_1_0;
localparam SC      = 16'b1_0000_1_0001_1001_1_0;
localparam AC      = 16'b1_0010_1_0000_0001_1_0;

logic  [2:0] state_r, state_w;
logic  [2:0] cmd_counter_r, cmd_counter_w;
logic  [4:0] counter_r, counter_w;
logic [27:0] data_r, data_w;
logic        out_r, out_w;
logic        o_fin_r, o_fin_w;
logic        nack;
logic        nack1_r, nack1_w, nack2_r, nack2_w, nack3_r, nack3_w;

assign io_sda = out_r ? 1'bz : 1'b0;
assign o_scl  = (state_r == S_TRANS || state_r == S_ACK || state_r == S_TER) ? ~i_clk : 1;
assign o_fin  = o_fin_r;
assign nack   = nack1_r | nack2_r | nack3_r;

always_comb begin: FSM
	state_w = S_IDLE;
	case (state_r)
		S_IDLE: begin
			if(i_start) state_w = S_START;
			else        state_w = S_IDLE;
		end
		S_START: begin
			if(counter_r == 1) state_w = S_TRANS;
			else               state_w = S_START;
		end
		S_TRANS: begin
			if(counter_r == 7 || counter_r == 16 || counter_r == 25) state_w = S_ACK;
			else state_w = S_TRANS;
		end
		S_ACK: begin
			if(counter_r != 26) state_w = S_TRANS;
			else                state_w = S_TER;
		end
		S_TER: begin
			if(cmd_counter_r != 6) state_w = S_START;
			else                   state_w = S_FIN;
		end
		S_FIN: begin
			state_w = S_FIN;
		end
		default: begin
			state_w = S_IDLE;
		end
	endcase
end

always_comb begin
	counter_w     = counter_r;
	cmd_counter_w = cmd_counter_r;
	data_w        = data_r;
	nack1_w       = nack1_r;
	nack2_w       = nack2_r;
	nack3_w       = nack3_r;
	out_w         = 1;
	o_fin_w       = o_fin_r;
	case (state_r)
		S_IDLE: begin
			out_w         = 1;
			nack1_w       = 0;
			nack2_w       = 0;
			nack3_w       = 0;
			counter_w     = 0;
			cmd_counter_w = 0;
		end
		S_START: begin
			counter_w = counter_r + 1;
			if (counter_r == 0) begin
				out_w = 0;
				case (cmd_counter_r)
					3'd0: begin
						data_w = {COMMON, RESET};
					end 
					3'd1: begin
						data_w = {COMMON, AAPC};
					end 
					3'd2: begin
						data_w = {COMMON, DAPC};
					end 
					3'd3: begin
						data_w = {COMMON, PDC};
					end 
					3'd4: begin
						data_w = {COMMON, DAIF};
					end 
					3'd5: begin
						data_w = {COMMON, SC};
					end 
					3'd6: begin
						data_w = {COMMON, AC};
					end 
					default: begin
						data_w = {28{1'b1}};
					end
				endcase
			end
			else begin
				counter_w = 0;
				out_w     = data_r[27];
				data_w    = data_r << 1;
			end
		end
		S_TRANS: begin
			counter_w = counter_r + 1;
			out_w     = data_r[27];
			data_w    = data_r << 1;
		end
		S_ACK: begin
			counter_w = counter_r + 1;
			out_w     = data_r[27];
			data_w    = data_r << 1;
			case (counter_r)
				5'd08: begin
					nack1_w = io_sda;
				end
				5'd17: begin
					nack2_w = io_sda;
				end
				5'd26: begin
					nack3_w = io_sda;
				end
				default: begin
				end
			endcase
		end
		S_TER: begin
			cmd_counter_w = cmd_counter_r + 1;
			counter_w     = 0;
			out_w         = 1;
			o_fin_w = (cmd_counter_r == 6);
		end
		S_FIN: begin
			
		end
		default: begin
			counter_w     = counter_r;
			cmd_counter_w = cmd_counter_r;
			data_w        = data_r;
			nack1_w       = nack1_r;
			nack2_w       = nack2_r;
			nack3_w       = nack3_r;
			out_w         = 1;
			o_fin_w       = 0;
		end
	endcase
end

always_ff @( posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		state_r       <= S_IDLE;
		counter_r     <= 0;
		cmd_counter_r <= 0;
		data_r        <= 0;
		out_r         <= 0;
		nack1_r       <= 0;
		nack2_r       <= 0;
		nack3_r       <= 0;
		o_fin_r       <= 0;
	end
	else begin
		state_r       <= state_w;
		counter_r     <= counter_w;
		cmd_counter_r <= cmd_counter_w;
		data_r        <= data_w;
		out_r         <= out_w;
		nack1_r       <= nack1_w;
		nack2_r       <= nack2_w;
		nack3_r       <= nack3_w;
		o_fin_r       <= o_fin_w;
	end
end

endmodule
