module Image_Generator (
    input         i_clk,
    input         i_rst_n,
    input         i_pause,

    input         i_addr_valid,
    input         i_enable,
    input  [19:0] i_ul_addr,
    input  [19:0] i_ur_addr,
    input  [19:0] i_dl_addr,
    input  [19:0] i_dr_addr,

    output        o_req_cam_data,
    input  [31:0] i_cam_data, // {2'b0, R, G, B}

    output [13:0] o_req_img_addr,
    input  [23:0] i_img_data,

    output        o_vaild,
    output [31:0] o_data,

    output        o_inside,
    output [35:0] o_A,
    output [35:0] o_B,
    output [35:0] o_C,
    output [35:0] o_D,
    output [35:0] o_E,
    output [35:0] o_F,
    output [35:0] o_G,
    output [35:0] o_H
);

logic  [9:0] row_counter_r, row_counter_w;
logic  [9:0] col_counter_r, col_counter_w;

logic        enable_r, enable_w;
logic        valid_r, valid_w;
logic [31:0] out_data_r, out_data_w;

logic        inverse_valid;
logic [35:0] A, B, C, D, E, F, G, H;

logic        can_fetch;
logic [13:0] image_addr;
logic        is_inside_r, is_inside_w;

logic        req_next;

assign o_inside = is_inside_r && valid_r;
assign frame_valid = (col_counter_r == 0 && row_counter_r == 0);

assign req_next = (!i_pause && col_counter_w < 800 && row_counter_w < 600);

assign o_req_cam_data = req_next;
assign o_req_img_addr = {image_addr[6:0], image_addr[13:7]};

assign o_vaild = valid_r;
assign o_data  = out_data_r;


assign o_A = A;
assign o_B = B;
assign o_C = C;
assign o_D = D;
assign o_E = E;
assign o_F = F;
assign o_G = G;
assign o_H = H;

GetPerspective get_perspective (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(i_addr_valid && i_enable),
	.i_ul_addr({i_ul_addr[9:0], i_ul_addr[19:10]}),     // {col, row}
	.i_ur_addr({i_ur_addr[9:0], i_ur_addr[19:10]}),     // {col, row}
	.i_dr_addr({i_dr_addr[9:0], i_dr_addr[19:10]}),     // {col, row}
	.i_dl_addr({i_dl_addr[9:0], i_dl_addr[19:10]}),     // {col, row}

    // .i_ul_addr({10'd310, 10'd63}),
    // .i_ur_addr({10'd500, 10'd18}),
    // .i_dr_addr({10'd400, 10'd190}),
    // .i_dl_addr({10'd290, 10'd220}),

	.o_A(A),
	.o_B(B),
	.o_C(C),
	.o_D(D),
	.o_E(E),
	.o_F(F),
	.o_G(G),
	.o_H(H),
	.o_valid(inverse_valid)
);

PerspectiveTransformer perspective_transformer (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(inverse_valid),
    .i_A(A),
    .i_B(B),
    .i_C(C),
    .i_D(D),
    .i_E(E),
    .i_F(F),
    .i_G(G),
    .i_H(H),
    .i_req(req_next),
    .o_inside(is_inside_w),
    .o_point(image_addr),       // {col, row}
    .o_can_fetch(can_fetch)
);

always_comb begin
    row_counter_w = row_counter_r;
    col_counter_w = col_counter_r;
    enable_w      = enable_r;
    out_data_w    = i_cam_data;
    valid_w       = req_next;

    if (i_addr_valid) begin
        enable_w = i_enable;
    end

    if ((i_addr_valid && !i_enable) || (enable_r && can_fetch)) begin
        row_counter_w = 10'b0;
        col_counter_w = 10'b0;
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

    if (!i_pause && enable_r && col_counter_r < 800) begin
        if (is_inside_r) begin
            out_data_w = {2'b0, i_img_data[23:16], 2'b0, i_img_data[15:8], 2'b0, i_img_data[7:0], 2'b0};
        end

        // if (   row_counter_r > (i_ul_addr[19:10]) 
        //     && row_counter_r < (i_ul_addr[19:10] + 15)
        //     && col_counter_r > (i_ul_addr[ 9: 0] - 16)
        //     && col_counter_r < (i_ul_addr[ 9: 0] + 15)) begin
        //     out_data_w = {2'b0, 10'h3ff, 10'h0, 10'h3ff}; //RGB
        // end
        // if (   row_counter_r > (i_ur_addr[19:10]) 
        //     && row_counter_r < (i_ur_addr[19:10] + 12)
        //     && col_counter_r > (i_ur_addr[ 9: 0] - 13)
        //     && col_counter_r < (i_ur_addr[ 9: 0] + 12)) begin
        //     out_data_w = {2'b0, 10'h3ff, 10'h0, 10'h0};
        // end
        // if (   row_counter_r > (i_dl_addr[19:10]) 
        //     && row_counter_r < (i_dl_addr[19:10] + 9)
        //     && col_counter_r > (i_dl_addr[ 9: 0] - 10)
        //     && col_counter_r < (i_dl_addr[ 9: 0] + 9)) begin
        //     out_data_w = {2'b0, 10'h0, 10'h3ff, 10'h3ff};
        // end
        // if (   row_counter_r > (i_dr_addr[19:10]) 
        //     && row_counter_r < (i_dr_addr[19:10] + 6)
        //     && col_counter_r > (i_dr_addr[ 9: 0] - 7)
        //     && col_counter_r < (i_dr_addr[ 9: 0] + 6)) begin
        //     out_data_w = {2'b0, 10'h0, 10'h0, 10'h3ff};
        // end
    end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        row_counter_r <= 10'd600;
        col_counter_r <= 10'd0;
        enable_r      <= 0;
        valid_r       <= 0;
        out_data_r    <= 0;
        is_inside_r   <= 0;
    end
    else begin
        row_counter_r <= row_counter_w;
        col_counter_r <= col_counter_w;
        enable_r      <= enable_w;
        valid_r       <= valid_w;
        out_data_r    <= out_data_w;
        is_inside_r   <= is_inside_w;
    end
end 

endmodule
