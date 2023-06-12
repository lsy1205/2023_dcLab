module Image_Generator (
    input         i_clk,
    input         i_rst_n,
    input         i_valid,
    input         i_enable,
    input         i_pause,
    
    input         i_addr_valid,
    input  [19:0] i_ul_addr,
    input  [19:0] i_ur_addr,
    input  [19:0] i_dl_addr,
    input  [19:0] i_dr_addr,

    input  [31:0] i_cam_data, // {2'b0, R, G, B}
    output        o_vaild,
    output [31:0] o_data,

    input  [23:0] i_img_data,
    output [13:0] o_req_addr
);

logic [9:0]  row_counter_r, row_counter_w;
logic [9:0]  col_counter_r, col_counter_w;
logic [9:0]  cen_row_r, cen_row_w, cen_col_r, cen_col_w;
logic [31:0] out_data_r, out_data_w;
logic        valid_r, valid_w;
logic        enable_r, enable_w;
logic [11:0] row_sum, col_sum;
logic [13:0] req_addr_r, req_addr_w;

assign o_vaild = valid_r;
assign o_data = out_data_r;
assign row_sum = i_ul_addr[19:10] + i_ur_addr[19:10] + i_dl_addr[19:10] + i_dr_addr[19:10];
assign col_sum = i_ul_addr[9:0] + i_ur_addr[9:0] + i_dl_addr[9:0] + i_dr_addr[9:0];
assign o_req_addr = req_addr_w;

always_comb begin
    row_counter_w = row_counter_r;
    col_counter_w = col_counter_r;
    cen_row_w     = cen_row_r;
    cen_col_w     = cen_col_r;
    enable_w      = enable_r;
    req_addr_w    = req_addr_r;

    valid_w       = i_valid;
    out_data_w    = i_cam_data;

    if (i_addr_valid) begin
        cen_row_w = row_sum[11:2];
        cen_col_w = col_sum[11:2];
        enable_w  = i_enable;
    end

    if (enable_r) begin
        if (   row_counter_w > (cen_row_r - 65) 
            && row_counter_w < (cen_row_r + 64)
            && col_counter_w > (cen_col_r - 65)
            && col_counter_w < (cen_col_r + 64)) begin
            req_addr_w = req_addr_r + 1; // address jitter but is ok ^_^
        end

        // case({row_counter_r, col_counter_r})
        //     i_ul_addr: begin
        //         out_data_w = {2'b0, 10'h3ff, 10'h0, 10'h0};
        //     end
        //     i_ur_addr: begin
        //         out_data_w = {2'b0, 10'h0, 10'h3ff, 10'h3ff};
        //     end
        //     i_dl_addr: begin
        //         out_data_w = {2'b0, 10'h0, 10'h0, 10'h3ff};
        //     end
        //     i_dr_addr: begin
        //         out_data_w = {2'b0, 10'h3ff, 10'h0, 10'h3ff};
        //     end
        //     default: begin
        //     end
        // endcase
        
        if (   row_counter_r > (i_ul_addr[19:10]) 
            && row_counter_r < (i_ul_addr[19:10] + 9)
            && col_counter_r > (i_ul_addr[ 9: 0] - 10)
            && col_counter_r < (i_ul_addr[ 9: 0] + 9)) begin
            out_data_w = {2'b0, 10'h3ff, 10'h0, 10'h3ff};
        end

        if (   row_counter_r > (cen_row_r - 65)
            && row_counter_r < (cen_row_r + 64)
            && col_counter_r > (cen_col_r - 65)
            && col_counter_r < (cen_col_r + 64)) begin
            // out_data_w = 32'h000003ff; // Blue
            out_data_w = {2'b0, i_img_data[23:16], 2'b0, i_img_data[15:8], 2'b0, i_img_data[7:0], 2'b0};
        end 
    end
    
    if (i_valid) begin
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
        req_addr_r    <= 0;
    end
    else begin
        row_counter_r <= row_counter_w;
        col_counter_r <= col_counter_w;
        cen_row_r     <= cen_row_w;
        cen_col_r     <= cen_col_w;  
        out_data_r    <= out_data_w;
        valid_r       <= valid_w;
        enable_r      <= enable_w;
        req_addr_r    <= req_addr_w;
    end
end 

endmodule
