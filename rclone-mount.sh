#!/bin/bash

source ./env.sh

mkdir -p $RCLONE_MOUNTPOINT
mkdir -p $RCLONE_PIDDIR

rclone mount $RCLONE_REMOTE:$RCLONE_BUCKET $RCLONE_MOUNTPOINT --read-only &
echo $! > $RCLONE_PIDFILE
