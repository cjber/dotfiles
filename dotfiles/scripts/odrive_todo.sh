#!/bin/bash

DRIVE=$HOME/drive/todo

if pidof -o %PPID -x "odrive_todo.sh"; then exit 1; fi

/usr/bin/rclone bisync "$DRIVE" odrive:todo
