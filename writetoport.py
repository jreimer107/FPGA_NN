# -*- coding: utf-8 -*-
"""
Created on Mon Dec  2 20:18:42 2019

@author: ECE_STUDENT
"""

# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import serial as sr
import numpy as np
import time
PORT = 'COM7'


serialObj = sr.serial_for_url(PORT, timeout= None
                              )
serialObj.baudrate = 9600#args.BAUDRATE
serialObj.bytesize = sr.EIGHTBITS#args.bytesize
serialObj.parity = sr.PARITY_NONE#args.parity
serialObj.stopbits = sr.STOPBITS_ONE#args.stopbits
#serialObj.rtscts = args.rtscts
#serialObj.xonxoff = args.xonxoff

weight_array = np.loadtxt('checkfile.txt')
weight_array = np.array([int(i) for i in weight_array])
read_from =[]
for i in range(0, weight_array.shape[0], 1):
    packet = bytearray()
    packet.append(weight_array[i])
    serialObj.write(packet)
    print("write value", i,":", hex(packet[0]))    
    time.sleep(.0012)

#for i in range(int(len(weight_array)/32)):
#    data = serialObj.read(32)
#    hex_data = []
#    for d in data:
#        hex_data.append(hex(d))
#    print ("read value", i,":", hex_data)
for i in range(int(len(weight_array))):
    data = serialObj.read(1)
    val = hex(data[0])
    print ("read value", i,":", val)
    if(hex(i) != val and int(i) < 256):
        print('ERROR')
        break

serialObj.close()
