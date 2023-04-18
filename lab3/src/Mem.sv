module Mem (
    input         i_clk,
    input         i_rst_n,
    input         i_mode, // 0: play(read), 1: record(write)
    input   [2:0] i_next_num,
    input         i_start,
    output        o_fin,

    output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,

    input  [15:0] i_w_data,
    output        o_vaild,
    output [15:0] o_r_data
);

localparam S_IDLE = 0;
localparam S_FETCH = 1;

logic [19:0] data_length_r, data_length_w;
logic state_r, state_w;

assign o_SRAM_ADDR = data_addr;
assign io_SRAM_DQ  = (i_mode) ? record_data : 16'dz; // sram_dq as output
assign o_r_data   = (!i_mode) ?  io_SRAM_DQ : 16'd0; // sram_dq as input
assign o_SRAM_WE_N = (i_mode) ?        1'b0 :  1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

always_comb begin
    state_w = state_r;
    case (state_r)
        S_IDLE: begin
            
        end 
        default: 
    endcase
end
    
endmodule



module AudDSP (
    input         i_rst_n,
	input         i_clk,
	input         i_clear,
	input         i_mode,		// 0: play, 1:record
	input   [3:0] i_speed,		// 0: 1/8, 1: 1/7, ..., 7: 1, ..., 13: 7, 14: 8
	input         i_interpol,	// 0: 0-order, 1: 1-order
	// input         i_lr,         // 0: left, 1: right
	input         i_start,
	output        o_fin,

	output [19:0] o_data_addr,

	// input         i_dac_lrck,
	input         i_rdata_ready,
	input  [15:0] i_rdata,
	output [15:0] o_dac_data,

	// input         i_adc_lrck,
	input  [15:0] i_adc_data,
	output [15:0] o_wdata
);

localparam S_IDLE = 0;
localparam S_RECD = 1;
localparam S_PLAY = 2;
localparam S_CLAC = 3;

logic  [1:0] state_r, state_w;
logic        fin_r, fin_w;
logic [19:0] data_addr_r, data_addr_w;
logic [19:0] last_l_r, last_l_w, last_r_r, last_r_w;
logic  [2:0] counter_r, counter_w;
logic [19:0] data_length_r, data_length_w;
logic [15:0] data_r, data_w;

assign o_data_addr = data_addr_r;
assign o_wdata = i_adc_data;
assign o_dac_data = data_r;
assign o_fin = fin_r;

always_comb begin : FSM
	state_w = state_r;

	case (state_r)
		S_IDLE: begin
			if (i_start) begin
				state_w = (i_mode) ? S_RECD : S_PLAY;
			end
		end 
		S_RECD: begin
			state_w = S_IDLE;
		end
		S_PLAY: begin
			if (i_rdata_ready) begin
				if (i_speed > 6) begin
					state_w = S_IDLE;
				end
				else begin
					state_w = S_CLAC;
				end
			end
		end
		S_CLAC: begin
			case (i_speed)
				4'd0: begin
					if (counter_r == 8) begin
						state_w = S_IDLE;
					end
				end
				4'd1: begin
					if (counter_r == 7) begin
						state_w = S_IDLE;
					end
				end
				4'd2: begin
					if (counter_r == 6) begin
						state_w = S_IDLE;
					end
				end
				4'd3: begin
					if (counter_r == 5) begin
						state_w = S_IDLE;
					end
				end
				4'd4: begin
					if (counter_r == 4) begin
						state_w = S_IDLE;
					end
				end
				4'd5: begin
					if (counter_r == 3) begin
						state_w = S_IDLE;
					end
				end
				4'd6: begin
					if (counter_r == 2) begin
						state_w = S_IDLE;
					end
				end
				default: begin
					state_w = S_IDLE;
				end
			endcase
		end
		default: begin
			state_w = S_IDLE;
		end 
	endcase
end

always_comb begin
	data_r = data_w;
	data_addr_w = data_addr_r;
	data_length_w = data_length_r;
	last_l_w = last_l_r;
	last_r_w = last_r_r;
	counter_w = counter_r;
	fin_w = 0;

	case (state_r)
		S_IDLE: begin
			if (i_start) begin
				counter_w = 0;

				if (i_mode) begin
					data_addr_w = data_addr_r + 1;
				end
				else begin
					if (data_addr_r == 20'hfffff) begin
						data_addr_w = data_addr_r + 1;
					end
					else if (data_addr_r[0]) begin
						case (i_speed)
							4'd8: begin
								data_addr_w = data_addr_r + 4;	
							end
							4'd9: begin
								data_addr_w = data_addr_r + 6;	
							end
							4'd10: begin
								data_addr_w = data_addr_r + 8;	
							end
							4'd11: begin
								data_addr_w = data_addr_r + 10;	
							end
							4'd12: begin
								data_addr_w = data_addr_r + 12;	
							end
							4'd13: begin
								data_addr_w = data_addr_r + 14;	
							end
							4'd14: begin
								data_addr_w = data_addr_r + 16;	
							end
							default: begin
								data_addr_w = data_addr_r + 1;
							end 
						endcase
					end
					else data_addr_w = data_addr_r + 1;
				end
			end
		end
		S_RECD: begin
			data_length_w = data_length_r + 1;
			fin_w = 1;
		end
		S_PLAY: begin
			if (i_rdata_ready) begin
				if (i_speed > 6) begin
					data_w = i_rdata;
					fin_w = 1;
				end
			end
		end
		S_CLAC: begin
			counter_w = counter_r + 1;

			case (i_speed)
				4'd0: begin
					if (counter_r == 8) begin
						fin_w = 1;
						if (data_addr_r[0]) begin
							last_r_w = i_rdata;
						end
						else begin
							last_l_w = i_rdata;
						end						
					end
					else begin
						if (data_addr_r[0]) begin
							data_w = (i_interpol) ? ((counter_r+1)*(last_r_r >> 3) + (7-counter_r)*(i_rdata >> 3)) : last_r_r;
						end
						else begin
							data_w = (i_interpol) ? ((counter_r+1)*(last_l_r >> 3) + (7-counter_r)*(i_rdata >> 3)) : last_l_r;
						end
					end 

				end
				4'd1: begin
					if (counter_r == 7) begin
						fin_w = 1;
						if (data_addr_r[0]) begin
							last_r_w = i_rdata;
						end
						else begin
							last_l_w = i_rdata;
						end						
					end
					else begin
						if (data_addr_r[0]) begin
							data_w = (i_interpol) ? ((counter_r+1)/7*last_r_r + (6-counter_r)/7*i_rdata) : last_r_r;
						end
						else begin
							data_w = (i_interpol) ? ((counter_r+1)/7*last_l_r + (6-counter_r)/7*i_rdata) : last_l_r;
						end
					end 
				end
				4'd2: begin
					if (counter_r == 6) begin
						fin_w = 1;
						if (data_addr_r[0]) begin
							last_r_w = i_rdata;
						end
						else begin
							last_l_w = i_rdata;
						end						
					end
					else begin
						if (data_addr_r[0]) begin
							data_w = (i_interpol) ? ((counter_r+1)/6*last_r_r + (5-counter_r)/6*i_rdata) : last_r_r;
						end
						else begin
							data_w = (i_interpol) ? ((counter_r+1)/6*last_l_r + (5-counter_r)/6*i_rdata) : last_l_r;
						end
					end 
				end
				4'd3: begin
					if (counter_r == 5) begin
						fin_w = 1;
						if (data_addr_r[0]) begin
							last_r_w = i_rdata;
						end
						else begin
							last_l_w = i_rdata;
						end						
					end
					else begin
						if (data_addr_r[0]) begin
							data_w = (i_interpol) ? ((counter_r+1)/5*last_r_r + (4-counter_r)/5*i_rdata) : last_r_r;
						end
						else begin
							data_w = (i_interpol) ? ((counter_r+1)/5*last_l_r + (4-counter_r)/5*i_rdata) : last_l_r;
						end
					end 
				end
				4'd4: begin
					if (counter_r == 4) begin
						fin_w = 1;
						if (data_addr_r[0]) begin
							last_r_w = i_rdata;
						end
						else begin
							last_l_w = i_rdata;
						end						
					end
					else begin
						if (data_addr_r[0]) begin
							data_w = (i_interpol) ? ((counter_r+1)*(last_r_r >> 2) + (3-counter_r)*(i_rdata >> 2)) : last_r_r;
						end
						else begin
							data_w = (i_interpol) ? ((counter_r+1)*(last_l_r >> 2) + (3-counter_r)*(i_rdata >> 2)) : last_l_r;
						end
					end 
				end
				4'd5: begin
					if (counter_r == 3) begin
						fin_w = 1;
						if (data_addr_r[0]) begin
							last_r_w = i_rdata;
						end
						else begin
							last_l_w = i_rdata;
						end						
					end
					else begin
						if (data_addr_r[0]) begin
							data_w = (i_interpol) ? ((counter_r+1)/3*last_r_r + (2-counter_r)/3*i_rdata) : last_r_r;
						end
						else begin
							data_w = (i_interpol) ? ((counter_r+1)/3*last_l_r + (2-counter_r)/3*i_rdata) : last_l_r;
						end
					end 
				end
				4'd6: begin
					if (counter_r == 2) begin
						fin_w = 1;
						if (data_addr_r[0]) begin
							last_r_w = i_rdata;
						end
						else begin
							last_l_w = i_rdata;
						end						
					end
					else begin
						if (data_addr_r[0]) begin
							data_w = (i_interpol) ? ((counter_r + 1) * ((last_r_r + i_rdata) >> 1)) : last_r_r;
						end
						else begin
							data_w = (i_interpol) ? ((counter_r + 1) * ((last_l_r + i_rdata) >> 1)) : last_l_r;
						end
					end 
				end
				default: begin
					data_w = i_rdata;
					fin_w = 1;
				end
			endcase
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r       <= S_IDLE;
		data_addr_r   <= 20'hfffff;
		data_length_r <= 0;
		last_l_r      <= 0;
		last_r_r      <= 0;
		counter_r     <= 0;
		fin_r         <= 0;
	end
	else if (i_clear) begin // data_length reserve?
		state_r       <= S_IDLE;
		data_addr_r   <= 20'hfffff;
		data_length_r <= data_length_w;
		last_l_r      <= 0;
		last_r_r      <= 0;
		counter_r     <= 0;
		fin_r         <= 0;
	end
	else begin
		state_r       <= state_w;
		data_addr_r   <= data_addr_w;
		data_length_r <= data_length_w;
		last_l_r      <= last_l_w;
		last_r_r      <= last_r_w;
		counter_r     <= counter_w;
		fin_r         <= fin_w;
	end
end
endmodule
