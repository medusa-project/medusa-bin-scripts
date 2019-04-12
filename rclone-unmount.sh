#!/bin/bash
source ./env.sh

fusermount -uz $RCLONE_MOUNTPOINT
# if [[ -f $RCLONE_PIDFILE ]]; then
#     pid=$(cat $RCLONE_PIDFILE)
#     echo "Killing rclone mount. PID: $pid"
#     kill $pid
#     rm -f $RCLONE_PIDFILE
# else
#     echo "Rclone pidfile not found"
# fi
