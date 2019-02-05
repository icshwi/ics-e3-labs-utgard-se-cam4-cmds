#!/bin/bash

E3_BIN=/epics/base-3.15.5/require/3.0.0/bin
IOC=labs-utg-se-cam1
IOC_PATH=/home/iocuser/iocs/cmds/$IOC
IOC_CMD=st.$IOC.cmd
PORT=2000

source $E3_BIN/setE3Env.bash

/usr/bin/procServ -f -L /var/log/procServ/$IOC -i ^C^D -c $IOC_PATH $PORT $E3_BIN/iocsh.bash $IOC_PATH/$IOC_CMD &

