module AudPlayer (
    input         i_rst_n,
	input         i_bclk,
	input         i_daclrck,
	input         i_start,
	input  [15:0] i_dac_data,
	output        o_aud_dacdat,
	output        o_fin
);
    
localparam S_IDLE = 0; // wait enable
localparam S_WAIT = 1; // wait lrc change
localparam S_SEND = 2; // send data

logic [1:0]  state_r, state_w;
logic [3:0]  counter_r, counter_w;
logic [15:0] record_data_r, record_data_w;
logic        record_lrc_r, record_lrc_w;
logic        fin_r, fin_w;

assign o_aud_dacdat = record_data_r[15];
assign o_fin = fin_r;

always_comb begin : FSM
	state_w = state_r;

	case(state_r) 
		S_IDLE: begin
			state_w = (i_start) ? S_WAIT : S_IDLE;
		end
		S_WAIT: begin
			state_w = (record_lrc_r != i_daclrck) ? S_SEND : S_WAIT;
		end
		S_SEND: begin
			state_w = (counter_r == 15) ? S_IDLE : S_SEND;
		end
		default: begin
			state_w = S_IDLE;
		end
	endcase
end

always_comb begin
	counter_w = counter_r;
	record_data_w = record_data_r;
	record_lrc_w = record_lrc_r;
	fin_w = 0;

	case(state_r)
		S_IDLE: begin
			counter_w = 0;
			record_lrc_w = i_daclrck;
			record_data_w = (i_start) ? i_dac_data : 0;
		end
		S_WAIT: begin
			counter_w = 0;
			record_lrc_w = i_daclrck;
		end
		S_SEND: begin
			counter_w = counter_r + 1;
			fin_w = (counter_r == 15)? 1 : 0;
			record_data_w = (counter_r) ? record_data_r << 1 : record_data_r;
		end
		default: begin
			counter_w = counter_r;
			record_data_w = record_data_r;
			record_lrc_w = record_lrc_r;
			fin_w = 0;
		end
	endcase
end

always_ff @(posedge i_bclk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r       <= S_IDLE;
		counter_r     <= 0;
		record_lrc_r  <= 0;
		fin_r         <= 0;
	end
	else begin
		state_r       <= state_w;
		counter_r     <= counter_w;
		record_lrc_r  <= record_lrc_w;
		fin_r         <= fin_w;
	end
end

always_ff @(negedge i_bclk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		record_data_r <= 0;
	end
	else begin
		record_data_r <= record_data_w;
	end
end


endmodule
