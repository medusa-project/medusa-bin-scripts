#!/bin/bash
source ./env.sh

mountpoint $RCLONE_MOUNTPOINT && fusermount -uz $RCLONE_MOUNTPOINT
