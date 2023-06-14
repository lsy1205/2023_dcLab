module Image_Generator (
    input         i_clk,
    input         i_rst_n,
    input         i_enable,
    input         i_pause,
    
    input         i_addr_valid,
    input  [19:0] i_ul_addr,
    input  [19:0] i_ur_addr,
    input  [19:0] i_dl_addr,
    input  [19:0] i_dr_addr,

    output        o_req_cam_data,
    input  [31:0] i_cam_data, // {2'b0, R, G, B}

    output        o_vaild,
    output [31:0] o_data,

    input  [23:0] i_img_data,
    output [13:0] o_req_addr,

    output        frame_valid
);

logic  [9:0] row_counter_r, row_counter_w;
logic [10:0] col_counter_r, col_counter_w;
logic  [9:0] cen_row_r, cen_row_w, cen_col_r, cen_col_w;
logic [31:0] out_data_r, out_data_w;
logic        valid_r, valid_w;
logic        enable_r, enable_w;
logic [11:0] row_sum, col_sum;
logic        req_cam_data_r, req_cam_data_w;
logic [32:0] A, B, C, D, E, F, G, H;
logic        inverse_valid;
logic        inverse_valid_w, inverse_valid_r;
logic        is_inside_w, is_inside_r;
logic [13:0] image_addr;
logic  [3:0] addr_req_counter_r, addr_req_counter_w;

assign frame_valid = (col_counter_r == 0 && row_counter_r == 0);

assign o_vaild = valid_r;
assign o_data = out_data_r;
assign row_sum = i_ul_addr[19:10] + i_ur_addr[19:10] + i_dl_addr[19:10] + i_dr_addr[19:10];
assign col_sum = i_ul_addr[9:0] + i_ur_addr[9:0] + i_dl_addr[9:0] + i_dr_addr[9:0];
assign o_req_addr = image_addr;
assign o_req_cam_data = req_cam_data_r;

// assign A = out_data_r;
// assign B = out_data_r;
// assign C = out_data_r;
// assign D = out_data_r;
// assign E = out_data_r;
// assign F = out_data_r;
// assign G = out_data_r;
// assign H = out_data_r;

GetPerspective get_perspective (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(i_addr_valid && i_enable),
	.i_ul_addr({i_ul_addr[9:0], i_ul_addr[19:10]}), // first 10 bit is x, last is y
	.i_ur_addr({i_ur_addr[9:0], i_ur_addr[19:10]}),
	.i_dr_addr({i_dr_addr[9:0], i_dr_addr[19:10]}),
	.i_dl_addr({i_dl_addr[9:0], i_dl_addr[19:10]}),
	.A(A),
	.B(B),
	.C(C),
	.D(D),
	.E(E),
	.F(F),
	.G(G),
	.H(H),
	.o_valid(inverse_valid)
);

PerspectiveTransformer perspective_transformer (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(req_cam_data_w),
    .i_A(A),
    .i_B(B),
    .i_C(C),
    .i_D(D),
    .i_E(E),
    .i_F(F),
    .i_G(G),
    .i_H(H),
    .o_inside(is_inside_w),
    .o_point(image_addr)
);

always_comb begin
    row_counter_w = row_counter_r;
    col_counter_w = col_counter_r;
    cen_row_w     = cen_row_r;
    cen_col_w     = cen_col_r;
    enable_w      = enable_r;
    out_data_w    = i_cam_data;
    req_cam_data_w = 1;
    valid_w       = 0;
    addr_req_counter_w = addr_req_counter_r;

    if (inverse_valid) begin
        addr_req_counter_w = 1;
    end
    if (addr_req_counter_r != 0 && addr_req_counter_r != 9) begin
        addr_req_counter_w = addr_req_counter_r + 1;
    end

    if (addr_req_counter_r != 9 && (i_pause || (col_counter_r > 797 && (col_counter_r < 1018 || row_counter_r == 599)) || row_counter_r == 600)) begin
        req_cam_data_w = 0;
    end
    // if (!i_pause && (col_counter_r < 798 || ((col_counter_r == 998 || col_counter_r == 999) && row_counter_r != 599)) && row_counter_r != 600 || col_counter_r == 10'h3ff) begin
    //     req_cam_data_w = 1;
    // end

    if (i_addr_valid) begin
        cen_row_w = row_sum[11:2];
        cen_col_w = col_sum[11:2];
        enable_w  = i_enable;
        row_counter_w = 10'b0;
        col_counter_w = 11'h7ff;
        req_cam_data_w = 1;
    end

    if (!i_pause && row_counter_r != 600) begin
        if (col_counter_r == 1019) begin
            col_counter_w = 0;
            row_counter_w = row_counter_r + 1;
        end
        else begin
            col_counter_w = col_counter_r + 1;
        end
    end

    if (!i_pause && enable_r) begin
        if (   row_counter_r > (i_ul_addr[19:10]) 
            && row_counter_r < (i_ul_addr[19:10] + 15)
            && col_counter_r > (i_ul_addr[ 9: 0] - 16)
            && col_counter_r < (i_ul_addr[ 9: 0] + 15)
            && col_counter_r < 800) begin
            out_data_w = {2'b0, 10'h3ff, 10'h0, 10'h3ff};
        end
        if (   row_counter_r > (i_ur_addr[19:10]) 
            && row_counter_r < (i_ur_addr[19:10] + 12)
            && col_counter_r > (i_ur_addr[ 9: 0] - 13)
            && col_counter_r < (i_ur_addr[ 9: 0] + 12)
            && col_counter_r < 800) begin
            out_data_w = {2'b0, 10'h3ff, 10'h0, 10'h0};
        end
        if (   row_counter_r > (i_dl_addr[19:10]) 
            && row_counter_r < (i_dl_addr[19:10] + 9)
            && col_counter_r > (i_dl_addr[ 9: 0] - 10)
            && col_counter_r < (i_dl_addr[ 9: 0] + 9)
            && col_counter_r < 800) begin
            out_data_w = {2'b0, 10'h0, 10'h3ff, 10'h3ff};
        end
        if (   row_counter_r > (i_dr_addr[19:10]) 
            && row_counter_r < (i_dr_addr[19:10] + 6)
            && col_counter_r > (i_dr_addr[ 9: 0] - 7)
            && col_counter_r < (i_dr_addr[ 9: 0] + 6)
            && col_counter_r < 800) begin
            out_data_w = {2'b0, 10'h0, 10'h0, 10'h3ff};
        end

        if (is_inside_r) begin
            out_data_w = {2'b0, i_img_data[23:16], 2'b0, i_img_data[15:8], 2'b0, i_img_data[7:0], 2'b0};
        end
    end

    if (!i_pause && row_counter_r != 600 && col_counter_r < 800) begin
        valid_w = 1;
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        row_counter_r      <= 10'd600;
        col_counter_r      <= 11'd0;
        cen_row_r          <= 0;
        cen_col_r          <= 0;
        out_data_r         <= 0;
        valid_r            <= 0;
        enable_r           <= 0;
        req_cam_data_r     <= 0;
        inverse_valid_r    <= 0;
        addr_req_counter_r <= 0;
        is_inside_r        <= 0;
    end
    else begin
        row_counter_r      <= row_counter_w;
        col_counter_r      <= col_counter_w;
        cen_row_r          <= cen_row_w;
        cen_col_r          <= cen_col_w;  
        out_data_r         <= out_data_w;
        valid_r            <= valid_w;
        enable_r           <= enable_w;
        req_cam_data_r     <= req_cam_data_w;
        inverse_valid_r    <= inverse_valid_w;
        addr_req_counter_r <= addr_req_counter_w;
        is_inside_r        <= is_inside_w;
    end
end 

endmodule
