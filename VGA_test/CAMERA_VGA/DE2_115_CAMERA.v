// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	DE2_115 D5M+VGA 640*480 800*600 solution
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny FAN Peli Li:| 22/07/2010:| Initial Revision
// --------------------------------------------------------------------
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================
//to set the VGA solution
`include "VGA_Param.h" 

module DE2_115_CAMERA(

	//////////// CLOCK //////////
	CLOCK_50,
	CLOCK2_50,
	CLOCK3_50,

	//////////// Sma //////////
	SMA_CLKIN,
	SMA_CLKOUT,

	//////////// LED //////////
	LEDG,
	LEDR,

	//////////// KEY //////////
	KEY,

	//////////// EJTAG //////////
	EX_IO,

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

	//////////// PS2 for Keyboard and Mouse //////////
	PS2_CLK,
	PS2_CLK2,
	PS2_DAT,
	PS2_DAT2,

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

	//////////// I2C for EEPROM //////////
	EEP_I2C_SCLK,
	EEP_I2C_SDAT,

	//////////// I2C for Audio Tv-Decoder  //////////
	I2C_SCLK,
	I2C_SDAT,

	//////////// Ethernet 0 //////////
	ENET0_GTX_CLK,
	ENET0_INT_N,
	ENET0_LINK100,
	ENET0_MDC,
	ENET0_MDIO,
	ENET0_RST_N,
	ENET0_RX_CLK,
	ENET0_RX_COL,
	ENET0_RX_CRS,
	ENET0_RX_DATA,
	ENET0_RX_DV,
	ENET0_RX_ER,
	ENET0_TX_CLK,
	ENET0_TX_DATA,
	ENET0_TX_EN,
	ENET0_TX_ER,
	ENETCLK_25,

	//////////// Ethernet 1 //////////
	ENET1_GTX_CLK,
	ENET1_INT_N,
	ENET1_LINK100,
	ENET1_MDC,
	ENET1_MDIO,
	ENET1_RST_N,
	ENET1_RX_CLK,
	ENET1_RX_COL,
	ENET1_RX_CRS,
	ENET1_RX_DATA,
	ENET1_RX_DV,
	ENET1_RX_ER,
	ENET1_TX_CLK,
	ENET1_TX_DATA,
	ENET1_TX_EN,
	ENET1_TX_ER,

	//////////// TV Decoder //////////
	TD_CLK27,
	TD_DATA,
	TD_HS,
	TD_RESET_N,
	TD_VS,

	//////////// USB 2.0 OTG //////////
	OTG_ADDR,
	OTG_CS_N,
	OTG_DACK_N,
	OTG_DATA,
	OTG_DREQ,
	OTG_FSPEED,
	OTG_INT,
	OTG_LSPEED,
	OTG_RD_N,
	OTG_RST_N,
	OTG_WE_N,

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

	//////////// Flash //////////
	FL_ADDR,
	FL_CE_N,
	FL_DQ,
	FL_OE_N,
	FL_RST_N,
	FL_RY,
	FL_WE_N,
	FL_WP_N,

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

//////////// CLOCK //////////
input		          		CLOCK_50;
input		          		CLOCK2_50;
input		          		CLOCK3_50;

//////////// Sma //////////
input		          		SMA_CLKIN;
output		          		SMA_CLKOUT;

//////////// LED //////////
output		     [8:0]		LEDG;
output		    [17:0]		LEDR;

//////////// KEY //////////
input		     [3:0]		KEY;

//////////// EJTAG //////////
inout		     [6:0]		EX_IO;

//////////// SW //////////
input		    [17:0]		SW;

//////////// SEG7 //////////
output		     [6:0]		HEX0;
output		     [6:0]		HEX1;
output		     [6:0]		HEX2;
output		     [6:0]		HEX3;
output		     [6:0]		HEX4;
output		     [6:0]		HEX5;
output		     [6:0]		HEX6;
output		     [6:0]		HEX7;

//////////// LCD //////////
output		          		LCD_BLON;
inout		     [7:0]		LCD_DATA;
output		          		LCD_EN;
output		          		LCD_ON;
output		          		LCD_RS;
output		          		LCD_RW;

//////////// RS232 //////////
output		          		UART_CTS;
input		          		UART_RTS;
input		          		UART_RXD;
output		          		UART_TXD;

//////////// PS2 for Keyboard and Mouse //////////
inout		          		PS2_CLK;
inout		          		PS2_CLK2;
inout		          		PS2_DAT;
inout		          		PS2_DAT2;

//////////// SDCARD //////////
output		          		SD_CLK;
inout		          		SD_CMD;
inout		     [3:0]		SD_DAT;
input		          		SD_WP_N;

//////////// VGA //////////
output		     [7:0]		VGA_B;
output		          		VGA_BLANK_N;
output		          		VGA_CLK;
output		     [7:0]		VGA_G;
output		          		VGA_HS;
output		     [7:0]		VGA_R;
output		          		VGA_SYNC_N;
output		          		VGA_VS;

//////////// Audio //////////
input		          		AUD_ADCDAT;
inout		          		AUD_ADCLRCK;
inout		          		AUD_BCLK;
output		          		AUD_DACDAT;
inout		          		AUD_DACLRCK;
output		          		AUD_XCK;

//////////// I2C for EEPROM //////////
output		          		EEP_I2C_SCLK;
inout		          		EEP_I2C_SDAT;

//////////// I2C for Audio Tv-Decoder  //////////
output		          		I2C_SCLK;
inout		          		I2C_SDAT;

//////////// Ethernet 0 //////////
output		          		ENET0_GTX_CLK;
input		          		ENET0_INT_N;
input		          		ENET0_LINK100;
output		          		ENET0_MDC;
inout		          		ENET0_MDIO;
output		          		ENET0_RST_N;
input		          		ENET0_RX_CLK;
input		          		ENET0_RX_COL;
input		          		ENET0_RX_CRS;
input		     [3:0]		ENET0_RX_DATA;
input		          		ENET0_RX_DV;
input		          		ENET0_RX_ER;
input		          		ENET0_TX_CLK;
output		     [3:0]		ENET0_TX_DATA;
output		          		ENET0_TX_EN;
output		          		ENET0_TX_ER;
input		          		ENETCLK_25;

//////////// Ethernet 1 //////////
output		          		ENET1_GTX_CLK;
input		          		ENET1_INT_N;
input		          		ENET1_LINK100;
output		          		ENET1_MDC;
inout		          		ENET1_MDIO;
output		          		ENET1_RST_N;
input		          		ENET1_RX_CLK;
input		          		ENET1_RX_COL;
input		          		ENET1_RX_CRS;
input		     [3:0]		ENET1_RX_DATA;
input		          		ENET1_RX_DV;
input		          		ENET1_RX_ER;
input		          		ENET1_TX_CLK;
output		     [3:0]		ENET1_TX_DATA;
output		          		ENET1_TX_EN;
output		          		ENET1_TX_ER;

//////////// TV Decoder //////////
input		          		TD_CLK27;
input		     [7:0]		TD_DATA;
input		          		TD_HS;
output		          		TD_RESET_N;
input		          		TD_VS;

//////////// USB 2.0 OTG //////////
output		     [1:0]		OTG_ADDR;
output		          		OTG_CS_N;
output		     [1:0]		OTG_DACK_N;
inout		    [15:0]		OTG_DATA;
input		     [1:0]		OTG_DREQ;
inout		          		OTG_FSPEED;
input		     [1:0]		OTG_INT;
inout		          		OTG_LSPEED;
output		          		OTG_RD_N;
output		          		OTG_RST_N;
output		          		OTG_WE_N;

//////////// IR Receiver //////////
input		          		IRDA_RXD;

//////////// SDRAM //////////
output		    [12:0]		DRAM_ADDR;
output		     [1:0]		DRAM_BA;
output		          		DRAM_CAS_N;
output		          		DRAM_CKE;
output		          		DRAM_CLK;
output		          		DRAM_CS_N;
inout		    [31:0]		DRAM_DQ;
output		     [3:0]		DRAM_DQM;
output		          		DRAM_RAS_N;
output		          		DRAM_WE_N;

//////////// SRAM //////////
output		    [19:0]		SRAM_ADDR;
output		          		SRAM_CE_N;
inout		    [15:0]		SRAM_DQ;
output		          		SRAM_LB_N;
output		          		SRAM_OE_N;
output		          		SRAM_UB_N;
output		          		SRAM_WE_N;

//////////// Flash //////////
output		    [22:0]		FL_ADDR;
output		          		FL_CE_N;
inout		     [7:0]		FL_DQ;
output		          		FL_OE_N;
output		          		FL_RST_N;
input		          		FL_RY;
output		          		FL_WE_N;
output		          		FL_WP_N;

//////////// GPIO, GPIO connect to D5M - 5M Pixel Camera //////////
input		    [11:0]		D5M_D;
input		          		D5M_FVAL;
input		          		D5M_LVAL;
input		          		D5M_PIXLCLK;
output		          		D5M_RESET_N;
output		          		D5M_SCLK;
inout		          		D5M_SDATA;
input		          		D5M_STROBE;
output		          		D5M_TRIGGER;
output		          		D5M_XCLKIN;


//=======================================================
//  REG/WIRE declarations
//=======================================================
wire	[15:0]	Read_DATA1;
wire	[15:0]	Read_DATA2;

wire	[11:0]	mCCD_DATA;
wire			mCCD_DVAL;
wire			mCCD_DVAL_d;
wire	[15:0]	X_Cont;
wire	[15:0]	Y_Cont;
wire	[9:0]	X_ADDR;
wire	[31:0]	Frame_Cont;
wire			DLY_RST_0;
wire			DLY_RST_1;
wire			DLY_RST_2;
wire			DLY_RST_3;
wire			DLY_RST_4;
wire			Read;
reg		[11:0]	rCCD_DATA;
reg				rCCD_LVAL;
reg				rCCD_FVAL;
wire	[11:0]	sCCD_R;
wire	[11:0]	sCCD_G;
wire	[11:0]	sCCD_B;
wire			sCCD_DVAL;

wire			sdram_ctrl_clk;
wire	[9:0]	oVGA_R;   				//	VGA Red[9:0]
wire	[9:0]	oVGA_G;	 				//	VGA Green[9:0]
wire	[9:0]	oVGA_B;   				//	VGA Blue[9:0]

wire            Threshold;
wire    [15:0]  write_1, write_2;
wire            gen_valid;
wire    [31:0]  gen_data;
wire            medi, medi_val;
wire            corner_val;
wire    [19:0]  ul_addr, ur_addr, dl_addr, dr_addr;
wire            corner_found;
wire            gen_fin;
wire            gen_ack;
wire    [15:0]  test;
wire            test_bit;
wire    [15:0]  test_data;
wire            test_rd_use;
wire            sram_wr_full;
wire    [23:0]  loader_data;
wire            loader_valid;
wire    [23:0]  image_data;
wire    [13:0]  image_addr;
wire            test_line;
wire            test_line2;
wire            test_line3;
wire            gen_read;
wire            frame_valid;
reg             led1, led2;

//power on start
wire             auto_start;
//=======================================================
//  Structural coding
//=======================================================
// D5M
assign	D5M_TRIGGER	=	1'b1;  // tRIGGER
assign	D5M_RESET_N	=	DLY_RST_1;
assign  VGA_CTRL_CLK = ~VGA_CLK;
assign  LEDR[13:0]        = image_addr;
// assign  LEDR[15]    = test_line2;
// assign  LEDR[16]    = test_line3;
assign  LEDR[15]    = led1;
assign  LEDR[16]    = led2;
// assign	LEDR		=	SW;
// assign	LEDG		=	Y_Cont;
assign  LEDG[0] = test_data[0];
assign  LEDG[1] = test_rd_use;
assign  LEDG[2] = sram_wr_full;
assign  LEDG[3] = test_line;
// assign  LEDG[3] = UART_RXD;
// assign  LEDG[4] = UART_TXD;
// assign	UART_TXD = UART_RXD;

//fetch the high 8 bits
assign  VGA_R = oVGA_R[9:2];
assign  VGA_G = oVGA_G[9:2];
assign  VGA_B = oVGA_B[9:2];

assign write_1 = medi ? 16'h7fff : 16'b0;
assign write_2 = medi ? 16'h7fff : 16'b0;
assign test = test_bit ? 16'h7fff : 16'b0;

//D5M read 
always@(posedge D5M_PIXLCLK)
begin
	rCCD_DATA	<=	D5M_D;
	rCCD_LVAL	<=	D5M_LVAL;
	rCCD_FVAL	<=	D5M_FVAL;
end

//auto start when power on
assign auto_start = ((KEY[0])&&(DLY_RST_3)&&(!DLY_RST_4))? 1'b1:1'b0;
//Reset module
Reset_Delay			u2	(	.iCLK(CLOCK2_50),
							.iRST(KEY[0]),
							.oRST_0(DLY_RST_0),
							.oRST_1(DLY_RST_1),
							.oRST_2(DLY_RST_2),
							.oRST_3(DLY_RST_3),
							.oRST_4(DLY_RST_4)
						);
//D5M image capture
CCD_Capture			u3	(	.oDATA(mCCD_DATA),
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
`ifdef VGA_640x480p60
RAW2RGB				u4	(	.iCLK(D5M_PIXLCLK),
							.iRST(DLY_RST_1),
							.iDATA(mCCD_DATA),
							.iDVAL(mCCD_DVAL),
							.oRed(sCCD_R),
							.oGreen(sCCD_G),
							.oBlue(sCCD_B),
							.oDVAL(sCCD_DVAL),
							.iX_Cont(X_Cont),
							.iY_Cont(Y_Cont),
							.oThreshold(Threshold)
						);
`else
RAW2RGB				u4	(	.iCLK(D5M_PIXLCLK),
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
`endif
//Frame count display
SEG7_LUT_8 			u5	(	.oSEG0(HEX0),.oSEG1(HEX1),
							.oSEG2(HEX2),.oSEG3(HEX3),
							.oSEG4(HEX4),.oSEG5(HEX5),
							.oSEG6(HEX6),.oSEG7(HEX7),
							.iDIG(Frame_Cont[31:0])
						);

sdram_pll 			u6	(
							.inclk0(CLOCK2_50),
							.c0(sdram_ctrl_clk),
							.c1(DRAM_CLK),
							.c2(D5M_XCLKIN), //25M
`ifdef VGA_640x480p60
							.c3(VGA_CLK)     //25M 
`else
						    .c4(VGA_CLK)     //40M 	
`endif
						);

//SDRam Read and Write as Frame Buffer
Sdram_Control	u7	(	//	HOST Side						
						    .RESET_N(KEY[0]),
							.CLK(sdram_ctrl_clk),

							//	FIFO Write Side 1
							.WR1_DATA({1'b0,sCCD_G[11:7],sCCD_B[11:2]}),
							// .WR1_DATA({1'b0, gen_data[19:15], gen_data[9:0]}), // {1'b0,sCCD_G[11:7],sCCD_B[11:2]}
							// .WR1_DATA(write_1),
							// .WR1(gen_valid),
							.WR1(sCCD_DVAL),
							// .WR1(medi_val),
							.WR1_ADDR(0),
`ifdef VGA_640x480p60
						    .WR1_MAX_ADDR(640*480/2),
						    .WR1_LENGTH(8'h50),
`else
							.WR1_MAX_ADDR(800*600/2),
							.WR1_LENGTH(8'h80),
`endif							
							.WR1_LOAD(!DLY_RST_0),
							.WR1_CLK(D5M_PIXLCLK),

							//	FIFO Write Side 2
							.WR2_DATA({1'b0,sCCD_G[6:2],sCCD_R[11:2]}),
							// .WR2_DATA({1'b0, gen_data[14:10], gen_data[29:20]}), // {1'b0,sCCD_G[6:2],sCCD_R[11:2]}
							// .WR2_DATA(write_2),
							// .WR2(gen_valid),
							.WR2(sCCD_DVAL),
							// .WR2(medi_val),
							.WR2_ADDR(23'h100000),
`ifdef VGA_640x480p60
						    .WR2_MAX_ADDR(23'h100000+640*480/2),
							.WR2_LENGTH(8'h50),
`else							
							.WR2_MAX_ADDR(23'h100000+800*600/2),
							.WR2_LENGTH(8'h80),
`endif	
							.WR2_LOAD(!DLY_RST_0),
							.WR2_CLK(D5M_PIXLCLK),

							//	FIFO Read Side 1
						    .RD1_DATA(Read_DATA1),
				        	// .RD1(Read),
				        	.RD1(gen_read),
				        	.RD1_ADDR(0),
`ifdef VGA_640x480p60
						    .RD1_MAX_ADDR(640*480/2),
							.RD1_LENGTH(8'h50),
`else
							.RD1_MAX_ADDR(800*600/2),
							// .RD1_LENGTH(8'h20),
							.RD1_LENGTH(8'h40),
`endif
							.RD1_LOAD(!DLY_RST_0),
							// .RD1_CLK(~VGA_CTRL_CLK),
							.RD1_CLK(CLOCK2_50),
							
							//	FIFO Read Side 2
						    .RD2_DATA(Read_DATA2),
				        	// .RD2(Read),
							.RD2(gen_read),
							.RD2_ADDR(23'h100000),
`ifdef VGA_640x480p60
						    .RD2_MAX_ADDR(23'h100000+640*480/2),
							.RD2_LENGTH(8'h50),
`else
							.RD2_MAX_ADDR(23'h100000+800*600/2),
							// .RD2_LENGTH(8'h20),
							.RD2_LENGTH(8'h40),
`endif
				        	.RD2_LOAD(!DLY_RST_0),
							// .RD2_CLK(~VGA_CTRL_CLK),
							.RD2_CLK(CLOCK2_50),
							
							//	SDRAM Side
						    .SA(DRAM_ADDR),
							.BA(DRAM_BA),
							.CS_N(DRAM_CS_N),
							.CKE(DRAM_CKE),
							.RAS_N(DRAM_RAS_N),
							.CAS_N(DRAM_CAS_N),
							.WE_N(DRAM_WE_N),
							.DQ(DRAM_DQ),
							.DQM(DRAM_DQM),
							.test1(test_line2),
							.test2(test_line3)
						);
//D5M I2C control
I2C_CCD_Config 		u8	(	//	Host Side
							.iCLK(CLOCK2_50),
							.iRST_N(DLY_RST_2),
							.iEXPOSURE_ADJ(KEY[1]),
							.iEXPOSURE_DEC_p(SW[0]),
							.iZOOM_MODE_SW(SW[16]),
							//	I2C Side
							.I2C_SCLK(D5M_SCLK),
							.I2C_SDAT(D5M_SDATA)
						);
//VGA DISPLAY
VGA_Controller		u1	(	//	Host Side
							.oRequest(Read),
							// .iRed(Read_DATA2[9:0]),
							// .iGreen({Read_DATA1[14:10],Read_DATA2[14:10]}),
							// .iBlue(Read_DATA1[9:0]),
							.iRed({test_data[15:11], 5'h0}),
							.iGreen({test_data[10:5], 4'h0}),
							.iBlue({test_data[4:0], 5'h0}),
							//	VGA Side
							.oVGA_R(oVGA_R),
							.oVGA_G(oVGA_G),
							.oVGA_B(oVGA_B),
							.oVGA_H_SYNC(VGA_HS),
							.oVGA_V_SYNC(VGA_VS),
							.oVGA_SYNC(VGA_SYNC_N),
							.oVGA_BLANK(VGA_BLANK_N),
							//	Control Signal
							.iCLK(VGA_CTRL_CLK),
							.iRST_N(DLY_RST_2),
							.iZOOM_MODE_SW(SW[16])
						);

Image_Generator     img_gen (
							.i_clk(CLOCK2_50),
							.i_rst_n(DLY_RST_1),
							.i_enable(corner_found),
							.i_pause(sram_wr_full),
							.i_addr_valid(corner_val),
							.i_ul_addr(ul_addr),
							.i_ur_addr(ur_addr),
							.i_dl_addr(dl_addr),
							.i_dr_addr(dr_addr),
							.o_req_cam_data(gen_read),
							.i_cam_data({2'b0, Read_DATA2[9:0], Read_DATA1[14:10], Read_DATA2[14:10], Read_DATA1[9:0]}),
							.o_vaild(gen_valid),
							.o_data(gen_data),
							.i_img_data(image_data),
							.o_req_addr(image_addr),

							.frame_valid(frame_valid)
);

Median_Filter       medium_filter (
							.i_clk(D5M_PIXLCLK),
							.i_rst_n(DLY_RST_1),
							.i_valid(sCCD_DVAL),
							.i_data(Threshold),
							.o_valid(medi_val),
							.o_data(medi)
);

Corner_Finder       corner_finder (
							.i_clk(D5M_PIXLCLK),
							.i_rst_n(DLY_RST_1),
							.i_valid(medi_val),
							.i_data(medi),
							.o_valid(corner_val),
							.o_success(corner_found),
							.o_ul_addr(ul_addr),
							.o_ur_addr(ur_addr),
							.o_dl_addr(dl_addr),
							.o_dr_addr(dr_addr),
);

Sram_Contoller      sram_control (
							.i_clk(sdram_ctrl_clk),
							.i_rst_n(DLY_RST_1),

							.wr_data({gen_data[29:25], gen_data[19:14], gen_data[9:5]}),
							.wr_request(gen_valid),
							.wr_clk(CLOCK2_50),

							.rd_data(test_data),
							.rd_request(Read),
							.rd_clk(~VGA_CTRL_CLK),

							.o_SRAM_ADDR(SRAM_ADDR),
							.io_SRAM_DQ(SRAM_DQ),
							.o_SRAM_WE_N(SRAM_WE_N),
							.o_SRAM_CE_N(SRAM_CE_N),
							.o_SRAM_OE_N(SRAM_OE_N),
							.o_SRAM_LB_N(SRAM_LB_N),
							.o_SRAM_UB_N(SRAM_UB_N),

							.o_rd_use(test_rd_use),
							.o_wr_use(sram_wr_full)
);

Image_Controller    image_controller (
							.i_clk(CLOCK2_50),
							.i_rst_n(DLY_RST_2),
							.wen(loader_valid),
							.i_data(loader_data),
							.i_address(image_addr),
							.o_data(image_data)
);

// Image_Loader_Wrapper        image_loader_wrapper (
// 	                        .clk_clk(CLOCK3_50),                        //                        clk.clk
// 	                        .image_loader_wrapper_i_clk(CLOCK3_50),               //                 img_loader.i_clk
// 	                        .image_loader_wrapper_data(loader_data),                //                           .data
// 	                        .image_loader_wrapper_valid(loader_valid),               //                           .valid
// 	                        .reset_reset_n(DLY_RST_2),                  //                      reset.reset_n
// 	                        .uart_0_external_connection_rxd(UART_RXD), // uart_0_external_connection.rxd
// 	                        .uart_0_external_connection_txd(UART_TXD)  //                           .txd
// );

test                 test_0 (
		                .clk_clk(CLOCK2_50),                         //                        clk.clk
		                .reset_reset_n(DLY_RST_2),                   //                      reset.reset_n
		                .test_loader_0_conduit_end_name(),  //  test_loader_0_conduit_end.name
		                .test_loader_0_conduit_end_data(loader_data),  //                           .data
		                .test_loader_0_conduit_end_valid(loader_valid), //                           .valid
		                .uart_0_external_connection_rxd(UART_RXD),  // uart_0_external_connection.rxd
		                .uart_0_external_connection_txd(UART_TXD)   //                           .txd
	);

// GetPerspective get_perspective (
//     .i_clk(D5M_PIXLCLK),
//     .i_rst_n(DLY_RST_1),
//     .i_start(corner_valid && corner_found),
// 	.i_ul_addr({ul_addr[9:0], ul_addr[19:10]}), // first 10 bit is x, last is y()
// 	.i_ur_addr({ur_addr[9:0], ur_addr[19:10]}),
// 	.i_dr_addr({dr_addr[9:0], dr_addr[19:10]}),
// 	.i_dl_addr({dl_addr[9:0], dl_addr[19:10]}),
// 	.A(),
// 	.B(),
// 	.C(),
// 	.D(),
// 	.E(),
// 	.F(),
// 	.G(),
// 	.H(),
// 	.o_valid()
// );

always @(*) begin
	led1 = 0;
	led2 = 0;
	if (test_line3 || led2) begin
		led2 = 1;
	end
	if (test_line2 || led1) begin
		led1 = 1;
	end
	if (frame_valid) begin
		led1 = 0;
		led2 = 0;
	end
end

endmodule
