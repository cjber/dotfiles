#!/bin/bash

sync=$(rclone about od: | grep Used: | tr -s " " | cut -d ":" -f 2)

echo "od: $sync"
