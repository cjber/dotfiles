#!/bin/sh
ws=$(hyprctl activeworkspace -j | jq -r ".id")
toggle=$(cat $HOME/.toggle$ws)

if [[ $toggle == "" ]]
then
    echo 0.33 > $HOME/.toggle$ws
fi

if [[ $toggle == 0.33 ]]
then
    echo 0.5 > $HOME/.toggle$ws \
    && hyprctl dispatch layoutmsg mfact 0.5 $ws
elif [[ $toggle == 0.5 ]]
then
    echo 0.33 > $HOME/.toggle$ws \
    && hyprctl dispatch layoutmsg mfact 0.33 $ws
fi
