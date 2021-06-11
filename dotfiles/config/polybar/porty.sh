#!/bin/sh

NANO=$(curl -s rate.sx/682.439563nano)
BUX=$(curl -s rate.sx/1232bux)
BAT=$(curl -s rate.sx/257.2497bat)
BAN=$(curl -s rate.sx/20414.11ban)

echo -n "\$"
echo $NANO + $BUX + $BAT + $BAN | bc | xargs printf "%.2f"
echo -n " | XNO \$"
echo $(curl -s rate.sx/1nano) | xargs printf "%.2f"

echo -n " | BTC \$"
echo $(curl -s rate.sx/1btc) | xargs printf "%.0f"
