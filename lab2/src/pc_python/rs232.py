#!/usr/bin/env python
from serial import Serial, EIGHTBITS, PARITY_NONE, STOPBITS_ONE
from sys import argv

KEY_W = 512

assert len(argv) == 6, "Usage: {} <COM port> <e|d> <key file> <input file> <output file>".format(argv[0])
s = Serial(
    port=argv[1],
    baudrate=115200,
    bytesize=EIGHTBITS,
    parity=PARITY_NONE,
    stopbits=STOPBITS_ONE,
    xonxoff=False,
    rtscts=False
)
fp_key = open(argv[3], 'rb')
fp_enc = open(argv[4], 'rb')
fp_dec = open(argv[5], 'wb')
assert fp_key and fp_enc and fp_dec

key = fp_key.read(KEY_W*2//8)
enc = fp_enc.read()
assert len(enc) % (KEY_W//8) == 0

s.write(key)
for i in range(0, len(enc), KEY_W//8):
    s.write(enc[i:i+KEY_W//8])
    dec = s.read(KEY_W//8-1)
    fp_dec.write(dec)

fp_key.close()
fp_enc.close()
fp_dec.close()
