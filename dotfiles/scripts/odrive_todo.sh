#!/bin/bash

DRIVE=$HOME/drive/todo

/usr/bin/rclone bisync "$DRIVE" odrive:todo
