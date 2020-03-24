#!/usr/bin/env sh

[ -f "$HOME/.xprofile" ] && . ~/.xprofile
[ -f "$HOME/.config/Xresources" ] && xrdb -merge -I$HOME ~/.config/Xresources

exec bspwm
