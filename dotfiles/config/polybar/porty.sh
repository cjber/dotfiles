#!/bin/sh

NANO=$(curl -s rate.sx/682.439563xno)
# BUX=$(curl -s rate.sx/1232bux)
BUX=0.55*1232
BAT=$(curl -s rate.sx/257.2497bat)
BAN=$(curl -s rate.sx/20414.11ban)
ALGO=$(curl -s rate.sx/762algo)
EFI=$(curl -s rate.sx/248efi)
GRT=$(curl -s rate.sx/10.556grt)

echo -n "\$"
echo $NANO + $BUX + $BAT + $BAN + $ALGO + $EFI + $GRT | bc | xargs printf "%.2f"
echo -n " | XNO \$"
echo $(curl -s rate.sx/1xno) | xargs printf "%.2f"

echo -n " | BTC \$"
echo $(curl -s rate.sx/1btc) | xargs printf "%.0f"
