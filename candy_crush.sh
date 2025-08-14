#!/bin/bash

# Candy Crush Clone in Bash - Optimized and Debugged

# Game configuration
BOARD_SIZE=8
CANDY_TYPES=("R" "G" "B" "Y" "P" "O")
MOVES_LEFT=20
SCORE=0
SELECTED_ROW=-1
SELECTED_COL=-1
declare -A board

# Initialize the game board with no initial matches
initialize_board() {
    local row col match_count=1
    
    while [[ $match_count -gt 0 ]]; do
        match_count=0
        
        # Fill board with random candies
        for ((row=0; row<BOARD_SIZE; row++)); do
            for ((col=0; col<BOARD_SIZE; col++)); do
                board[$row,$col]=${CANDY_TYPES[$RANDOM % ${#CANDY_TYPES[@]}]}
            done
        done
        
        # Check for initial matches
        match_count=$(find_matches | wc -l)
    done
}

# Display the game board with colors
display_board() {
    clear
    echo -e "Candy Crush Clone - Moves Left: \033[1;33m$MOVES_LEFT\033[0m - Score: \033[1;32m$SCORE\033[0m"
    echo "------------------------------------------------"
    
    # Column numbers
    echo -n "   "
    for ((col=0; col<BOARD_SIZE; col++)); do
        printf "%2d " $col
    done
    echo
    
    # Board rows with row numbers
    for ((row=0; row<BOARD_SIZE; row++)); do
        printf "%2d " $row
        
        for ((col=0; col<BOARD_SIZE; col++)); do
            local candy=${board[$row,$col]}
            local color_code=""
            
            # Set candy colors
            case $candy in
                "R") color_code="\033[1;31m" ;; # Red
                "G") color_code="\033[1;32m" ;; # Green
                "B") color_code="\033[1;34m" ;; # Blue
                "Y") color_code="\033[1;33m" ;; # Yellow
                "P") color_code="\033[1;35m" ;; # Purple
                "O") color_code="\033[1;38;5;208m" ;; # Orange
            esac
            
            # Highlight selected candy
            if [[ $row -eq $SELECTED_ROW && $col -eq $SELECTED_COL ]]; then
                echo -en "\033[7m${color_code}[$candy]\033[0m "
            else
                echo -en "${color_code}[$candy]\033[0m "
            fi
        done
        echo
    done
    echo "------------------------------------------------"
    echo "Instructions:"
    echo "1. Select first candy (row,col)"
    echo "2. Select adjacent candy to swap"
    echo "3. Commands: q=quit, r=reset, h=hint"
}

# Find all matches on the board
find_matches() {
    local matches=()
    local row col
    
    # Check horizontal matches
    for ((row=0; row<BOARD_SIZE; row++)); do
        for ((col=0; col<BOARD_SIZE-2; col++)); do
            if [[ ${board[$row,$col]} == ${board[$row,$((col+1))]} && \
                ${board[$row,$col]} == ${board[$row,$((col+2))]} ]]; then
                matches+=("$row,$col")
                matches+=("$row,$((col+1))")
                matches+=("$row,$((col+2))")
            fi
        done
    done
    
    # Check vertical matches
    for ((col=0; col<BOARD_SIZE; col++)); do
        for ((row=0; row<BOARD_SIZE-2; row++)); do
            if [[ ${board[$row,$col]} == ${board[$((row+1)),$col]} && \
                ${board[$row,$col]} == ${board[$((row+2)),$col]} ]]; then
                matches+=("$row,$col")
                matches+=("$((row+1)),$col")
                matches+=("$((row+2)),$col")
            fi
        done
    done
    
    # Remove duplicates and return
    printf '%s\n' "${matches[@]}" | sort -u
}

# Process matches and update board
process_matches() {
    local matches=$(find_matches)
    local match_count=$(echo "$matches" | wc -l)
    local had_matches=0
    
    while [[ $match_count -gt 0 ]]; do
        had_matches=1
        
        # Add to score (10 points per candy + 50 bonus for chain reactions)
        if [[ $SCORE -eq 0 ]]; then
            SCORE=$((SCORE + match_count * 10))
        else
            SCORE=$((SCORE + match_count * 10 + 50))
        fi
        
        # Remove matched candies
        while IFS=',' read -r row col; do
            board[$row,$col]=" "
        done <<< "$matches"
        
        # Shift candies down
        for ((col=0; col<BOARD_SIZE; col++)); do
            for ((row=BOARD_SIZE-1; row>=0; row--)); do
                if [[ ${board[$row,$col]} == " " ]]; then
                    # Find first non-empty candy above
                    local above=$((row-1))
                    while [[ $above -ge 0 && ${board[$above,$col]} == " " ]]; do
                        above=$((above-1))
                    done
                    
                    if [[ $above -ge 0 ]]; then
                        board[$row,$col]=${board[$above,$col]}
                        board[$above,$col]=" "
                    fi
                fi
            done
        done
        
        # Fill empty spaces with new candies
        for ((row=0; row<BOARD_SIZE; row++)); do
            for ((col=0; col<BOARD_SIZE; col++)); do
                if [[ ${board[$row,$col]} == " " ]]; then
                    board[$row,$col]=${CANDY_TYPES[$RANDOM % ${#CANDY_TYPES[@]}]}
                fi
            done
        done
        
        # Check for more matches
        matches=$(find_matches)
        match_count=$(echo "$matches" | wc -l)
    done
    
    return $((1 - had_matches)) # Return 0 if had matches, 1 if not
}

# Swap two candies if valid
swap_candies() {
    local row1=$1 col1=$2 row2=$3 col2=$4
    local temp=${board[$row1,$col1]}
    
    # Perform the swap
    board[$row1,$col1]=${board[$row2,$col2]}
    board[$row2,$col2]=$temp
    
    # Check if swap created a match
    if ! process_matches; then
        # No match created, swap back
        board[$row2,$col2]=${board[$row1,$col1]}
        board[$row1,$col1]=$temp
        return 1
    fi
    
    MOVES_LEFT=$((MOVES_LEFT - 1))
    return 0
}

# Check if two positions are adjacent
are_adjacent() {
    local row1=$1 col1=$2 row2=$3 col2=$4
    
    if [[ $row1 -eq $row2 && $(($col1 - $col2)) -eq 1 ]]; then
        return 0
    elif [[ $row1 -eq $row2 && $(($col2 - $col1)) -eq 1 ]]; then
        return 0
    elif [[ $col1 -eq $col2 && $(($row1 - $row2)) -eq 1 ]]; then
        return 0
    elif [[ $col1 -eq $col2 && $(($row2 - $row1)) -eq 1 ]]; then
        return 0
    fi
    
    return 1
}

# Show a hint for a possible move
show_hint() {
    local row col
    
    # Check horizontal swaps
    for ((row=0; row<BOARD_SIZE; row++)); do
        for ((col=0; col<BOARD_SIZE-1; col++)); do
            # Try swap
            local temp=${board[$row,$col]}
            board[$row,$col]=${board[$row,$((col+1))]}
            board[$row,$((col+1))]=$temp
            
            if [[ $(find_matches | wc -l) -gt 0 ]]; then
                # Undo swap
                board[$row,$((col+1))]=${board[$row,$col]}
                board[$row,$col]=$temp
                echo "Hint: Try swapping ($row,$col) with ($row,$((col+1)))"
                return
            fi
            
            # Undo swap
            board[$row,$((col+1))]=${board[$row,$col]}
            board[$row,$col]=$temp
        done
    done
    
    # Check vertical swaps
    for ((col=0; col<BOARD_SIZE; col++)); do
        for ((row=0; row<BOARD_SIZE-1; row++)); do
            # Try swap
            local temp=${board[$row,$col]}
            board[$row,$col]=${board[$((row+1)),$col]}
            board[$((row+1)),$col]=$temp
            
            if [[ $(find_matches | wc -l) -gt 0 ]]; then
                # Undo swap
                board[$((row+1)),$col]=${board[$row,$col]}
                board[$row,$col]=$temp
                echo "Hint: Try swapping ($row,$col) with ($((row+1)),$col)"
                return
            fi
            
            # Undo swap
            board[$((row+1)),$col]=${board[$row,$col]}
            board[$row,$col]=$temp
        done
    done
    
    echo "No valid moves found! Try resetting the game."
}

# Main game loop
main() {
    initialize_board
    
    while true; do
        display_board
        
        if [[ $MOVES_LEFT -le 0 ]]; then
            echo -e "\033[1;31mGame Over!\033[0m Final Score: \033[1;32m$SCORE\033[0m"
            read -p "Play again? (y/n) " choice
            if [[ $choice == "y" || $choice == "Y" ]]; then
                MOVES_LEFT=20
                SCORE=0
                SELECTED_ROW=-1
                SELECTED_COL=-1
                initialize_board
                continue
            else
                break
            fi
        fi
        
        read -p "Enter row,col or command: " input
        
        case $input in
            q|Q)
                break
                ;;
            r|R)
                MOVES_LEFT=20
                SCORE=0
                SELECTED_ROW=-1
                SELECTED_COL=-1
                initialize_board
                ;;
            h|H)
                show_hint
                read -p "Press enter to continue..."
                ;;
            *[0-9],[0-9]*)
                IFS=',' read -r row col <<< "$input"
                if [[ $row -ge 0 && $row -lt $BOARD_SIZE && $col -ge 0 && $col -lt $BOARD_SIZE ]]; then
                    if [[ $SELECTED_ROW -eq -1 && $SELECTED_COL -eq -1 ]]; then
                        SELECTED_ROW=$row
                        SELECTED_COL=$col
                    else
                        if are_adjacent $SELECTED_ROW $SELECTED_COL $row $col; then
                            if swap_candies $SELECTED_ROW $SELECTED_COL $row $col; then
                                SELECTED_ROW=-1
                                SELECTED_COL=-1
                            else
                                echo -e "\033[1;31mInvalid swap - no match created!\033[0m"
                                read -p "Press enter to continue..."
                            fi
                        else
                            echo -e "\033[1;31mCandies must be adjacent!\033[0m"
                            read -p "Press enter to continue..."
                            SELECTED_ROW=-1
                            SELECTED_COL=-1
                        fi
                    fi
                else
                    echo -e "\033[1;31mInvalid coordinates!\033[0m"
                    read -p "Press enter to continue..."
                    SELECTED_ROW=-1
                    SELECTED_COL=-1
                fi
                ;;
            *)
                echo -e "\033[1;31mInvalid input!\033[0m"
                read -p "Press enter to continue..."
                SELECTED_ROW=-1
                SELECTED_COL=-1
                ;;
        esac
    done
    
    echo "Thanks for playing!"
}

# Start the game
main
