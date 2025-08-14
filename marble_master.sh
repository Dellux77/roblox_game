#!/bin/bash
# Marble Master - A simple marble game

# Game setup
marbles=15
player=1

# Main game loop
while [ $marbles -gt 0 ]; do
    clear
    echo "Marble Master"
    echo "Marbles left: $marbles"
    echo -n "Player $player: Take 1-3 marbles: "
    
    # Get valid input
    while true; do
        read take
        [ $take -ge 1 -a $take -le 3 -a $take -le $marbles ] 2>/dev/null && break
        echo "Invalid! Enter 1-3 (max $marbles): "
    done

    marbles=$((marbles - take))
    [ $marbles -eq 0 ] && break
    player=$((player % 2 + 1))
done

# Game over
echo "Player $player wins!"
