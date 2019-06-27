#!/bin/bash

source $HOME/bin/env.sh

mountpoint -q $RCLONE_MOUNTPOINT && fusermount -uz $RCLONE_MOUNTPOINT
