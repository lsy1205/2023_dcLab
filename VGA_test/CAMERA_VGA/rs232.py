#!/usr/bin/env python
from serial import Serial, EIGHTBITS, PARITY_NONE, STOPBITS_ONE
import random as nd
import numpy as np
from PIL import Image
from sys import argv

s = Serial(
    port=argv[1],
    baudrate=115200,
    bytesize=EIGHTBITS,
    parity=PARITY_NONE,
    stopbits=STOPBITS_ONE,
    xonxoff=False,
    rtscts=False
)

# img = Image.open("amongus.jpg")
img = Image.open("chessboard.jpg")
# img = Image.open("rainbow.jpg")
img = img.resize((128,128))
img = np.array(img)

s.write(img)
# for i in range(128*128*3):
    # s.write(nd.randint(0,255).to_bytes(1, byteorder='big'))
    # s.write(((i+128) % 256).to_bytes(1, byteorder='big'))
    # s.write(nd.randint(0,1).to_bytes(1, byteorder='big'))
