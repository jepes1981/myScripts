#!/usr/bin/env python

import subprocess
import json
from timeit import default_timer as timer
import time

CPU_CriticalTemp=60.0
CPU_CriticalTemp_Threshold=10 #seconds
CPU_Temp_Check_Frequency=2 #seconds
Current_CPU_Temp=-1.0
#start_time=0 #initialize time stamping for computation of CPU_Overheat_Duration
#end_time=0 #same as variable: start_time
CPU_Overheating_Flag = False #status of last temp check if beyond critical temp
CPU_Overheat_Duration = 0.0  #initialize, used to measure how long how CPU has been over the CPU_CriticalTemp_Threshold

def line():
    print('*'*80)

def get_CPU_temp():
    sensorsub = subprocess.run(['sensors', '-j'], capture_output=True)
    #print(sensorsub.stdout.decode())
    sensorsjson = json.loads(sensorsub.stdout.decode())
    #line()
    #print(type(sensorsjson['k10temp-pci-00c3']['Tdie']['temp2_input']))
    current_temp = sensorsjson['k10temp-pci-00c3']['Tdie']['temp2_input']    # floatingpoint
    #print('DEBUG27: CPU_CriticalTemp(from get_CPU_temp):', CPU_CriticalTemp) 
    return current_temp, current_temp >= CPU_CriticalTemp
    

def Critical_Mode(temp, duration):
    message = ['notify-send', '-u', 'critical', '{}'.format("CRITICAL TEMP at {} degrees for {} seconds already!!!, \nSHUTTING DOWN IN 30 SECONDS\nIssue the command shutdown -c to cancel".format(temp, duration))]
    print(message)
    subprocess.run(message)
    subprocess.run(['shutdown','30'])
    exit()
           
def main_loop():
    # first run, get start_time and current cpu temp
    global CPU_Overheat_Duration
    start_time = timer()
    #print('DEBUG36: start_time:', start_time)
    Current_CPU_Temp, CPU_Overheating_Flag = get_CPU_temp()
    #print('DEBUG37: Current_CPU_Temp: {}, CPU_Overheating_Flag: {}'.format(Current_CPU_Temp, CPU_Overheating_Flag))
    #print('DEBUG40: Starting sleep for {} seconds.'.format(CPU_Temp_Check_Frequency))
    time.sleep(CPU_Temp_Check_Frequency)
    Current_CPU_Temp, CPU_Overheating_Flag = get_CPU_temp()
    #print('DEBUG41: Current_CPU_Temp: {}, CPU_Overheating_Flag: {}, CPU_CriticalTemp: {}'.format(Current_CPU_Temp, CPU_Overheating_Flag, CPU_CriticalTemp))
    if CPU_Overheating_Flag :
        end_time = timer()
        #print('DEBUG44: end_time', end_time)
        CPU_Overheat_Duration += (end_time - start_time)
        #print('DEBUG46: CPU_Overheat_Duration:', CPU_Overheat_Duration)
        if CPU_Overheat_Duration >= CPU_CriticalTemp_Threshold :
            #print('DEBUG48: CPU_Overheat_Duration >= CPU_CriticalTemp_Threshold = True') 
            Critical_Mode(Current_CPU_Temp, CPU_Overheat_Duration)    #call critical mode, Critical_Mode is a function that can shutdown, provide notification etc
        #else: #print('DEBUG48: CPU_Overheat_Duration < CPU_CriticalTemp_Threshold')
    else:
        #print('DEBUG54: Reset CPU_Overheat_Duration to zero')
        CPU_Overheat_Duration = 0

def main():
    global CPU_CriticalTemp
    while True:
        main_loop()

main()

