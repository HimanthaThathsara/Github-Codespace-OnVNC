#!/bin/bash
# 
# Use the gitHub-codespaces as Linux cloud desktop Using `XFCE + TigerVNC + noVNC`
# Instructions:
#       1. Create a new Codespace from this repo or fork this.
#       2. Open the terminal and run this script: `./main.sh
#       3. That All.

# you can change the desktop resolution by changing the setting of the OnVNC server, butt in the start i difined hard code for the resolution.

# Import the color variables and functions for pretty output
source "$(dirname "$0")/lib/color.sh"

# CONFIG 
DISPLAY_NUM=1            # Donot change the `DISPLAY_NUM` unless you have to plan use few VNC display.
VNC_PORT=5901
NOVNC_PORT=6080
GEOMETRY="1280x720"      # desktop resolution hard code for this test
DEPTH=24
NOVNC_DIR="$HOME/noVNC"


set -euo pipefail

# Check for missing packages
# store the variable `need_install` as 1 if any are missing
need_install=0
for cmd in startxfce4 vncserver dbus-launch; do
    command -v "$cmd" >/dev/null 2>&1 || need_install=1
done

# Install dependencies
# If `need_install` is 1, then this install the all the desktop and VNC packages.
if [ "$need_install" -eq 1 ]; then
    say ">> Installing desktop + VNC packages."
    sudo apt-get update -y
    sudo apt-get install -y \
        xfce4 xfce4-goodies \
        tigervnc-standalone-server tigervnc-common \
        dbus-x11
else
    say ">> Desktop packages already installed, Skipping."
fi

# Clone the noVNC repo if it doesn't exist.
# websockify is a dependency of noVNC, so we clone it into the correct subdirectory.
if [ ! -d "$NOVNC_DIR" ]; then
    say ">> Cloning noVNC"
    git clone https://github.com/novnc/noVNC.git "$NOVNC_DIR"
    git clone https://github.com/novnc/websockify "$NOVNC_DIR/utils/websockify"
else
    say ">> noVNC already Installed. Skipping."
fi

# setup the correct xstartup
say ">> setup the xstartup."
mkdir -p "$HOME/.vnc"
cat > "$HOME/.vnc/xstartup" << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
dbus-launch --exit-with-session startxfce4
EOF
chmod +x "$HOME/.vnc/xstartup"

# Setup the VNC password
if [ ! -f "$HOME/.vnc/passwd" ]; then
    warn ">> Create one now & Used this to log in to the onVNC session."
    vncpasswd
fi

# Kill anysession on this display, then start
say ">> Restarting VNC server on :$DISPLAY_NUM "
vncserver -kill ":$DISPLAY_NUM" >/dev/null 2>&1 || true
sleep 1
vncserver ":$DISPLAY_NUM" -geometry "$GEOMETRY" -depth "$DEPTH" -localhost no

# close the old noVNC bridge, if any in running and start a new one.
say ">> Starting noVNC bridge"
pkill -f "novnc_proxy" >/dev/null 2>&1 || true
sleep 1

echo ""
echo -e "Desktop is ready."
echo -e "  1. Go to the PORTS tab in VS Code."
echo -e "  2. If port ${NOVNC_PORT} is not listed, click 'Forward a Port' and add ${NOVNC_PORT}."
echo -e "  3. Click the globe icon, then add  /vnc.html  to the URL."
echo -e "  4. Click Connect and enter your VNC password."
echo ""

# noVNC runs in the foreground. Leave this terminal open.
"$NOVNC_DIR/utils/novnc_proxy" --vnc "localhost:$VNC_PORT" --listen "$NOVNC_PORT"
