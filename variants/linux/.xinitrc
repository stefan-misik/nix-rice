#!/usr/bin/env sh

[ -f "$HOME/.xprofile" ] && . ~/.xprofile
[ -f "$HOME/.Xresources" ] && xrdb -merge -I$HOME ~/.Xresources

exec bspwm
