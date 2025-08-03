#!/bin/bash
# sway-next-workspace.sh

# Get the current workspace number
current=$(swaymsg -t get_workspaces | jq '.[] | select(.focused).num')

# Decide maximum workspace number, adjust as desired
max=10

if [[ $current -lt $max ]]; then
    next=$((current + 1))
    swaymsg workspace number $next
fi
