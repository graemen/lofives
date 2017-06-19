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