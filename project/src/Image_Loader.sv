module Image_Loader (
    input         avm_clk,
    input         avm_rst_n,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest,
    output        avm_valid
);

localparam BYTE_COUNT = 12288;

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

localparam S_CHECK = 1'b0;
localparam S_TRANS = 1'b1;

logic        state_r, state_w;
logic [13:0] bytes_counter_r, bytes_counter_w;  // 64 x 64 x 3 = 12288
logic  [4:0] avm_address_r, avm_address_w;
logic        avm_read_r, avm_read_w, avm_write_r, avm_write_w;
logic  [7:0] get_byte_r, get_byte_w;
logic        valid_r, valid_w;

assign avm_address   = avm_address_r;
assign avm_read      = avm_read_r;
assign avm_write     = avm_write_r;
assign avm_writedata = get_byte_r;
assign avm_valid     = valid_r;

always_comb begin : FSM
    state_w = state_r;

    case (state_r)
        S_CHECK: begin
            if(!avm_waitrequest && avm_readdata[RX_OK_BIT]) begin
                state_w = S_TRANS;
            end
        end
        S_TRANS: begin
            if(bytes_counter_r == BYTE_COUNT-1 && !avm_waitrequest) begin
                state_w = S_CHECK;
            end
        end
        default: begin
            state_w = S_CHECK;
        end
    endcase
end

always_comb begin
    bytes_counter_w = bytes_counter_r;
    avm_address_w   = avm_address_r;
    avm_read_w      = avm_read_r;
    avm_write_w     = avm_write_r;
    get_byte_w      = get_byte_r;
    valid_w         = 0;

    case (state_r)
        S_CHECK: begin
            avm_read_w = 1;
            avm_write_w = 0;
            avm_address_w = STATUS_BASE;
            
            if(!avm_waitrequest && avm_readdata[RX_OK_BIT]) begin
                avm_read_w = 0;
            end
        end
        S_TRANS: begin
            avm_read_w = 1;
            avm_write_w = 0;
            avm_address_w = RX_BASE;
            
            if(!avm_waitrequest) begin
                get_byte_w = avm_readdata[7:0];
                if (bytes_counter_r == BYTE_COUNT-1) begin
                    bytes_counter_w = 0;
                end
                else begin
                    bytes_counter_w = bytes_counter_r + 1;
                end
                avm_read_w = 0;
                valid_w = 1;
            end
        end
        default: begin
            bytes_counter_w = bytes_counter_r;
            avm_address_w   = avm_address_r;
            avm_read_w      = avm_read_r;
            avm_write_w     = avm_write_r;
        end
    endcase
end

always_ff @(negedge avm_clk or negedge avm_rst_n) begin
    if (!avm_rst_n) begin
        state_r         <= S_CHECK;
        bytes_counter_r <= 0;
        get_byte_r      <= 0;
        valid_r         <= 0;
        avm_address_r   <= STATUS_BASE;
        avm_read_r      <= 0;
        avm_write_r     <= 0;
    end
    else begin
        state_r         <= state_w;
        bytes_counter_r <= bytes_counter_w;
        get_byte_r      <= get_byte_w;
        valid_r         <= valid_w;
        avm_address_r   <= avm_address_w;
        avm_read_r      <= avm_read_w;
        avm_write_r     <= avm_write_w;
    end
end

endmodule
