#!/bin/bash
# Mind Reader - Bash version

# Set up colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Generate random symbol
symbols=('*' '#' '$' '%' '@' '&' '?' '!' '+')
chosen=${symbols[$RANDOM % ${#symbols[@]}]}

# Build the grid
clear
echo -e "${GREEN}=== Mind Reader ===${NC}"
echo "Think of a 2-digit number (10-99)"
echo "Add the digits together"
echo "Subtract that from your number"
echo "Find your result below and focus on its symbol"
echo

# Display grid with all multiples of 9 having the same symbol
for i in {0..89}; do
  (( (i+10) % 9 == 0 )) && echo -n "$chosen " || echo -n "${symbols[$RANDOM % ${#symbols[@]}]} "
  (( (i+1) % 9 == 0 )) && echo
done

echo
read -p "Press Enter when ready..."
echo -e "${RED}I'm reading your mind...${NC}"
sleep 2
echo -e "The symbol you're thinking of is: ${GREEN}$chosen${NC}"
sleep 1
echo "How it works: The math always gives a multiple of 9 (9,18,27...)"
echo "All those positions show the same symbol!"
