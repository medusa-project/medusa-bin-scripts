#!/bin/bash

source ./env.sh

mkdir -p $RCLONE_MOUNTPOINT
mkdir -p $RCLONE_PIDDIR

rclone mount medusa-user:medusa-main $HOME/mnt/medusa-main-ro --read-only &
#rclone mount medusa-user:medusa-main $HOME/mnt/medusa-main-ro --read-only --log-file $HOME/bin/rclone.log -vv &
echo $! > $RCLONE_PIDFILE
