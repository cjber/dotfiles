#!/bin/bash

grim -g "$(slurp)" - | wl-copy --type image/png
