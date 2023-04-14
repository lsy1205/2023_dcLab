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

// command
localparam COMMON =   00110100000;
localparam RESET  = 1111000000000;
localparam AAPC   = 0100000010101;
localparam DAPC   = 0101000000000;
localparam PDC    = 0110000000000;
localparam DAIF   = 0111001000010;
localparam SC     = 1000000011001;
localparam AC     = 1001000000001;

logic        state_r, state_w;
logic  [2:0] cmd_counter_r, cmd_counter_w;
logic  [4:0] counter_r, counter_w;
logic [23:0] data_r, data_w;
logic        out_r, out_w;
logic        o_fin_r, o_fin_w;
logic        ack;
logic        ack1_r, ack1_w, ack2_r, ack2_w, ack3_r, ack3_w;

assign io_sda = out_r ? 1'bz : 1'b0;
assign o_scl  = (state_r == S_TRANS|| state_r == S_ACK) ? ~i_clk : 1;
assign o_fin  = o_fin_r;
assign ack    = ack1 && ack2 && ack3;

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
			else                   state_w = S_IDLE;
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
	ack1_w        = ack1_r;
	ack2_w        = ack2_r;
	ack3_w        = ack3_r;
	out_w         = 1;
	o_fin_w       = 0;
	case (state_r)
		S_IDLE: begin
			out_w         = 1;
			ack1_w        = 0;
			ack2_w        = 0;
			ack3_w        = 0;
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
						data_w = {23{1'b1}};
					end
				endcase
			end
			else begin
				counter_w = 0;
				out_w     = data_r[23];
				data_w    = data_r << 1;
			end
		end
		S_TRANS: begin
			counter_w = counter_r + 1;
			out_w     = data_r[23];
			data_w    = data_r << 1;
		end
		S_ACK: begin
			counter_w = counter_r + 1;
			out_w     = 1'b1;
			case (counter_r)
				8: begin
					ack1_w = io_sda;
				end
				17: begin
					ack2_w = io_sda;
				end
				26:begin
					ack3_w = io_sda;
				end
				default: begin
				end
			endcase
		end
		S_TER: begin
			cmd_counter_w = cmd_counter_r + 1;
			counter_w     = 0;
			out_w         = 0;
			if(cmd_counter_r == 6) begin
				o_fin_w = 1;
			end
			else begin
				o_fin_w = 0;
			end
		end
		default: begin
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
		ack1_r        <= 0;
		ack2_r        <= 0;
		ack3_r        <= 0;
		o_fin_r       <= 0;
	end

	else begin
		state_r       <= state_w;
		counter_r     <= counter_w;
		cmd_counter_r <= cmd_counter_w;
		data_r        <= data_w;
		out_r         <= out_w;
		ack1_r        <= ack1_w;
		ack2_r        <= ack2_w;
		ack3_r        <= ack3_w;
		o_fin_r       <= o_fin_w;

	end
end

endmodule

// module i2c (
// 			 CLOCK,
// 			 I2C_SCLK,		//I2C CLOCK
// 			 I2C_SDAT,		//I2C DATA
// 			 I2C_DATA,		//DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
// 			 GO,      		//GO transfor
// 			 END,    	    //END transfor 
// 			 ACK,     	    //ACK
// 			 RESET,
// 			 SDO
// 		   	);

// //=======================================================
// //  PORT declarations
// //=======================================================
			
// 	input 			[23:0]I2C_DATA;	
//  output  		      I2C_SDAT;
 		
// 	output 			      I2C_SCLK;
// //TEST
// 	output	[5:0]	 SD_COUNTER;
// 	output 			 SDO;




// wire I2C_SCLK = SCLK | ( ((SD_COUNTER >= 4) & (SD_COUNTER <= 30))? ~CLOCK :0 );

// reg ACK1,ACK2,ACK3;
// wire ACK = ACK1 | ACK2 | ACK3;

// //==============================I2C COUNTER====================================
// always @(negedge RESET or posedge CLOCK ) 
// 	begin
// 		if (!RESET)
// 			begin
// 				SD_COUNTER = 6'b111111;
// 			end
// 		else begin
// 				if (GO == 0)
// 					begin
// 						SD_COUNTER = 0;
// 					end
// 				else begin
// 						if (SD_COUNTER < 6'b111111)
// 							begin
// 								SD_COUNTER = SD_COUNTER+1;
// 							end	
// 					 end		
// 			 end
// 	end
// //==============================I2C COUNTER====================================

// always @(negedge RESET or  posedge CLOCK ) 
// 	begin
// 		if (!RESET) 
// 			begin 
// 				SCLK = 1;
// 				SDO  = 1; 
// 				ACK1 = 0;
// 				ACK2 = 0;
// 				ACK3 = 0; 
// 				END  = 1; 
// 			end
// 		else
// 			case (SD_COUNTER)
// 					6'd0  : begin 
// 								ACK1 = 0 ;
// 								ACK2 = 0 ;
// 								ACK3 = 0 ; 
// 								END  = 0 ; 
// 								SDO  =1  ; 
// 								SCLK =1  ;
// 							end
// 					//=========start===========
// 					6'd1  : begin 
// 								SD  = I2C_DATA;
// 								SDO = 0;
// 							end
							
// 					6'd2  : 	SCLK = 0;
// 					//======SLAVE ADDR=========
// 					6'd3  : 	SDO = SD[23];
// 					6'd4  : 	SDO = SD[22];
// 					6'd5  : 	SDO = SD[21];
// 					6'd6  : 	SDO = SD[20];
// 					6'd7  : 	SDO = SD[19];
// 					6'd8  : 	SDO = SD[18];
// 					6'd9  :	    SDO	= SD[17];
// 					6'd10 : 	SDO = SD[16];	
// 					6'd11 : 	SDO = 1'b1;//ACK

// 					//========SUB ADDR==========
// 					6'd12  : begin 
// 								SDO  = SD[15]; 
// 								ACK1 = I2C_SDAT; 
// 							 end
// 					6'd13  : 	SDO = SD[14];
// 					6'd14  : 	SDO = SD[13];
// 					6'd15  : 	SDO = SD[12];
// 					6'd16  : 	SDO = SD[11];
// 					6'd17  : 	SDO = SD[10];
// 					6'd18  : 	SDO = SD[9];
// 					6'd19  : 	SDO = SD[8];	
// 					6'd20  : 	SDO = 1'b1;//ACK

// 					//===========DATA============
// 					6'd21  : begin 
// 								SDO  = SD[7]; 
// 								ACK2 = I2C_SDAT; 
// 							 end
// 					6'd22  : 	SDO = SD[6];
// 					6'd23  : 	SDO = SD[5];
// 					6'd24  : 	SDO = SD[4];
// 					6'd25  : 	SDO = SD[3];
// 					6'd26  : 	SDO = SD[2];
// 					6'd27  : 	SDO = SD[1];
// 					6'd28  : 	SDO = SD[0];	
// 					6'd29  : 	SDO = 1'b1;//ACK

	
// 					//stop
// 					6'd30 : begin 
// 								SDO  = 1'b0;	
// 								SCLK = 1'b0; 
// 								ACK3 = I2C_SDAT; 
// 							end	
// 					6'd31 : 	SCLK = 1'b1; 
// 					6'd32 : begin 
// 								SDO = 1'b1; 
// 								END = 1; 
// 							end 

// 			endcase
// 	end
	
// endmodule
