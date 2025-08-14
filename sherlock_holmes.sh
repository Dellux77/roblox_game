#!/bin/bash
# Sherlock - A deduction game

case=$(($RANDOM%3+1))
clues=("The killer wore a black coat" "The butler saw nothing" "The window was forced")
solution=("The professor" "The gardener" "The wife")

clear
echo "Sherlock Holmes: Murder Mystery"
echo "A body has been found in the library."
echo "Clue: ${clues[$case-1]}"
echo
echo "Who done it?"
echo "1) The professor"
echo "2) The gardener"
echo "3) The wife"
echo -n "Your deduction (1-3): "

read guess
[ $guess -eq $case ] && echo "Correct! ${solution[$case-1]} did it!" || echo "Wrong! It was ${solution[$case-1]}!"
