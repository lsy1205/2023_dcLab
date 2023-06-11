module Image_Generator (
    input         i_clk,
    input         i_rst_n,
    input         i_valid,
    input         i_enable,
    input         i_recive,
    
    input         i_addr_valid,
    input  [19:0] i_ul_addr,
    input  [19:0] i_ur_addr,
    input  [19:0] i_dl_addr,
    input  [19:0] i_dr_addr,

    input  [31:0] i_data, // {2'b0, R, G, B}
    output        o_vaild,
    output [31:0] o_data,

    output        o_fin,
    output        o_test
);

logic [9:0]  row_counter_r, row_counter_w;
logic [9:0]  col_counter_r, col_counter_w;
logic [9:0]  cen_row_r, cen_row_w, cen_col_r, cen_col_w;
logic [31:0] out_data_r, out_data_w;
logic        valid_r, valid_w;
logic        enable_r, enable_w;
logic [11:0] row_sum, col_sum;
logic        fin_r, fin_w;

assign o_fin = fin_r;
assign o_vaild = valid_r;
assign o_data = out_data_r;
assign row_sum = i_ul_addr[19:10] + i_ur_addr[19:10] + i_dl_addr[19:10] + i_dr_addr[19:10];
assign col_sum = i_ul_addr[9:0] + i_ur_addr[9:0] + i_dl_addr[9:0] + i_dr_addr[9:0];

assign test = col_counter_r[0];

always_comb begin
    row_counter_w = row_counter_r;
    col_counter_w = col_counter_r;
    out_data_w    = out_data_r;
    valid_w       = i_valid;
    cen_row_w     = cen_row_r;
    cen_col_w     = cen_col_r;
    enable_w      = enable_r;
    fin_w         = fin_r;

    if (i_addr_valid) begin
        cen_row_w = row_sum[11:2];
        cen_col_w = col_sum[11:2];
        enable_w  = i_enable;
    end

    if (enable_r && 
        row_counter_r > (cen_row_r - 65) && row_counter_r < (cen_row_r + 64) &&
        col_counter_r > (cen_col_r - 65) && col_counter_r < (cen_col_r + 64)) begin
        out_data_w = 32'h000003ff; // Blue
    end 
    else begin
        out_data_w = i_data;
    end
    if (i_valid) begin
        if (col_counter_r == 799) begin
            col_counter_w = 0;
            if(row_counter_r == 599) begin
                row_counter_w = 0;
                fin_w = 1;
            end 
            else begin
                row_counter_w = row_counter_r + 1;
            end
        end
        else begin
            col_counter_w = col_counter_r + 1;
        end
    end

    if(i_recive) begin
        fin_w = 0;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        row_counter_r <= 0;
        col_counter_r <= 0;
        cen_row_r     <= 0;
        cen_col_r     <= 0;
        out_data_r    <= 0;
        valid_r       <= 0;
        enable_r      <= 0;
        fin_r         <= 0;
    end
    else begin
        row_counter_r <= row_counter_w;
        col_counter_r <= col_counter_w;
        cen_row_r     <= cen_row_w;
        cen_col_r     <= cen_col_w;  
        out_data_r    <= out_data_w;
        valid_r       <= valid_w;
        enable_r      <= enable_w;
        fin_r         <= fin_w;
    end
end 

endmodule
