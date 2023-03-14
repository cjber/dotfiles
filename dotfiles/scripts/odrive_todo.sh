#!/bin/bash

DRIVE=$HOME/drive/todo

if pgrep -fl rclone; then exit 1; fi

/usr/bin/rclone bisync "$DRIVE" odrive:todo
