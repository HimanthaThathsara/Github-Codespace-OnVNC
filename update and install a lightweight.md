# update and install a lightweight desktop + VNC server
sudo apt-get update
sudo apt-get install -y xfce4 xfce4-goodies tigervnc-standalone-server tigervnc-common dbus-x11

# install noVNC (lets you view the desktop in a browser tab)
git clone https://github.com/novnc/noVNC.git ~/noVNC
git clone https://github.com/novnc/websockify ~/noVNC/utils/websockify

# set a VNC password (you'll type one when prompted)
mkdir -p ~/.vnc
vncpasswd

# tell VNC to launch XFCE
echo -e '#!/bin/bash\nstartxfce4 &' > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

# start the VNC server on display :1 (1280x720)
vncserver :1 -geometry 1280x720 -depth 24 -localhost no

# kill any half-started session
vncserver -kill :1

# write a proper xstartup file
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
dbus-launch --exit-with-session startxfce4
EOF

# make it executable
chmod +x ~/.vnc/xstartup

# start noVNC, bridging the desktop to a web port (6080)
~/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080


- "Forward a Port" button --> Type the port number inside the little box --> port number `6080` --> A row for 6080 should now show up --> Hover over it --> click the globe icon to open it in a browser tab --> then add `vnc.html` to the end of that URL and press Enter.

- Kill the VNC 
    `vncserver -kill :1`
