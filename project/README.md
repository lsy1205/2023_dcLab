# Project

## Memory

### Data Assignment

* VGA: SRAM
  * 640x480x60Hz = 28 MHz access (require FIFO of 48 bit)
* Image Process: SDRAM in, SRAM out
  * ?? Hz
* Camera: SDRAM
  * 640x480x30Hz = 9 MHz access (FIFO)

### SDRAM Data Format

* RGBGray: `8:8:8:8`
  * $G = (G_1+G_2) / 2$
  * $Gray = (R+G_1+G_2+B) / 4$

### Average filter

* unprocessed gray pixel store in SRAM
* averaged gray pixel store in SDRAM
* $Avg_{i,j} = (Gray_{i-1,j-1} + Gray_{i-1,j} + Gray_{i,j-1} + Gray_{i,j}) / 4$
  
### Blue Square

* threshold on B channel to extract the rectangle

### Useful Link for PnP

https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=1217599
https://github.dev/opencv/opencv/blob/4.x/modules/calib3d/src/solvepnp.cpp
https://docs.opencv.org/3.4/d9/d0c/group__calib3d.html#ga357634492a94efe8858d0ce1509da869
https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8099974
