#!/bin/sh

NANO=$(curl -s rate.sx/682.439563nano)
BUX=$(curl -s rate.sx/1232bux)
BAT=$(curl -s rate.sx/257.2497bat)
BAN=$(curl -s rate.sx/20414.11ban)
LINK=$(curl -s rate.sx/48.5link)
EFI=$(curl -s rate.sx/248efi)
GRT=$(curl -s rate.sx/10.556grt)

echo -n "\$"
echo $NANO + $BUX + $BAT + $BAN + $LINK + $EFI + $GRT | bc | xargs printf "%.2f"
echo -n " | XNO \$"
echo $(curl -s rate.sx/1nano) | xargs printf "%.2f"

echo -n " | BTC \$"
echo $(curl -s rate.sx/1btc) | xargs printf "%.0f"
