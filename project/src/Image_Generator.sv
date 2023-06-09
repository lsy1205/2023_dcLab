module Image_Generator (
    input         i_clk,
    input         i_rst_n,
    input         i_valid,

    input         i_row, // row of center  picture is 128*128
    input         i_col, // col of center
    input  [31:0] i_data, // {8'b0, R, G, B}
    output        o_vaild,
    output [31:0] o_data
);
    logic [9:0]  row_counter_r, row_counter_w;
    logic [9:0]  col_counter_r, col_counter_w;
    logic [31:0] out_data_r, out_data_w;
    logic        valid_r, valid_w;

    assign o_vaild = valid_r;
    assign o_data = out_data_r;

    always_comb begin
        row_counter_w = row_counter_r;
        col_counter_w = col_counter_r;
        out_data_w    = out_data_r;
        valid_w       = i_valid;
    
        if (row_counter_r > (i_row - 64) && row_counter_r < (i_row + 65) &&
            col_counter_r > (i_col - 64) && col_counter_r < (i_col + 65)) begin
            out_data_w = 32'h000000ff; // Blue
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

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            row_counter_r <= 0;
            col_counter_r <= 0;
            out_data_r    <= 0;
            valid_r       <= 0;
        end
        else begin
            row_counter_r <= row_counter_w;
            col_counter_r <= col_counter_w;
            out_data_r    <= out_data_w;
            valid_r       <= valid_w;
        end
    end 

endmodule
