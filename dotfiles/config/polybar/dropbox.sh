#!/bin/bash

sync=$(python -W ignore /usr/bin/dropbox-cli status | grep Syncing)
upload=$(python -W ignore /usr/bin/dropbox-cli status | grep Uploading)

echo "$sync" + "|" "$upload"
