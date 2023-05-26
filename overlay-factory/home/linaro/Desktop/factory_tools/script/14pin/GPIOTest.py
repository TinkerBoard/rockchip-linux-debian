#coding=UTF-8
import os
import subprocess

#Tinker 3
gpio_a=[105, 107, 146, 148, 149]
gpio_b=[106, 108, 148, 149, 146]

gpio_fail = []

def gpio_export(pin_number):
    if os.path.exists("/sys/class/gpio/gpio%d"%(pin_number)) == True:
       os.popen("./GPIOUnRegister.sh %d"%(pin_number))
    os.popen("./GPIORegister.sh %d"%(pin_number))

def gpio_selftest(pin_a,pin_b):
    MyProcess_a=subprocess.Popen("./GPIOSelfTest.sh %d %d"%(pin_a , pin_b) , shell=True,stdout=subprocess.PIPE)
    MyProcess_a.wait()
    output=MyProcess_a.stdout.read().decode("utf-8")
    if "FAIL" in output:
        gpio_fail.append(pin_a)

def main():
    for i in range(len(gpio_a)):

        #prepare to GPIO
        print ("Testing GPIO PIN#%d - #%d" %(gpio_a[i] , gpio_b[i]))
        gpio_export(gpio_a[i])
        gpio_export(gpio_b[i])

        #test each other
        gpio_selftest(gpio_a[i] , gpio_b[i])
        gpio_selftest(gpio_b[i] , gpio_a[i])

    if len(gpio_fail) > 0 :
        print("FAIL,ret=", end='')
        print(*gpio_fail, sep=",")
    else:
        print("PASS")

if __name__ == "__main__":
    main()
