#!/bin/bash
# Garden Simulator

garden=("." "." "." "." ".")
plants=("carrot" "tomato" "flower" "weed")

while true; do
  clear
  echo "Your Garden: ${garden[*]}"
  echo "1) Plant"
  echo "2) Water"
  echo "3) Harvest"
  echo "4) Quit"
  read -p "Choose: " opt

  case $opt in
    1) 
      idx=$((RANDOM%5))
      plant=${plants[$RANDOM%4]}
      garden[$idx]=$plant
      echo "Planted $plant in plot $((idx+1))"
      ;;
    2) 
      for i in {0..4}; do
        [[ ${garden[$i]} != "." ]] && garden[$i]="*${garden[$i]}*"
      done
      echo "Watered all plants"
      ;;
    3)
      for i in {0..4}; do
        [[ ${garden[$i]} == *weed* ]] && garden[$i]="." && echo "Pulled weed from plot $((i+1))"
        [[ ${garden[$i]} == **carrot** ]] && garden[$i]="." && echo "Harvested carrot from plot $((i+1))"
        [[ ${garden[$i]} == **tomato** ]] && garden[$i]="." && echo "Picked tomato from plot $((i+1))"
        [[ ${garden[$i]} == **flower** ]] && garden[$i]="." && echo "Cut flower from plot $((i+1))"
      done
      ;;
    4) exit ;;
    *) echo "Invalid option" ;;
  esac
  sleep 1
done
