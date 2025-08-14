#!/bin/bash
# Rivals - Debugged and Working Duel Game

p1_health=100
p2_health=100

while (( p1_health > 0 && p2_health > 0 )); do
    clear
    echo "Player 1: $p1_health   Player 2: $p2_health"
    echo "1) Attack (10-15 dmg)"
    echo "2) Heal (5-10 hp)"
    echo "3) Special (20-25 dmg, 50% hit)"
    
    # Player 1 move with input validation
    while true; do
        read -p "Player 1 move [1-3]: " p1_move
        if [[ "$p1_move" =~ ^[1-3]$ ]]; then
            break
        else
            echo "Invalid input! Please enter 1, 2, or 3"
        fi
    done

    # Player 1 action
    case $p1_move in
        1) 
            dmg=$((10 + RANDOM % 6))
            ((p2_health -= dmg))
            echo "Player 1 attacks for $dmg damage!"
            ;;
        2) 
            heal=$((5 + RANDOM % 6))
            ((p1_health += heal))
            # Cap health at 100
            ((p1_health > 100)) && p1_health=100
            echo "Player 1 heals for $heal health!"
            ;;
        3) 
            if (( RANDOM % 2 )); then 
                dmg=$((20 + RANDOM % 6))
                ((p2_health -= dmg))
                echo "Player 1's special attack hits for $dmg damage!"
            else 
                echo "Player 1's special attack missed!"
            fi
            ;;
    esac
    
    # Check if Player 2 was defeated
    (( p2_health <= 0 )) && break
    
    # Simple AI for Player 2
    ai_move=$((1 + RANDOM % 3))
    case $ai_move in
        1) 
            dmg=$((10 + RANDOM % 6))
            ((p1_health -= dmg))
            echo "Player 2 attacks for $dmg damage!"
            ;;
        2) 
            heal=$((5 + RANDOM % 6))
            ((p2_health += heal))
            # Cap health at 100
            ((p2_health > 100)) && p2_health=100
            echo "Player 2 heals for $heal health!"
            ;;
        3) 
            if (( RANDOM % 2 )); then 
                dmg=$((20 + RANDOM % 6))
                ((p1_health -= dmg))
                echo "Player 2's special attack hits for $dmg damage!"
            else 
                echo "Player 2's special attack missed!"
            fi
            ;;
    esac
    
    # Ensure health doesn't go negative
    ((p1_health < 0)) && p1_health=0
    ((p2_health < 0)) && p2_health=0
    
    sleep 2
done

# Game over message
clear
echo "Final Scores:"
echo "Player 1: $p1_health   Player 2: $p2_health"
(( p1_health > p2_health )) && echo "Player 1 wins!" || echo "Player 2 wins!"`
            
