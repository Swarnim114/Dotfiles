#!/bin/bash

CURRENT=$(hyprshade current)

case "$CURRENT" in
    blue_light_filter)
        NEXT="nightmode"
        ;;
    nightmode)
        NEXT="paper"
        ;;
    paper)
        hyprshade off
        exit
        ;;
    *)
        NEXT="blue_light_filter"
        ;;
esac

hyprshade on "$NEXT"
