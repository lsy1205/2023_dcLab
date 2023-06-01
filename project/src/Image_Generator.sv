module Image_Generator (
    input         i_clk,
    input         i_rst_n,
    input         i_start,
    input         i_row, // row of center  picture is 128*128
    input         i_col, // col of center
    input  [31:0] i_data, // {2'b0, R, G, B}
    output        o_vaild,
    output [31:0] o_data
    
);
    localparam S_IDLE = 0;
    localparam S_EXEC = 1;

    logic [1:0]  state_r, state_w;
    logic [9:0]  row_counter_r, row_counter_w;
    logic [9:0]  col_counter_r, col_counter_w;
    logic [9:0]  center_row_r, center_row_w;
    logic [9:0]  center_col_r, center_col_w;
    logic [31:0] out_data_r, out_data_w;
    logic        valid_r, valid_w;

    always_comb begin : FSM
        state_w = S_IDLE;

        case (state_r)
        S_IDLE: begin
            if (i_start) begin
                state_w = S_EXEC;
            end
        end
        S_EXEC: begin
            state_w = S_IDLE;
        end
        default: begin
            state_w = S_IDLE;
        end
        endcase
    end
    
    always_comb begin
        row_counter_w = row_counter_r;
        col_counter_w = col_counter_r;
        center_row_w  = center_row_r;
        center_col_w  = center_col_r;
        out_data_w    = out_data_r;
        valid_w       = 0;
        
        case (state_r)
        S_IDLE: begin
            if (i_start) begin
                center_row_w = i_row;
                center_col_w = i_col;
            end
        end
        S_EXEC: begin
            if (row_counter_r > (center_row_r - 64) && row_counter_r < (center_row_r + 65) &&
                col_counter_r > (center_col_r - 64) && col_counter_r < (center_col_r + 65)) begin
                out_data_w = {22'b0, 10'b1};
            end 
            else begin
                out_data_w = i_data;
            end

            if (col_counter_r == 799) begin
                col_counter_w = 0;
                if(row_counter_r == 599) begin
                    row_counter_w = 0;
                end 
                else begin
                    row_counter_w = row_counter_r + 1;
                end
            end
            else begin
                col_counter_w = col_counter_r + 1;
            end
            valid_w = 1;

        end
        endcase
    end

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state_r       <= 0;
            row_counter_r <= 0;
            col_counter_r <= 0;
            center_row_r  <= 0;
            center_col_r  <= 0;
            out_data_r    <= 0;
            valid_r       <= 0;
        end
        else begin
            state_r       <= state_w;
            row_counter_r <= row_counter_w;
            col_counter_r <= col_counter_w;
            center_row_r  <= center_row_w;
            center_col_r  <= center_col_w;
            out_data_r    <= out_data_w;
            valid_r       <= valid_w;
        end
    end 

endmodule