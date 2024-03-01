// --------------------------------------------------------------------
// Copyright (c) 20057 by Terasic Technologies Inc. 
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
// Major Functions:	RAW2RGB
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| 		Changes Made:
//   V1.0 :| Johnny Fan        :| 07/08/01  :|      Initial Revision
// --------------------------------------------------------------------
module	RAW2RGB				(	iCLK,iRST_n,
								//Read Port 1
								iData,
								iDval,
								oRed,
								oGreen,
								oBlue,
								oDval,
								iZoom,
								iX_Cont,
								iY_Cont,
								oThreshold
							);


input			iCLK,iRST_n;
input	[11:0]	iData;
input			iDval;
output	[11:0]	oRed;
output	[11:0]	oGreen;
output	[11:0]	oBlue;
output			oDval;
input	[1:0]	iZoom;
input	[15:0]	iX_Cont;
input	[15:0]	iY_Cont;
output          oThreshold;

wire	[11:0]	wData0;
wire	[11:0]	wData1;
wire	[11:0]	wData2;

reg		[11:0]	rRed;
reg		[12:0]	rGreen;
reg		[11:0]	rBlue;
reg				rDval;
reg		[11:0]	wData0_d1,wData0_d2;
reg		[11:0]	wData1_d1,wData1_d2;
reg		[11:0]	wData2_d1,wData2_d2;

reg				oDval;

reg				dval_ctrl;
reg				dval_ctrl_en;

wire    [12:0]  red_th, blue_th, green_th;
wire    [13:0]  gray;
//out
assign	oRed	=   rRed; // 0; // oThreshold ? rRed : 0;
assign	oGreen	=	rGreen[12:1]; // (rGreen[12:1] > green_th) ? rGreen[12:1] - gray + 2048 : 0;// oThreshold ? rGreen[12:1] : 0;
assign	oBlue	=	rBlue; // 0; // oThreshold ? rBlue : 0;
assign  red_th  =   gray - 0;
assign  blue_th =   gray - 0;
assign  green_th =  gray + 300;
assign  gray    =   (rRed + rBlue + rGreen) >> 2;

assign  oThreshold = ( rGreen[12:1] > green_th) ? 1 : 0; 
// assign  oThreshold = ( $signed(rGreen[12:1]) > $signed(green_th) && $signed(rRed) < $signed(red_th) && $signed(rBlue) < $signed(blue_th)) ? 1 : 0; 

Line_Buffer	L1	(
					.clken(iDval),
					.clock(iCLK),
					.shiftin(iData),
					.shiftout(),
					.taps2x(wData0),
					.taps1x(wData1),
					.taps0x(wData2)
				);

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				dval_ctrl<=0;
			end	
		else
			begin
				if(iY_Cont>1)
					begin
						dval_ctrl<=1;
					end		
				else
					begin
						dval_ctrl<=0;
					end
			end	
	end

always@(posedge dval_ctrl or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				dval_ctrl_en<=0;
			end	
		else
			begin
				dval_ctrl_en<=1;
			end	
	end


always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				rDval<=0;
				oDval <= 0;
			end	
		else
			if(dval_ctrl_en)
				begin
					rDval<=iDval;	
					oDval<=rDval;
				end
			else
				begin
					rDval<=iDval;
					oDval<=0;
				end	
	end

always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				wData0_d1<=0;
				wData0_d2<=0;
				wData1_d1<=0;
				wData1_d2<=0;
				wData2_d1<=0;
				wData2_d2<=0;				
			end
		else
			begin
				{wData0_d2,wData0_d1}<={wData0_d1,wData0};
				{wData1_d2,wData1_d1}<={wData1_d1,wData1};
				{wData2_d2,wData2_d1}<={wData2_d1,wData2};
			end
	end		
	
always@(posedge iCLK or negedge iRST_n)
	begin
		if (!iRST_n)
			begin
				rRed<=0;
				rGreen<=0;
				rBlue<=0;	
			end

		else if ({iY_Cont[0],iX_Cont[0]} == 2'b11)
			begin
				if (iY_Cont == 12'd1)
					begin
						rRed<=wData1_d1;
						rGreen<=wData0_d1+wData1;
						rBlue<=wData0;
					end		
				else
					begin
						rRed<=wData1_d1;
						rGreen<=wData1+wData2_d1;
						rBlue<=wData2;
					end
			end		
		else if ({iY_Cont[0],iX_Cont[0]} == 2'b10)
			begin
				if (iY_Cont == 12'd1)
					begin
						if (iX_Cont == 12'b0)
							begin
								rRed<=wData0_d2;
								rGreen<={wData1_d2,1'b0};
								rBlue<=wData1_d1;
							end
						else
							begin
								rRed<=wData1;
								rGreen<=wData1_d1+wData0;
								rBlue<=wData0_d1;	
							end
					end		
				else
					begin
						// for last one X pixel of the colowm process
						if (iX_Cont == 12'b0)
							begin
								rRed<=wData2_d2;
								rGreen<={wData2_d1,1'b0};
								rBlue<=wData1_d1;
							end
						// normal X pixel of the colowm process
						else
							begin
								rRed<=wData1;
								rGreen<=wData1_d1+wData2;
								rBlue<=wData2_d1;	
							end	
					end	
			end		
		else if ({iY_Cont[0],iX_Cont[0]} == 2'b01)
			begin
				rRed<=wData2_d1;
				rGreen<=wData2+wData1_d1;
				rBlue<=wData1;		
			end	

		else if ({iY_Cont[0],iX_Cont[0]} == 2'b00)
			begin
				if (iX_Cont == 12'b0)
					begin
						rRed<=wData1_d2;
						rGreen<={wData2_d2,1'b0};
						rBlue<=wData2_d1;
					end
				// normal X of the colowm process
				
				else
					begin
						rRed<=wData2;
						rGreen<=wData2_d1+wData1;
						rBlue<=wData1_d1;	
					end	
			end	
	end


endmodule