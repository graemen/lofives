# ----------------------------------------------------------------------------------------------
#   This file is part of LoFives - osc glove instrument software.
#   This code runs on the C.H.I.P platform with an LSM9DS1 attached
#
#   LoFives is free software: you can redistribute it and/or modify it under the terms
#   of the GNU General Public License as published by the Free Software Foundation, either
#   version 3 of the license, or any later version.
#
#   LoFives is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
#   without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#   See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License along with
#   LoFives.  If not, see http://www.gnu.org/licenses/
#
#
#   Copyright 2017 LOlux productions (www.lolux.net)
#
#   Developed by :
#
#       graeme@lolux.net
#
# ----------------------------------------------------------------------------------------------

import math
import sys
import getopt
import time
import liblo
#import smbus
import numpy
import RTIMU
import CHIP_IO.GPIO as GPIO

def learn(imu, target):
    if imu.IMURead():
        data = imu.getIMUData()

        gyro = data['gyro']
        accel = data['accel']
        compass = data['compass']
        fusion = data['fusionPose']
        fusionq = data['fusionQPose']

        # send data via OSC
        print "fusionX"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/fusX", fusion[0], "fusionX")
        print "fusionY"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/fusY", fusion[1], "fusionY")
        print "fusionZ"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/fusZ", fusion[2], "fusionZ")

        print "fusionQ-X"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/fusqX", fusionq[0], "fusionqX")
        print "fusionQ-Y"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/fusqY", fusionq[1], "fusionqY")
        print "fusionQ-Z"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/fusqZ", fusionq[2], "fusionqZ")
        print "fusionQ-A"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/fusqA", fusionq[3], "fusionqA")

        print "gyroX"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/gyrX", gyro[0], "gyroX")
        print "gyroY"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/gyrY", gyro[1], "gyroY")
        print "gyroZ"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/gyrZ", gyro[2], "gyroZ")

        print "accelX"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/accX", accel[0], "accelX")
        print "accelY"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/accY", accel[1], "accelY")
        print "accelZ"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/accZ", accel[2], "accelZ")

        print "compassX"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/magX", compass[0], "compassX")
        print "compassY"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/magY", compass[1], "compassY")
        print "compassZ"
        raw_input("Press any key to learn...")
        liblo.send(target, "/gx/r/magZ", compass[2], "compassZ")

        #liblo.send(target, "/gx/r/0", 1, "firstfinger")
        #liblo.send(target, "/gx/r/1", 1, "secondfinger")
        #liblo.send(target, "/gx/r/2", 1, "thirdfinger")
        #liblo.send(target, "/gx/r/3", 1, "fourthfinger")


def read_imu(imu, target):
    # get the data from the imu
    data = imu.getIMUData()
    gyro = data['gyro']
    accel = data['accel']
    compass = data['compass']
    fusion = data['fusionPose']
    fusionq = data['fusionQPose']

    # send data via OSC
    liblo.send(target, "/gx/r/fusX", fusion[0], "fusionX")
    liblo.send(target, "/gx/r/fusY", fusion[1], "fusionY")
    liblo.send(target, "/gx/r/fusZ", fusion[2], "fusionZ")
    liblo.send(target, "/gx/r/fusqX", fusionq[0], "fusionqX")
    liblo.send(target, "/gx/r/fusqY", fusionq[1], "fusionqY")
    liblo.send(target, "/gx/r/fusqZ", fusionq[2], "fusionqZ")
    liblo.send(target, "/gx/r/fusqA", fusionq[3], "fusionqA")

    gyroX = numpy.interp(gyro[0], [-1.0,1.0], [0.0,1.0])
    liblo.send(target, "/gx/r/gyrX", gyroX, "gyroX")
    gyroY = numpy.interp(gyro[1], [-1.0,1.0], [0.0,1.0])
    liblo.send(target, "/gx/r/gyrY", gyroY, "gyroY")
    gyroZ = numpy.interp(gyro[2], [-1.0,1.0], [0.0,1.0])
    liblo.send(target, "/gx/r/gyrZ", gyroZ, "gyroZ")

    accelX = numpy.interp(accel[0], [-1.0,1.0], [0.0,1.0])
    liblo.send(target, "/gx/r/accX", accelX, "accelX")
    accelY = numpy.interp(accel[1], [-1.0,1.0], [0.0,1.0])
    liblo.send(target, "/gx/r/accY", accelY, "accelY")
    accelZ = numpy.interp(accel[2], [-1.0,1.0], [0.0,1.0])
    liblo.send(target, "/gx/r/accZ", accelZ, "accelZ")

    compassX = numpy.interp(compass[0], [-60.0,15.0], [0.0,1.0])
    liblo.send(target, "/gx/r/magX", compassX, "compassX")
    compassY = numpy.interp(compass[1], [-50.0,20.0], [0.0,1.0])
    liblo.send(target, "/gx/r/magY", compassY, "compassY")
    compassZ = numpy.interp(compass[2], [-50.0,40.0], [0.0,1.0])
    liblo.send(target, "/gx/r/magZ", compassZ, "compassZ")

    #liblo.send(target, "/gx/r/0", 1, "firstfinger")
    #liblo.send(target, "/gx/r/1", 1, "secondfinger")
    #liblo.send(target, "/gx/r/2", 1, "thirdfinger")
    #liblo.send(target, "/gx/r/3", 1, "fourthfinger")

def main(argv):

    # osc default server
    server = '192.168.0.26'
    # SC only seems to listen on thsi port...so make it default
    port = '57120'
    # default to sending OSC. run = False is learn mode
    run = True
    poll_interval = 0


    try:
        opts, args = getopt.getopt(argv,"hl:s:p:t:",["learn=", "server=","port=","timing="])
    except getopt.GetoptError:
        print 'test.py -l <learn> -s <server> -p <port> -t <timing>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'gloves.py -l <learn> -s <server> -p <port> -t <timing>'
            sys.exit()
        elif opt in ("-l", "--learn"):
            run = False
        elif opt in ("-s", "--server"):
            server = arg
        elif opt in ("-p", "--port"):
            port = arg
        elif opt in ("-t", "--timing"):
            poll_interval = float(arg);


    SETTINGS_FILE = "RTIMULib"

    # set sound server
    try:
        target = liblo.Address(server, port)
    except liblo.AddressError as err:
        print(err)
        sys.exit()


    # setup i2c 9DoF IMU
    s = RTIMU.Settings(SETTINGS_FILE)
    imu = RTIMU.RTIMU(s)

    if imu.IMUInit():
        print imu.IMUName()
    else:
        print "could not initialise IMU exiting."
        sys.exit()

    imu.setGyroEnable(True)
    imu.setAccelEnable(True)
    imu.setCompassEnable(True)

    # learn mode
    if not run:
        print "- Learning mode"
        learn(imu, target)
        sys.exit()

    # sense and transmit OSC data
    if poll_interval == 0:
    	poll_interval = (imu.IMUGetPollInterval())*1.0/1000.0

    print "- Transmit OSC to ", server, ":", port
    liblo.send(target, "/gx/status", 0, "ON")
    
    while(run):
        if imu.IMURead():
            read_imu(imu, target)
            time.sleep(poll_interval*1.0)
        else:
            time.sleep(poll_interval*1.0)

if __name__ == "__main__":
    main(sys.argv[1:])
