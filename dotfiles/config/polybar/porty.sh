#!/bin/sh

NANO=$(curl -s rate.sx/683nano)
BUX=$(curl -s rate.sx/1232bux)
BAT=$(curl -s rate.sx/257bat)
BAN=$(curl -s rate.sx/20298ban)
OMG=$(curl -s rate.sx/32omg)

echo -n "\$"
echo $NANO + $BUX + $BAT + $BAN + $OMG | bc | xargs printf "%.2f"
