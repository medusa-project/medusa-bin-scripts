#!/bin/bash
source ./env.sh

echo $RCLONE_PIDFILE
if [[ -f $RCLONE_PIDFILE ]]; then
    pid=$(cat $RCLONE_PIDFILE)
    echo "Killing rclone mount. PID: $pid"
    kill $pid
    rm -f $RCLONE_PIDFILE
else
    echo "Rclone pidfile not found"
fi
