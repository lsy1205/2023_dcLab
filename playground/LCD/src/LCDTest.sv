module LCD_top(
    CLOCK_50,                   //    50 MHz
    i_rst_n,
    LCD_ON,                     //    LCD Power ON/OFF
    LCD_BLON,                   //    LCD Back Light ON/OFF
    LCD_RW,                     //    LCD Read/Write Select, 0 = Write, 1 = Read
    LCD_EN,                     //    LCD Enable
    LCD_RS,                     //    LCD Command/Data Select, 0 = Command, 1 = Data
    LCD_DATA                    //    LCD Data bus 8 bits
);

input             CLOCK_50;     //    50 MHz
input             i_rst_n;
inout    [7:0]    LCD_DATA;     //    LCD Data bus 8 bits
output            LCD_ON;       //    LCD Power ON/OFF
output            LCD_BLON;     //    LCD Back Light ON/OFF
output            LCD_RW;       //    LCD Read/Write Select, 0 = Write, 1 = Read
output            LCD_EN;       //    LCD Enable
output            LCD_RS;       //    LCD Command/Data Select, 0 = Command, 1 = Data

//    LCD ON
assign    LCD_ON      =    1'b1;
assign    LCD_BLON    =    1'b0;
 
wire        DLY_RST;
 
Reset_Delay r0(
    .iCLK(CLOCK_50),
    .i_rst_n(i_rst_n),
    .oRESET(DLY_RST)
);
 
LCD_TEST u5(    
    //    Host Side
    .iCLK(CLOCK_50),
    .iRST_N(DLY_RST),
    //    LCD Side
    .LCD_DATA(LCD_DATA),
    .LCD_RW(LCD_RW),
    .LCD_EN(LCD_EN),
    .LCD_RS(LCD_RS)
);
 
endmodule                


module LCD_TEST (    
    //    Host Side
    iCLK,iRST_N,
    //    LCD Side
    LCD_DATA,LCD_RW,LCD_EN,LCD_RS    
);

//    Host Side
input            iCLK,iRST_N;
//    LCD Side
output    [7:0]   LCD_DATA;
output            LCD_RW,LCD_EN,LCD_RS;
//    Internal Wires/Registers
reg     [5:0]    LUT_INDEX;
reg     [8:0]    LUT_DATA;
reg     [5:0]    mLCD_ST;
reg    [17:0]    mDLY;
reg              mLCD_Start;
reg     [7:0]    mLCD_DATA;
reg              mLCD_RS;
wire             mLCD_Done;
  
parameter    LCD_INTIAL    =    0;
parameter    LCD_LINE1    =    5;
parameter    LCD_CH_LINE    =    LCD_LINE1+16;
parameter    LCD_LINE2    =    LCD_LINE1+16+1;
parameter    LUT_SIZE    =    LCD_LINE1+32+1 -16;
  
always@(posedge iCLK or negedge iRST_N) begin
    if(!iRST_N)
    begin
        LUT_INDEX    <=    0;
        mLCD_ST        <=    0;
        mDLY        <=    0;
        mLCD_Start    <=    0;
        mLCD_DATA    <=    0;
        mLCD_RS        <=    0;
    end
    else
    begin
        if(LUT_INDEX<LUT_SIZE)
        begin
            case(mLCD_ST)
            0: begin
                mLCD_DATA  <= LUT_DATA[7:0];
                mLCD_RS    <= LUT_DATA[8];
                mLCD_Start <= 1;
                mLCD_ST    <= 1;
            end
            1: begin
                if(mLCD_Done)
                begin
                    mLCD_Start <= 0;
                    mLCD_ST    <= 2;                    
                end
            end
            2: begin
                if(mDLY<18'h3FFFE)    // 5.2ms
                mDLY <= mDLY+1;
                else
                begin
                    mDLY    <= 0;
                    mLCD_ST <= 3;
                end
            end
            3: begin
                LUT_INDEX <= LUT_INDEX+1;
                mLCD_ST   <= 0;
            end
            endcase
          end
      end
  end
  
  always@(*)
  begin
    case(LUT_INDEX)
    //    Initial
    LCD_INTIAL+0:    LUT_DATA    <=    9'h038; //Fun set
    LCD_INTIAL+1:    LUT_DATA    <=    9'h00F; //dis on
    LCD_INTIAL+2:    LUT_DATA    <=    9'h001; //clr dis
    LCD_INTIAL+3:    LUT_DATA    <=    9'h006; //Ent mode
    LCD_INTIAL+4:    LUT_DATA    <=    9'h080; //set ddram address
    //    Line 1
    LCD_LINE1+0:     LUT_DATA    <=    9'h120;    //    http://halflife.cnblogs.com
    LCD_LINE1+1:     LUT_DATA    <=    9'h168; // h
    LCD_LINE1+2:     LUT_DATA    <=    9'h174; // t
    LCD_LINE1+3:     LUT_DATA    <=    9'h174; // t
    LCD_LINE1+4:     LUT_DATA    <=    9'h170; // p
    LCD_LINE1+5:     LUT_DATA    <=    9'h13A; // :
    LCD_LINE1+6:     LUT_DATA    <=    9'h12F; // /
    LCD_LINE1+7:     LUT_DATA    <=    9'h12F; // /
    LCD_LINE1+8:     LUT_DATA    <=    9'h168; // h
    LCD_LINE1+9:     LUT_DATA    <=    9'h161; // a
    LCD_LINE1+10:    LUT_DATA    <=    9'h16C; // l
    LCD_LINE1+11:    LUT_DATA    <=    9'h166; // f
    LCD_LINE1+12:    LUT_DATA    <=    9'h16C; // l
    LCD_LINE1+13:    LUT_DATA    <=    9'h169; // i
    LCD_LINE1+14:    LUT_DATA    <=    9'h166; // f
    LCD_LINE1+15:    LUT_DATA    <=    9'h165; // e
    //    Change Line
    LCD_CH_LINE:     LUT_DATA    <=    9'h0C1;
    //    Line 2
    LCD_LINE2+0:     LUT_DATA    <=    9'h12E;    // .
    LCD_LINE2+1:     LUT_DATA    <=    9'h163; // c
    LCD_LINE2+2:     LUT_DATA    <=    9'h16E; // n
    LCD_LINE2+3:     LUT_DATA    <=    9'h162; // b
    LCD_LINE2+4:     LUT_DATA    <=    9'h16C; // l
    LCD_LINE2+5:     LUT_DATA    <=    9'h16F; // o
    LCD_LINE2+6:     LUT_DATA    <=    9'h167; // g
    LCD_LINE2+7:     LUT_DATA    <=    9'h173; // s
    LCD_LINE2+8:     LUT_DATA    <=    9'h12E; // .
    LCD_LINE2+9:     LUT_DATA    <=    9'h163; // c
    LCD_LINE2+10:    LUT_DATA    <=    9'h16F; // o
    LCD_LINE2+11:    LUT_DATA    <=    9'h16D; // m
    LCD_LINE2+12:    LUT_DATA    <=    9'h120;
    LCD_LINE2+13:    LUT_DATA    <=    9'h120;
    LCD_LINE2+14:    LUT_DATA    <=    9'h120;
    LCD_LINE2+15:    LUT_DATA    <=    9'h120;
    default:         LUT_DATA    <=    9'h000;
    endcase
end

LCD_Controller  u0( 
    //    Host Side
    .iDATA(mLCD_DATA),
    .iRS(mLCD_RS),
    .iStart(mLCD_Start),
    .oDone(mLCD_Done),
    .iCLK(iCLK),
    .iRST_N(iRST_N),
    //    LCD Interface
    .LCD_DATA(LCD_DATA),
    .LCD_RW(LCD_RW),
    .LCD_EN(LCD_EN),
    .LCD_RS(LCD_RS)    
);
endmodule

module LCD_Controller (    //    Host Side
                        iDATA,iRS,
                        iStart,oDone,
                        iCLK,iRST_N,
                        //    LCD Interface
                        LCD_DATA,
                        LCD_RW,
                        LCD_EN,
                        LCD_RS    );
//    CLK
parameter    CLK_Divide    =    16;

//    Host Side
input    [7:0]    iDATA;
input    iRS,iStart;
input    iCLK,iRST_N;
output    reg        oDone;
//    LCD Interface
output    [7:0]    LCD_DATA;
output    reg        LCD_EN;
output            LCD_RW;
output            LCD_RS;
//    Internal Register
reg        [4:0]    Cont;
reg        [1:0]    ST;
reg        preStart,mStart;

/////////////////////////////////////////////
//    Only write to LCD, bypass iRS to LCD_RS
assign    LCD_DATA    =    iDATA; 
assign    LCD_RW        =    1'b0;
assign    LCD_RS        =    iRS;
/////////////////////////////////////////////

always@(posedge iCLK or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        oDone    <=    1'b0;
        LCD_EN    <=    1'b0;
        preStart<=    1'b0;
        mStart    <=    1'b0;
        Cont    <=    0;
        ST        <=    0;
    end
    else
    begin
        //////    Input Start Detect ///////
        preStart<=    iStart;
        if({preStart,iStart}==2'b01)  // latch ?
        begin
            mStart    <=    1'b1;
            oDone    <=    1'b0;
        end
        //////////////////////////////////
        if(mStart)  //generate LCD_EN
        begin
            case(ST)
            0:    ST    <=    1;    //    Wait Setup, tAS >= 40ns
            1:    begin
                    LCD_EN    <=    1'b1;
                    ST        <=    2;
                end
            2:    begin                    
                    if(Cont<CLK_Divide)
                    Cont    <=    Cont+1;
                    else
                    ST        <=    3;
                end
            3:    begin
                    LCD_EN    <=    1'b0;
                    mStart    <=    1'b0;
                    oDone    <=    1'b1;
                    Cont    <=    0;
                    ST        <=    0;
                end
            endcase
        end
    end
end

endmodule

module Reset_Delay(
    iCLK,
    i_rst_n,
    oRESET
);

input         iCLK;
input         i_rst_n;
output reg    oRESET;
reg    [19:0] Cont;

always@(posedge iCLK or negedge i_rst_n)
begin
    if(!i_rst_n)
        Cont <= 0;
    else if(Cont!=20'hFFFFF)   //21ms
    begin
        Cont    <=    Cont+1;
        oRESET  <=    1'b0;
    end
    else
    oRESET    <=    1'b1;
end

endmodule
