# lofives
Gestural instruments using open sound control, C.H.I.P and SuperCollider.

Need to enable rc.local in systemd on the CHIP:

sudo cp rc-local.service /etc/systemd/system/rc-local.service 
sudo chmod +x /etc/rc.local
sudo systemctl enable rc-local
sudo systemctl start rc-local.service
sudo systemctl status rc-local.service


