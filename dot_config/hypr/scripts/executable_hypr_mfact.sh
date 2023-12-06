#!/bin/sh
if [[ $(hyprctl getoption master:mfact -j | jq -r ".float") == "0.33000" ]]
then
    hyprctl dispatch layoutmsg mfact 0.5 && \
        hyprctl reload && \
        hyprctl keyword master:mfact 0.5
elif [[ $(hyprctl getoption master:mfact -j | jq -r ".float") == "0.50000" ]]
then
    hyprctl dispatch layoutmsg mfact 0.33 && \
        hyprctl reload && \
        hyprctl keyword master:mfact 0.33
fi
