module Top (
    i_clk,
    i_rst_n,

    //////////// LED //////////
    LEDG,
    LEDR,

    //////////// KEY //////////
    KEY,

    //////////// SW //////////
    SW,

    //////////// SEG7 //////////
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5,
    HEX6,
    HEX7,

    //////////// LCD //////////
    LCD_BLON,
    LCD_DATA,
    LCD_EN,
    LCD_ON,
    LCD_RS,
    LCD_RW,

    //////////// RS232 //////////
    UART_CTS,
    UART_RTS,
    UART_RXD,
    UART_TXD,

    //////////// SDCARD //////////
    SD_CLK,
    SD_CMD,
    SD_DAT,
    SD_WP_N,

    //////////// VGA //////////
    VGA_B,
    VGA_BLANK_N,
    VGA_CLK,
    VGA_G,
    VGA_HS,
    VGA_R,
    VGA_SYNC_N,
    VGA_VS,

    //////////// Audio //////////
    AUD_ADCDAT,
    AUD_ADCLRCK,
    AUD_BCLK,
    AUD_DACDAT,
    AUD_DACLRCK,
    AUD_XCK,

    //////////// I2C for Audio Tv-Decoder  //////////
    I2C_SCLK,
    I2C_SDAT,

    //////////// IR Receiver //////////
    IRDA_RXD,

    //////////// SDRAM //////////
    DRAM_ADDR,
    DRAM_BA,
    DRAM_CAS_N,
    DRAM_CKE,
    DRAM_CLK,
    DRAM_CS_N,
    DRAM_DQ,
    DRAM_DQM,
    DRAM_RAS_N,
    DRAM_WE_N,

    //////////// SRAM //////////
    SRAM_ADDR,
    SRAM_CE_N,
    SRAM_DQ,
    SRAM_LB_N,
    SRAM_OE_N,
    SRAM_UB_N,
    SRAM_WE_N,

    //////////// GPIO, GPIO connect to D5M - 5M Pixel Camera //////////
    D5M_D,
    D5M_FVAL,
    D5M_LVAL,
    D5M_PIXLCLK,
    D5M_RESET_N,
    D5M_SCLK,
    D5M_SDATA,
    D5M_STROBE,
    D5M_TRIGGER,
    D5M_XCLKIN 
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

input                          i_clk;
input                          i_rst_n;

//////////// LED //////////
output             [8:0]        LEDG;
output            [17:0]        LEDR;

//////////// KEY //////////
input             [3:0]        KEY;

//////////// SW //////////
input            [17:0]        SW;

//////////// SEG7 //////////
output             [6:0]        HEX0;
output             [6:0]        HEX1;
output             [6:0]        HEX2;
output             [6:0]        HEX3;
output             [6:0]        HEX4;
output             [6:0]        HEX5;
output             [6:0]        HEX6;
output             [6:0]        HEX7;

//////////// LCD //////////
output                          LCD_BLON;
inout             [7:0]        LCD_DATA;
output                          LCD_EN;
output                          LCD_ON;
output                          LCD_RS;
output                          LCD_RW;

//////////// RS232 //////////
output                          UART_CTS;
input                          UART_RTS;
input                          UART_RXD;
output                          UART_TXD;

//////////// SDCARD //////////
output                          SD_CLK;
inout                          SD_CMD;
inout             [3:0]        SD_DAT;
input                          SD_WP_N;

//////////// VGA //////////
output             [7:0]        VGA_B;
output                          VGA_BLANK_N;
output                          VGA_CLK;
output             [7:0]        VGA_G;
output                          VGA_HS;
output             [7:0]        VGA_R;
output                          VGA_SYNC_N;
output                          VGA_VS;

//////////// Audio //////////
input                          AUD_ADCDAT;
inout                          AUD_ADCLRCK;
inout                          AUD_BCLK;
output                          AUD_DACDAT;
inout                          AUD_DACLRCK;
output                          AUD_XCK;

//////////// I2C for Audio Tv-Decoder  //////////
output                          I2C_SCLK;
inout                          I2C_SDAT;

//////////// IR Receiver //////////
input                          IRDA_RXD;

//////////// SDRAM //////////
output            [12:0]        DRAM_ADDR;
output             [1:0]        DRAM_BA;
output                          DRAM_CAS_N;
output                          DRAM_CKE;
output                          DRAM_CLK;
output                          DRAM_CS_N;
inout            [31:0]        DRAM_DQ;
output             [3:0]        DRAM_DQM;
output                          DRAM_RAS_N;
output                          DRAM_WE_N;

//////////// SRAM //////////
output            [19:0]        SRAM_ADDR;
output                          SRAM_CE_N;
inout            [15:0]        SRAM_DQ;
output                          SRAM_LB_N;
output                          SRAM_OE_N;
output                          SRAM_UB_N;
output                          SRAM_WE_N;

//////////// GPIO, GPIO connect to D5M - 5M Pixel Camera //////////
input            [11:0]        D5M_D;
input                          D5M_FVAL;
input                          D5M_LVAL;
input                          D5M_PIXLCLK;
output                          D5M_RESET_N;
output                          D5M_SCLK;
inout                          D5M_SDATA;
input                          D5M_STROBE;
output                          D5M_TRIGGER;
output                          D5M_XCLKIN;


//=======================================================
//  REG/WIRE declarations
//=======================================================
wire    [15:0]    Read_DATA1;
wire    [15:0]    Read_DATA2;

wire    [11:0]    mCCD_DATA;
wire            mCCD_DVAL;
wire            mCCD_DVAL_d;
wire    [15:0]    X_Cont;
wire    [15:0]    Y_Cont;
wire    [9:0]    X_ADDR;
wire    [31:0]    Frame_Cont;
wire            DLY_RST_0;
wire            DLY_RST_1;
wire            DLY_RST_2;
wire            DLY_RST_3;
wire            DLY_RST_4;
wire            Read;
reg        [11:0]    rCCD_DATA;
reg                rCCD_LVAL;
reg                rCCD_FVAL;
wire    [11:0]    sCCD_R;
wire    [11:0]    sCCD_G;
wire    [11:0]    sCCD_B;
wire            sCCD_DVAL;

wire            sdram_ctrl_clk;
wire    [9:0]    oVGA_R;                   //    VGA Red[9:0]
wire    [9:0]    oVGA_G;                     //    VGA Green[9:0]
wire    [9:0]    oVGA_B;                   //    VGA Blue[9:0]
wire            Threshold;

wire    [15:0]   write_1, write_2;

//power on start
wire             auto_start;
//=======================================================
//  Structural coding
//=======================================================
// D5M
assign    D5M_TRIGGER    =    1'b1;  // tRIGGER
assign    D5M_RESET_N    =    DLY_RST_1;
assign  VGA_CTRL_CLK = ~VGA_CLK;

assign    LEDR        =    SW;
assign    LEDG        =    Y_Cont;
assign    UART_TXD = UART_RXD;

//fetch the high 8 bits
assign  VGA_R = oVGA_R[9:2];
assign  VGA_G = oVGA_G[9:2];
assign  VGA_B = oVGA_B[9:2];

//D5M read 
always@(posedge D5M_PIXLCLK)
begin
    rCCD_DATA    <=    D5M_D;
    rCCD_LVAL    <=    D5M_LVAL;
    rCCD_FVAL    <=    D5M_FVAL;
end

//auto start when power on
assign auto_start = ((KEY[0])&&(DLY_RST_3)&&(!DLY_RST_4))? 1'b1:1'b0;

//test
assign write_1 = Threshold ? {1'b0, 15'b1} : {1'b0, 15'b0};
assign write_2 = Threshold ? {1'b0, 15'b1} : {1'b0, 15'b0};

//Reset module
Reset_Delay            u2    (    .iCLK(CLOCK2_50),
                            .iRST(KEY[0]),
                            .oRST_0(DLY_RST_0),
                            .oRST_1(DLY_RST_1),
                            .oRST_2(DLY_RST_2),
                            .oRST_3(DLY_RST_3),
                            .oRST_4(DLY_RST_4)
                        );
//D5M image capture
CCD_Capture            u3    (    .oDATA(mCCD_DATA),
                            .oDVAL(mCCD_DVAL),
                            .oX_Cont(X_Cont),
                            .oY_Cont(Y_Cont),
                            .oFrame_Cont(Frame_Cont),
                            .iDATA(rCCD_DATA),
                            .iFVAL(rCCD_FVAL),
                            .iLVAL(rCCD_LVAL),
                            .iSTART(!KEY[3]|auto_start),
                            .iEND(!KEY[2]),
                            .iCLK(~D5M_PIXLCLK),
                            .iRST(DLY_RST_2)
                        );
//D5M raw date convert to RGB data
RAW2RGB                u4    (    .iCLK(D5M_PIXLCLK),
                            .iRST_n(DLY_RST_1),
                            .iData(mCCD_DATA),
                            .iDval(mCCD_DVAL),
                            .oRed(sCCD_R),
                            .oGreen(sCCD_G),
                            .oBlue(sCCD_B),
                            .oDval(sCCD_DVAL),
                            .iZoom(SW[16]),
                            .iX_Cont(X_Cont),
                            .iY_Cont(Y_Cont),
                            .oThreshold(Threshold)
                        );
//Frame count display
SEG7_LUT_8             u5    (    .oSEG0(HEX0),.oSEG1(HEX1),
                            .oSEG2(HEX2),.oSEG3(HEX3),
                            .oSEG4(HEX4),.oSEG5(HEX5),
                            .oSEG6(HEX6),.oSEG7(HEX7),
                            .iDIG(Frame_Cont[31:0])
                        );

sdram_pll             u6    (
                            .inclk0(CLOCK2_50),
                            .c0(sdram_ctrl_clk),
                            .c1(DRAM_CLK),
                            .c2(D5M_XCLKIN), //25M
                            .c4(VGA_CLK)     //40M     
                        );

//SDRam Read and Write as Frame Buffer
Sdram_Control    u7    (    //    HOST Side                        
                            .RESET_N(KEY[0]),
                            .CLK(sdram_ctrl_clk),

                            //    FIFO Write Side 1
                            .WR1_DATA(write_1), // original {1'b0,sCCD_G[11:7],sCCD_B[11:2]}
                            .WR1(sCCD_DVAL),
                            .WR1_ADDR(0),
                            .WR1_MAX_ADDR(800*600/2),
                            .WR1_LENGTH(8'h80),
                            .WR1_LOAD(!DLY_RST_0),
                            .WR1_CLK(D5M_PIXLCLK),

                            //    FIFO Write Side 2
                            .WR2_DATA(write_2), // original {1'b0,sCCD_G[6:2],sCCD_R[11:2]}
                            .WR2(sCCD_DVAL),
                            .WR2_ADDR(23'h100000),
                            .WR2_MAX_ADDR(23'h100000+800*600/2),
                            .WR2_LENGTH(8'h80),
                            .WR2_LOAD(!DLY_RST_0),
                            .WR2_CLK(D5M_PIXLCLK),

                            //    FIFO Read Side 1
                            .RD1_DATA(Read_DATA1),
                            .RD1(Read),
                            .RD1_ADDR(0),
                            .RD1_MAX_ADDR(800*600/2),
                            .RD1_LENGTH(8'h80),
                            .RD1_LOAD(!DLY_RST_0),
                            .RD1_CLK(~VGA_CTRL_CLK),
                            
                            //    FIFO Read Side 2
                            .RD2_DATA(Read_DATA2),
                            .RD2(Read),
                            .RD2_ADDR(23'h100000),
                            .RD2_MAX_ADDR(23'h100000+800*600/2),
                            .RD2_LENGTH(8'h80),
                            .RD2_LOAD(!DLY_RST_0),
                            .RD2_CLK(~VGA_CTRL_CLK),
                            
                            //    SDRAM Side
                            .SA(DRAM_ADDR),
                            .BA(DRAM_BA),
                            .CS_N(DRAM_CS_N),
                            .CKE(DRAM_CKE),
                            .RAS_N(DRAM_RAS_N),
                            .CAS_N(DRAM_CAS_N),
                            .WE_N(DRAM_WE_N),
                            .DQ(DRAM_DQ),
                            .DQM(DRAM_DQM)
                        );
//D5M I2C control
I2C_CCD_Config         u8    (    //    Host Side
                            .iCLK(CLOCK2_50),
                            .iRST_N(DLY_RST_2),
                            .iEXPOSURE_ADJ(KEY[1]),
                            .iEXPOSURE_DEC_p(SW[0]),
                            .iZOOM_MODE_SW(SW[16]),
                            //    I2C Side
                            .I2C_SCLK(D5M_SCLK),
                            .I2C_SDAT(D5M_SDATA)
                        );
//VGA DISPLAY
VGA_Controller        u1    (    //    Host Side
                            .oRequest(Read),
                            .iRed(Read_DATA2[9:0]),
                            .iGreen({Read_DATA1[14:10],Read_DATA2[14:10]}),
                            .iBlue(Read_DATA1[9:0]),
                            //    VGA Side
                            .oVGA_R(oVGA_R),
                            .oVGA_G(oVGA_G),
                            .oVGA_B(oVGA_B),
                            .oVGA_H_SYNC(VGA_HS),
                            .oVGA_V_SYNC(VGA_VS),
                            .oVGA_SYNC(VGA_SYNC_N),
                            .oVGA_BLANK(VGA_BLANK_N),
                            //    Control Signal
                            .iCLK(VGA_CTRL_CLK),
                            .iRST_N(DLY_RST_2),
                            .iZOOM_MODE_SW(SW[16])
                        );

// Image_Loader img_loader (
//                             .i_clk(),
//                             .data(),
//                             .valid(),
//                             .avm_clk(),
//                             .avm_rst_n(),
//                             .avm_address(),
//                             .avm_read(),
//                             .avm_readdata(),
//                             .avm_write(),
//                             .avm_waitrequest()
//                         );

// Sram_Contoller sram_ctrl(
//                             .i_clk(),
//                             .i_rst_n(),
//                             .i_write(),
//                             .i_read(),
//                             .o_fin(),
//                             //SRAM
//                             .o_SRAM_ADDR(),
//                             .io_SRAM_DQ(),
//                             .o_SRAM_WE_N(),
//                             .o_SRAM_CE_N(),
//                             .o_SRAM_OE_N(),
//                             .o_SRAM_LB_N(),
//                             .o_SRAM_UB_N(),
//                             //DATA
//                             .o_vaild(),
//                             .o_r_data(),
//                             .i_w_data()
// );

// Image_Generator img_gen(
//                             .i_clk(D5M_PIXLCLK),
//                             .i_rst_n(i_rst_n),
//                             .o_read(), // to sram i_read
//                             .i_sram_data()
// );


endmodule
