# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import serial as sr
import numpy as np
PORT = 'COM6'


serialObj = sr.serial_for_url(PORT, timeout=5)
serialObj.baudrate = 4800#args.BAUDRATE
serialObj.bytesize = sr.EIGHTBITS#args.bytesize
serialObj.parity = sr.PARITY_NONE#args.parity
serialObj.stopbits = sr.STOPBITS_ONE#args.stopbits
#serialObj.rtscts = args.rtscts
#serialObj.xonxoff = args.xonxoff

weight_array = np.loadtxt('checkfile.txt')
weight_array = np.array([int(i) for i in weight_array])
read_from =[]
for i in range(1):
    #print(weight_array[i])
    serialObj.write((str(weight_array[i])).encode('utf-8'))
    #print((str(weight_array[i])).encode('utf-8'))
    #read_from.append(serialObj.read(8))

print(serialObj.read(8))
#read_from = serialObj.read(8)
print(read_from)