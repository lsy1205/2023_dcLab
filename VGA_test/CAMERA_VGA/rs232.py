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

for i in range(16384):
    s.write(nd.randint(0,256).to_bytes(8, byteorder='big'))
    # time.sleep(0.00001)
    i = i + 1
