# lofives
Gestural instruments using open sound control, C.H.I.P and SuperCollider.

Need to enable lofives service in systemd on the CHIP:

sudo cp lofives.service /etc/systemd/system/lofives.service 
sudo chmod +x /usr/local/bin/lofives
sudo systemctl enable lofives
sudo systemctl start lofives
sudo systemctl status lofives


