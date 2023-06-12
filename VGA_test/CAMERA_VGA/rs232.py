#!/usr/bin/env python
from serial import Serial, EIGHTBITS, PARITY_NONE, STOPBITS_ONE
import random as nd
import time
from sys import argv

i = 0
s = Serial(
    port=argv[1],
    baudrate=115200,
    bytesize=EIGHTBITS,
    parity=PARITY_NONE,
    stopbits=STOPBITS_ONE,
    xonxoff=False,
    rtscts=False
)

for i in range(16384*3):  #range(16384*3):
    s.write(nd.randint(0,255).to_bytes(1, byteorder='big'))
    # s.write(((i+128) % 256).to_bytes(1, byteorder='big'))
    # s.write(nd.randint(0,1).to_bytes(1, byteorder='big'))
