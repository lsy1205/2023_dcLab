module Rsa256Wrapper (
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest
);

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// Feel free to design your own FSM!
localparam S_GET_KEY        = 0;
localparam S_GET_DATA       = 1;
localparam S_WAIT_CALCULATE = 2;
localparam S_SEND_DATA      = 3;

localparam ST_CHECK = 0;
localparam ST_TRANS = 1;

logic [255:0] n_r, n_w, d_r, d_w, enc_r, enc_w, dec_r, dec_w;
logic   [1:0] state_r, state_w;
logic   [6:0] bytes_counter_r, bytes_counter_w;
logic   [4:0] avm_address_r, avm_address_w;
logic         avm_read_r, avm_read_w, avm_write_r, avm_write_w;

logic         rsa_start_r, rsa_start_w;
logic         rsa_finished;
logic [255:0] rsa_dec;

logic         stage_r, stage_w;

assign avm_address   = avm_address_r;
assign avm_read      = avm_read_r;
assign avm_write     = avm_write_r;
assign avm_writedata = dec_r[247-:8];

Rsa256Core rsa256_core(
    .i_clk(avm_clk),
    .i_rst(avm_rst),
    .i_start(rsa_start_r),
    .i_msg(enc_r),
    .i_key(d_r),
    .i_n(n_r),
    .o_ans(rsa_dec),
    .o_finished(rsa_finished)
);

task StartRead;
    input [4:0] addr;
    begin
        avm_read_w = 1;
        avm_write_w = 0;
        avm_address_w = addr;
    end
endtask
task StartWrite;
    input [4:0] addr;
    begin
        avm_read_w = 0;
        avm_write_w = 1;
        avm_address_w = addr;
    end
endtask

always_comb begin : FSM
    // TODO
    state_w = state_r;

    case (state_r)
        S_GET_KEY: begin
            if(bytes_counter_r == 63 && !avm_waitrequest && stage_r == ST_TRANS) begin
                state_w = S_GET_DATA;
            end
        end
        S_GET_DATA: begin
            if(bytes_counter_r == 31 && !avm_waitrequest && stage_r == ST_TRANS) begin
                state_w = S_WAIT_CALCULATE;
            end
        end
        S_WAIT_CALCULATE: begin
            if(rsa_finished) begin
                state_w = S_SEND_DATA;
            end
        end
        S_SEND_DATA: begin
            if(bytes_counter_r == 30 && !avm_waitrequest && stage_r == ST_TRANS) begin
                state_w = S_GET_DATA;
            end
        end
        default: begin
            state_w = state_r;
        end
    endcase
end

always_comb begin
    n_w             = n_r;
    d_w             = d_r;
    enc_w           = enc_r;
    dec_w           = dec_r;
    avm_address_w   = avm_address_r;
    avm_read_w      = avm_read_r;
    avm_write_w     = avm_write_r;
    bytes_counter_w = bytes_counter_r;
    rsa_start_w     = rsa_start_r;
    stage_w         = stage_r;

    case (state_r)
        S_GET_KEY: begin
            case (stage_r)
                ST_CHECK: begin
                    avm_read_w = 1;
                    avm_write_w = 0;
                    avm_address_w = STATUS_BASE;
                    
                    if(!avm_waitrequest && avm_readdata[RX_OK_BIT]) begin
                        avm_read_w = 0; // can delete???????
                        stage_w = ST_TRANS;
                    end
                end
                ST_TRANS: begin
                    avm_read_w = 1;
                    avm_write_w = 0;
                    avm_address_w = RX_BASE;
                    
                    if(!avm_waitrequest) begin
                        if(bytes_counter_r < 32) begin
                            n_w = n_r >> 8;
                            n_w[255-:8] = avm_readdata[7:0];
                        end
                        else begin
                            d_w = d_r >> 8;
                            d_w[255-:8] = avm_readdata[7:0];
                        end
                    
                        bytes_counter_w = (bytes_counter_r != 63) ? bytes_counter_r + 1 : 0;
                        avm_read_w = 0;
                        stage_w = ST_CHECK;
                    end
                end
            endcase
        end
        S_GET_DATA: begin
            case (stage_r)
                ST_CHECK: begin
                    avm_read_w = 1;
                    avm_write_w = 0;
                    avm_address_w = STATUS_BASE;
                    
                    if(!avm_waitrequest && avm_readdata[RX_OK_BIT]) begin
                        avm_read_w = 0;
                        stage_w = ST_TRANS;
                    end
                end
                ST_TRANS: begin
                    avm_read_w = 1;
                    avm_write_w = 0;
                    avm_address_w = RX_BASE;
                    
                    if(!avm_waitrequest) begin
                        enc_w = enc_r >> 8;
                        enc_w[255-:8] = avm_readdata[7:0];
                        
                        bytes_counter_w = (bytes_counter_r != 31) ? bytes_counter_r + 1 : 0;
                        rsa_start_w = (bytes_counter_r == 31); 
                        avm_read_w = 0;
                        stage_w = ST_CHECK;
                    end
                end
            endcase
        end
        S_WAIT_CALCULATE: begin
            avm_read_w = 0;
            avm_write_w = 0;
        end
        S_SEND_DATA: begin
            case (stage_r)
                ST_CHECK: begin
                    avm_read_w = 1;
                    avm_write_w = 0;
                    avm_address_w = STATUS_BASE;

                    if(!avm_waitrequest && avm_readdata[TX_OK_BIT]) begin
                        avm_read_w = 0;
                        stage_w = ST_TRANS;
                    end
                end
                ST_TRANS: begin
                    avm_read_w = 0;
                    avm_write_w = 1;
                    avm_address_w = TX_BASE;

                    if(!avm_waitrequest) begin
                        dec_w = dec_r << 8;
                        bytes_counter_w = (bytes_counter_r != 30) ? bytes_counter_r + 1 : 0;
                        avm_write_w = 0;
                        stage_w = ST_CHECK;
                    end
                end
            endcase
        end
        default: begin
            n_w             = n_r;
            d_w             = d_r;
            enc_w           = enc_r;
            dec_w           = dec_r;
            avm_address_w   = avm_address_r;
            avm_read_w      = avm_read_r;
            avm_write_w     = avm_write_r;
            bytes_counter_w = bytes_counter_r;
            rsa_start_w     = rsa_start_r;
            stage_w         = stage_r;
        end
    endcase
end

always_ff @(posedge avm_clk or posedge avm_rst) begin
    if (avm_rst) begin
        n_r             <= 0;
        d_r             <= 0;
        enc_r           <= 0;
        dec_r           <= 0;
        avm_address_r   <= STATUS_BASE;
        avm_read_r      <= 1;
        avm_write_r     <= 0;
        state_r         <= S_GET_KEY;
        bytes_counter_r <= 63;
        rsa_start_r     <= 0;
        stage_r         <= 0;
    end else begin
        n_r             <= n_w;
        d_r             <= d_w;
        enc_r           <= enc_w;
        dec_r           <= dec_w;
        avm_address_r   <= avm_address_w;
        avm_read_r      <= avm_read_w;
        avm_write_r     <= avm_write_w;
        state_r         <= state_w;
        bytes_counter_r <= bytes_counter_w;
        rsa_start_r     <= rsa_start_w;
        stage_r         <= stage_w;
    end
end

endmodule
