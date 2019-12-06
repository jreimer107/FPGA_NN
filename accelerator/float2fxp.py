#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov 15 17:36:07 2019

@author: asmitapal
"""


import scipy.io
import numpy
from decimal import Decimal, ROUND_UP
import glob  

#Create a dictionary of binary to hex mappings for 0-16
hex2bin = dict('{:04b} {:x}'.format(x,x).split() for x in range(16))


"""

Convert each decimal fraction to binary
Ignore the decimal place and concatenate it
as a single number.
The logic followed here to get the binary for fraction is to keep
on multiplying till you reach 1. Additionally 1 bit is added in the
first place to account for sign.

"""
def decimalToBinary(num) : 
  
    binary = ""
    Integral = abs(int(num))
    fractional = abs(num - Integral)
    
    #Process the integer part. Add zeroes equivalent to integer width if
    #integer part is 0.
    if(Integral == 0):
        binary += 5*'0'
    else:
        while (Integral) : 
            rem = Integral % 2
            binary += str(rem); 
            Integral //= 2
        if(len(binary) < 5):
            binary = (5-len(binary)) * '0' + binary
    #binary = binary[ : : -1]

    #Account for sign bit
    if(num < 0):
        sign_bit = '1' 
    else:
        sign_bit = '0'
#    
    #Conversion for fractional part
    #TODO: No support for anything exceeding 10 bits
    fract_bit = 0
    binary_fract=""
    while (fract_bit==0) : 
        fractional *= 2
        fract_bit = int(fractional)
        #print(fractional, fract_bit)
  
        if (fract_bit == 1) : 
            fractional -= fract_bit  
            binary_fract += '1'
              
        else : 
            binary_fract += '0'
    if(len(binary_fract) <= 10):
        binary_fract = (10-len(binary_fract)) * '0' + binary_fract
    
    #print(len(binary), len(binary_fract))
    binary = sign_bit + binary + binary_fract
    
  
        #k_prec -= 1
  
    return binary


"""

Convert a binary number to hex by getting keys from the
dictionary. If the number of bits is 

"""

def bin2hex(n):
   #print(n)
   new_str =[]
   new_str = [n[i:i+4] for i in range(0, len(n), 4)]
   #print(n, new_str)
   hex_num = "0x"
   for s in new_str:
       hex_num += hex2bin.get(s)
   return hex_num


# Driver code
if __name__ == "__main__" :
    n = 2.854
    bin_n = decimalToBinary(n)
    print(bin_n)
    hex_n = bin2hex(bin_n)
    print(n, bin_n, hex_n)
    for file in glob.glob('/Users/asmitapal/Downloads/weights/*.mat'):
        mat = scipy.io.loadmat(file)
        layer_weight = mat['parameters'] # array
        print (file, layer_weight.shape)
        
        #filename = file.split('/')[-1]
        filepath = file.split('.')[0]+'_3FxP-Binary.txt'
        filepath2 = file.split('.')[0]+'_3FxP-Hex.txt'
        fp = open(filepath, 'w')
        fp2 = open(filepath2,'w')
        #binary_layer = []
        #hex_layer = []
        for i in range(len(layer_weight)):
            for j in range(len(layer_weight[i])):
                z = layer_weight[i][j].item()
                layer_weight[i][j] = Decimal(z).quantize(Decimal('1.000'), rounding=ROUND_UP)
                #layer1_weight[i][j] = float_bin(layer1_weight[i][j], 6)
                print(layer_weight[i][j])
                bin_n = decimalToBinary(layer_weight[i][j])
                
                #binary_layer.append(bin_n)
                #print(binary_layer[i][j])
                hex_n = bin2hex(bin_n)
                #hex_layer.append( bin2hex(bin_n))
                print(layer_weight[i][j], bin_n, hex_n)
                fp.write(str(bin_n)+ ' ')
                fp2.write(str(hex_n)+ ' ')
            fp.write('\n')
            fp2.write('\n')
        fp.close()
        fp2.close()