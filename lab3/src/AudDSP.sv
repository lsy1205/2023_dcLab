module AudDSP (
    input         i_rst_n,
	input         i_clk,
	input         i_clear,
	input         i_mode,		// 0: play, 1:record
	input   [3:0] i_speed,		// 1: 1/8, 2: 1/7, ..., 8: 1, ..., 14: 7, 15: 8
	input         i_interpol,	// 0: 0-order, 1: 1-order
	input         i_start,
	output        o_fin,

	output  [2:0] o_next_num,	// 0: nxt 1, 1: nxt 2, ..., 7: nxt 8
	output        o_mem_start,
	input         i_mem_fin,

	input  [15:0] i_rdata,
	output [15:0] o_dac_data,

	input  [15:0] i_adc_data,
	output [15:0] o_wdata
);

localparam S_IDLE = 0;
localparam S_SAVE = 1;
localparam S_CALC = 2;
localparam S_INCR = 3;

logic  [1:0] state_r, state_w;
logic  [2:0] counter_r, counter_w;
logic        fin_r, fin_w;

logic  [2:0] next_num_r, next_num_w;
logic        mem_start_r, mem_start_w;
logic        mem_fin;

logic [15:0] last_data_r, last_data_w;
logic [15:0] data_r, data_w;

logic [15:0] delta_r, delta_w;
logic [15:0] diff, quotient, temp;
logic        sign_r, sign_w;
logic        div_3, div_5, div_7;


assign o_fin      = fin_r;

assign o_next_num  = next_num_r;
assign o_mem_start = mem_start_r;
assign o_dac_data  = (i_speed[3]) ? data_r : last_data_r;
assign o_wdata     = data_r;


Div357 div0 (
	.i_in(diff),
	.i_div_3(div_3),
	.i_div_5(div_5),
	.i_div_7(div_7),
	.o_out(quotient)
);

always_comb begin : FSM
	state_w = state_r;

	case (state_r)
		S_IDLE: begin
			if (i_start) begin
				state_w = (i_mode) ? S_SAVE :
				          (counter_r) ? S_INCR : S_CALC;
			end
		end 
		S_SAVE: begin
			if (i_mem_fin) begin
				state_w = S_IDLE;
			end
		end
		S_CALC: begin
			if (i_mem_fin) begin
				state_w = S_IDLE;
			end
		end
		S_INCR: begin
			state_w = S_IDLE;
		end
		default: begin
			state_w = S_IDLE;
		end 
	endcase
end

always_comb begin
	counter_w   = counter_r;
	last_data_w = last_data_r;
	data_w      = data_r;
	delta_w     = delta_r;
	sign_w      = sign_r;
	next_num_w  = next_num_r;
	fin_w       = 0;
	mem_start_w = 0;
	div_3 = 0;
	div_5 = 0;
	div_7 = 0;
	diff  = 0;

	case (state_r)
		S_IDLE: begin
			if (i_start) begin
				mem_start_w = (!i_mode && !counter_r);
				next_num_w  = (!i_mode && i_speed[3]) ? i_speed[2:0] : 0;
			end
		end
		S_SAVE: begin
			data_w      = i_adc_data;
			fin_w       = 1;
			mem_start_w = 1;
		end
		S_CALC: begin
			if (i_mem_fin) begin
				last_data_w = data_r;
				data_w      = i_rdata;
				fin_w       = 1;

				if (!i_speed[3]) begin
					counter_w = i_speed;
					temp = i_rdata - data_r;
					sign_w = temp[15];
					diff = (i_interpol == 0) ? 0 :
					       (temp[15]) ? data_r - i_rdata : temp;

					case (i_speed[2:0])
						3'd1: begin  // 1/8
							delta_w = diff >> 3;
						end
						3'd2: begin  // 1/7
							div_7 = 1;
							delta_w = quotient;
						end
						3'd3: begin  // 1/6
							div_3 = 1;
							delta_w = quotient >> 1;
						end
						3'd4: begin  // 1/5
							div_5 = 1;
							delta_w = quotient;
						end
						3'd5: begin  // 1/4
							delta_w = diff >> 2;
						end
						3'd6: begin  // 1/3
							div_3 = 1;
							delta_w = quotient;
						end
						3'd7: begin  // 1/2
							delta_w = diff >> 1;
						end
						default: begin
							div_3   = 0;
							div_5   = 0;
							div_7   = 0;
							diff    = 0;
							delta_w = 0;
						end
					endcase
				end
			end
		end
		S_INCR: begin
			counter_w   = counter_r + 1;
			last_data_w = last_data_r + delta_r;
			fin_w       = 1;
		end
		default: begin
			counter_w   = counter_r;
			last_data_w = last_data_r;
			data_w      = data_r;
			delta_w     = delta_r;
			sign_w      = sign_r;
			next_num_w  = next_num_r;
			fin_w       = 0;
			mem_start_w = 0;
			div_3 = 0;
			div_5 = 0;
			div_7 = 0;
			diff  = 0;
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n || i_clear) begin
		state_r     <= S_IDLE;
		counter_r   <= 3'b0;
		last_data_r <= 1'b0;
		data_r      <= 16'b0;
		delta_r     <= 16'b0;
		sign_r      <= 1'b0;
		fin_r       <= 1'b0;
		mem_start_r <= 1'b0;
	end
	else begin
		state_r     <= state_w;
		counter_r   <= counter_w;
		last_data_r <= last_data_w;
		data_r      <= data_w;
		delta_r     <= delta_w;
		sign_r      <= sign_w;
		fin_r       <= fin_w;
		mem_start_r <= mem_start_w;
	end
end
endmodule
