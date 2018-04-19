# LoFives
Glove instruments using open sound control, C.H.I.P and SuperCollider .

## Install on CHIP

Dependencies:
- sudo apt-get install liblo-dev python-dev cython build-essential python-numpy
- python liblo http://das.nasophon.de/pyliblo/
- RTIMULib https://github.com/RPi-Distro/RTIMULib and follow the python install instructions: https://github.com/RPi-Distro/RTIMULib/tree/master/Linux/python
- CHIP_IO https://github.com/xtacocorex/CHIP_IO

Enable lofives service in systemd on the CHIP:

- cp gloves.py /home/chip/bin/
- sudo cp lofives.service /etc/systemd/system/lofives.service 
- sudo chmod +x /usr/local/bin/lofives
- sudo systemctl enable lofives
- sudo systemctl start lofives
- sudo systemctl status lofives

Edit /usr/local/bin/lofives to connec tto correct host IP (gloves.py -s flag)

## Install on Host

Dependencies
- SuperCollider http://supercollider.github.io/

