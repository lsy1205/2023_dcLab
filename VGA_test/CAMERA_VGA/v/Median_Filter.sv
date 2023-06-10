module Median_Filter (
    input  i_clk,
    input  i_rst_n,
    input  i_valid,
    input  i_data,
    output o_valid,
    output o_data
);
localparam ROW_SIZE    = 800;
localparam BUFFER_SIZE = 1605;
logic [BUFFER_SIZE - 1:0] buffer_r, buffer_w;
logic               [9:0] row_cntr_r, row_cntr_w;
logic               [9:0] column_cntr_r, column_cntr_w;
logic [3:0] sum;
logic data_r, data_w;
logic valid_r, valid_w;

assign o_data  = data_r;
assign o_valid = valid_r;
assign sum     = ((buffer_r[1603+1] + buffer_r[1603] + buffer_r[1603-1]) 
                + (buffer_r[ 802+1] + buffer_r[ 802] + buffer_r[ 802-1])) 
                + (buffer_r[     1] + buffer_r[   0] + buffer_w[0]);

always_comb begin
    row_cntr_w = row_cntr_r;
    column_cntr_w = column_cntr_r;
    buffer_w = buffer_r;
    valid_w = 0;
    data_w = (sum > 6) ? 1 : 0;

    if (i_valid || column_cntr_r == 800 || column_cntr_r == 801 || row_cntr_r == 600) begin
        buffer_w[BUFFER_SIZE - 1:1] = buffer_r[BUFFER_SIZE - 2:0];
        buffer_w[0] = (i_valid) ? i_data : 0;
        column_cntr_w = (column_cntr_r == 801) ? 0 : column_cntr_r + 1;
    end
    if (column_cntr_r == 801) begin
        row_cntr_w = (row_cntr_r == 600) ? 0 : row_cntr_r + 1;
    end

    if (row_cntr_r && column_cntr_r && column_cntr_r != 801) begin
        valid_w = 1;
    end

end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        buffer_r      <= 0;
        row_cntr_r    <= 0;
        column_cntr_r <= 0;
        data_r        <= 0;
        valid_r       <= 0;
    end
    else begin
        buffer_r      <= buffer_w;
        row_cntr_r    <= row_cntr_w;
        column_cntr_r <= column_cntr_w;
        data_r        <= data_w;
        valid_r       <= valid_w;
        // valid_r       <= i_valid;
    end
end
endmodule
