# Project

## Camera

### Timing

* $t_{ROW} = 2 \times (width + 312) \times t_{PIXCLK} = 1424 \times t_{PIXCLK} = 28480 \mu s$
* $SW = 1984, (>0, <65536)$
* $t_{FRAME} = max(H + VB, SW + 1) \times t_{ROW} = 56.5 ms$
* $fps = 1 / t_{FRAME} = 17.7$

## Memory

* CLK = 100 MHz
* SDRAM: working memory
  * Camera (write)
    * 2x800x600x24 bit = 960,000x24 bit
    * 480,000x30 Hz = 14 MHz
  * Img Generator (read)
    * 480,000x30 Hz = 14 MHz
  * Preload image (random read)
    * 100x100x24 bit = 10,000x24 bit
    * 14 MHz
* SRAM: graphical memory
  * VGA (read)
    * 2x800x600x16 bit = 960,000x16 bit
    * 480,000x60 Hz = 28.8 MHz
  * Img Generator (write)
    * 480,000x30 Hz = 14 MHz
  * Binary image (read/write) (suspended)
    * 800x600x1 bit = 30,000x16 bit
    * 2x30,000x15 Hz = 0.9 MHz

## Data Format

* RGB888: SDRAM
* Differential RGB565: SRAM
  * Padding $(127, 127, 127)$
  * $Diff = ori[i][j] - recon[i][j]$
  * $DR[4:0] = Diff[0][6:2]$
  * $DG[5:0] = Diff[1][6:1]$
  * $DB[4:0] = Diff[2][6:2]$
* [Deprecated] RGBGray8888: SDRAM
  * $G = (G_1+G_2) / 2$

## Green Square
* threshold 
  * $gray = (R+G_1+G_2+B) / 4$
  * green = $gray + 300$
  * red = $gray$
  * blue = $gray$
* threshold on B channel to extract the rectangle

## Image Generator
* i_data = {8'b0, R, G, B}

## VGA

* Clock: 40 MHz
* get data when oRequest is high

## FIFO Size

* SRAM to VGA:
  * VGA requires 800 pixels per 26.4 us
  * SRAM can give 800 pixels in 16 us
  * FIFO size decided by SRAM work load
  <!-- * FIFO Size >= 134 pixels -> choose 256 pixels (256 * 3 * 8 = 6144 bits)  -->

## Average filter

* unprocessed gray pixel store in SRAM
* averaged gray pixel store in SDRAM
* $Avg_{i,j} = (Gray_{i-1,j-1} + Gray_{i-1,j} + Gray_{i,j-1} + Gray_{i,j}) / 4$  

## Need frame synchronization signal for everyone !!!!!!!!
## Useful Link for PnP

https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=1217599
https://github.dev/opencv/opencv/blob/4.x/modules/calib3d/src/solvepnp.cpp
https://docs.opencv.org/3.4/d9/d0c/group__calib3d.html#ga357634492a94efe8858d0ce1509da869
https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8099974
