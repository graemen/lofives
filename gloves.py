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
import time
import liblo
import smbus
import numpy
import RTIMU
import CHIP_IO.GPIO as GPIO

SETTINGS_FILE = "RTIMULib"

# set sound server
try:
    target = liblo.Address('192.168.0.26', '8000')
except liblo.AddressError as err:
    print(err)
    sys.exit()

# running
run = True
timestamp = 0

# setup i2c 9DoF IMU
s = RTIMU.Settings(SETTINGS_FILE)
imu = RTIMU.RTIMU(s)

if imu.IMUInit():
    print imu.IMUName()
else:
    print "could not initialise IMU exiting."
    exit()

imu.setGyroEnable(True)
imu.setAccelEnable(True)
imu.setCompassEnable(True)

poll_interval = imu.IMUGetPollInterval()

while(run):
    if imu.IMURead():

        # accelerometer x/y/z in meters/s2
        # magetometer x/y/z in gauss
        # gyroscope in x/y/x degrees/second

        # get the data from the imu
        data = imu.getIMUData()
        #print data
        print "-"
        gyro = data['gyro']
    accel = data['accel']
    compass = data['compass']

        # send data via OSC
    print "gyro", gyro
        liblo.send(target, "/gloves/right/gyroX", gyro[0], "gyroX")
        liblo.send(target, "/gloves/right/gyroY", gyro[1], "gyroY")
        liblo.send(target, "/gloves/right/gyroZ", gyro[2], "gyroZ")

    print "accel", accel
        liblo.send(target, "/gloves/right/accelX", accel[0], "accelX")
        liblo.send(target, "/gloves/right/accelY", accel[1], "accelY")
        liblo.send(target, "/gloves/right/accelZ", accel[2], "accelZ")

    print "compass", compass
        liblo.send(target, "/gloves/right/compassX", compass[0], "compassX")
        liblo.send(target, "/gloves/right/compassY", compass[1], "compassY")
        liblo.send(target, "/gloves/right/compassZ", compass[2], "compassZ")

        #liblo.send(target, "/gloves/right/0", 1, "firstfinger")
        #liblo.send(target, "/gloves/right/1", 1, "secondfinger")
        #liblo.send(target, "/gloves/right/2", 1, "thirdfinger")
        #liblo.send(target, "/gloves/right/3", 1, "fourthfinger")

        # run at poll interval
        #time.sleep(poll_interval*1.0/1000.0)
        time.sleep(2.0)

    else:
        print "cannot read IMU"
