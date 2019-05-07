#!/bin/bash
source ./env.sh

mountpoint -q $RCLONE_MOUNTPOINT && fusermount -uz $RCLONE_MOUNTPOINT
