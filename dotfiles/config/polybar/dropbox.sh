#!/bin/bash

sync=$(maestral status | grep Status | tr -s " " | cut -d ":" -f 2)

echo "db: $sync"
