# lofives
Gestural instruments using open sound control, C.H.I.P and SuperCollider.

## Install on CHIP

Dependencies:
- liblo http://das.nasophon.de/pyliblo/
- numpy http://www.numpy.org/
- RTIMULib https://github.com/RPi-Distro/RTIMULib 
- CHIP_IO https://github.com/xtacocorex/CHIP_IO

Enable lofives service in systemd on the CHIP:

- sudo cp lofives.service /etc/systemd/system/lofives.service 
- sudo chmod +x /usr/local/bin/lofives
- sudo systemctl enable lofives
- sudo systemctl start lofives
- sudo systemctl status lofives

## Install on Host

Dependencies
- SuperCollider http://supercollider.github.io/

