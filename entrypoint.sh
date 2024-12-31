#!/bin/dash

# SNUM=$(echo $DISPLAY | sed 's/:\([0-9][0-9]*\)/\1/')
# xvfb-run -n $SNUM -s "-screen 0 1024x768x24" -f ~/.Xauthority openbox-session &
# sleep 1
# x11vnc -display $DISPLAY -usepw -forever -quiet &

sudo chown $(id -u) /workdir
sudo chgrp $(id -g) /workdir

# this assumes the usb dongle of interest is located on bus 0 and device 3
# if not this should me modified to match (or can be run manually once the
# container is started)
if [ -c "/dev/bus/usb/001/003" ]; then
    echo "USB device detected at bus 001, device 003 Changing permissions"
    sudo chmod 0666 /dev/bus/usb/001/003
fi

# check to see if the STM32 Cube programmer is installed, and if it is
# then append it to the PATH
# can be downloaded from
# https://www.st.com/en/development-tools/stm32cubeprog.html
if [ -d "/home/$USER/st/stm32cubeclt_1.17.0/STM32CubeProgrammer" ]; then
    echo "Adding the STM32 Cube Programmer to the path"
    export PATH=$PATH:/home/$USER/st/stm32cubeclt_1.17.0/STM32CubeProgrammer/bin
fi

exec "$@"
