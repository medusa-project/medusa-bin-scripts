#!/bin/bash

source $HOME/bin/env.sh

mkdir -p $RCLONE_MOUNTPOINT
mkdir -p $RCLONE_PIDDIR

#mountpoint -q $RCLONE_MOUNTPOINT && fusermount -uz $RCLONE_MOUNTPOINT
fusermount -uz $RCLONE_MOUNTPOINT || echo "$RCLONE_MOUNTPOINT may not be mounted currently"
rclone mount $RCLONE_REMOTE:$RCLONE_BUCKET $RCLONE_MOUNTPOINT --read-only &
echo $! > $RCLONE_PIDFILE
