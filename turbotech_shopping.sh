#!/bin/bash
# TechBazaar - Terminal Phone Store

# Database files
PRODUCTS_DB="products.db"
USERS_DB="users.db"
ORDERS_DB="orders.db"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize databases if they don't exist
init_db() {
  [[ ! -f "$PRODUCTS_DB" ]] && {
    echo "Creating product database..."
    cat > "$PRODUCTS_DB" <<EOF
1|iPhone 15 Pro|Apple|999|10|6.1-inch Super Retina, A17 Pro, 128GB
2|Galaxy S23 Ultra|Samsung|1199|15|6.8-inch AMOLED, Snapdragon 8 Gen 2, 256GB
3|Pixel 8 Pro|Google|999|8|6.7-inch OLED, Tensor G3, 128GB
4|OnePlus 11|OnePlus|699|12|6.7-inch Fluid AMOLED, Snapdragon 8 Gen 2, 256GB
5|Xperia 1 V|Sony|1399|5|6.5-inch 4K OLED, Snapdragon 8 Gen 2, 256GB
EOF
  }

  [[ ! -f "$USERS_DB" ]] && touch "$USERS_DB"
  [[ ! -f "$ORDERS_DB" ]] && touch "$ORDERS_DB"
}

# Main menu
main_menu() {
  clear
  echo -e "${GREEN}TechBazaar - Phone Store${NC}"
  echo -e "${BLUE}1. Browse Products"
  echo "2. View Cart"
  echo "3. Checkout"
  echo "4. Account"
  echo -e "5. Exit${NC}"
  read -p "Choose an option: " choice

  case $choice in
    1) browse_products ;;
    2) view_cart ;;
    3) checkout ;;
    4) account_menu ;;
    5) exit 0 ;;
    *) echo -e "${RED}Invalid option!${NC}"; sleep 1; main_menu ;;
  esac
}

# Product browsing
browse_products() {
  clear
  echo -e "${YELLOW}Available Phones${NC}"
  echo "------------------------------------------------------------"
  printf "%-3s | %-20s | %-10s | %-8s | %-5s | %-30s\n" "ID" "Name" "Brand" "Price" "Stock" "Specs"
  echo "------------------------------------------------------------"
  
  while IFS='|' read -r id name brand price stock specs; do
    printf "%-3s | %-20s | %-10s | \$%-7s | %-5s | %-30s\n" "$id" "$name" "$brand" "$price" "$stock" "$specs"
  done < "$PRODUCTS_DB"
  
  echo "------------------------------------------------------------"
  echo -e "${BLUE}1. Add to cart"
  echo "2. Search products"
  echo -e "3. Back to menu${NC}"
  read -p "Choose an option: " choice

  case $choice in
    1) add_to_cart ;;
    2) search_products ;;
    3) main_menu ;;
    *) echo -e "${RED}Invalid option!${NC}"; sleep 1; browse_products ;;
  esac
}

# Add to cart function
add_to_cart() {
  read -p "Enter product ID to add to cart: " product_id
  read -p "Enter quantity: " quantity

  # Validate input is numeric
  if ! [[ "$product_id" =~ ^[0-9]+$ ]] || ! [[ "$quantity" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Please enter valid numbers!${NC}"
    sleep 1
    browse_products
    return
  fi

  # Validate product exists
  if ! grep -q "^$product_id|" "$PRODUCTS_DB"; then
    echo -e "${RED}Product not found!${NC}"
    sleep 1
    browse_products
    return
  fi

  # Get product details
  IFS='|' read -r id name brand price stock specs <<< "$(grep "^$product_id|" "$PRODUCTS_DB")"

  # Check stock
  if [[ $quantity -gt $stock ]]; then
    echo -e "${RED}Not enough stock available!${NC}"
    sleep 1
    browse_products
    return
  fi

  # Add to cart (in memory array)
  cart+=("$id|$name|$price|$quantity")
  echo -e "${GREEN}Added to cart: $name x$quantity${NC}"
  sleep 1
  browse_products
}

# View cart
view_cart() {
  clear
  if [[ ${#cart[@]} -eq 0 ]]; then
    echo -e "${YELLOW}Your cart is empty${NC}"
    sleep 1
    main_menu
    return
  fi

  echo -e "${YELLOW}Your Shopping Cart${NC}"
  echo "------------------------------------------------------------"
  printf "%-3s | %-20s | %-8s | %-5s | %-8s\n" "ID" "Name" "Price" "Qty" "Total"
  echo "------------------------------------------------------------"

  total=0
  for item in "${cart[@]}"; do
    IFS='|' read -r id name price quantity <<< "$item"
    item_total=$((price * quantity))
    printf "%-3s | %-20s | \$%-7s | %-5s | \$%-7s\n" "$id" "$name" "$price" "$quantity" "$item_total"
    total=$((total + item_total))
  done

  echo "------------------------------------------------------------"
  echo -e "${GREEN}Total: \$$total${NC}"
  echo -e "${BLUE}1. Remove item"
  echo "2. Update quantity"
  echo "3. Checkout"
  echo -e "4. Back to menu${NC}"
  read -p "Choose an option: " choice

  case $choice in
    1) remove_from_cart ;;
    2) update_quantity ;;
    3) checkout ;;
    4) main_menu ;;
    *) echo -e "${RED}Invalid option!${NC}"; sleep 1; view_cart ;;
  esac
}

remove_from_cart() {
  read -p "Enter product ID to remove: " product_id
  new_cart=()
  removed=0

  for item in "${cart[@]}"; do
    IFS='|' read -r id name price quantity <<< "$item"
    if [[ "$id" != "$product_id" ]]; then
      new_cart+=("$item")
    else
      removed=1
    fi
  done

  if [[ $removed -eq 1 ]]; then
    cart=("${new_cart[@]}")
    echo -e "${GREEN}Product removed from cart${NC}"
  else
    echo -e "${RED}Product not found in cart${NC}"
  fi
  sleep 1
  view_cart
}

update_quantity() {
  read -p "Enter product ID to update: " product_id
  read -p "Enter new quantity: " new_quantity

  if ! [[ "$new_quantity" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Please enter a valid number!${NC}"
    sleep 1
    view_cart
    return
  fi

  # Check stock
  IFS='|' read -r stock_id stock_name stock_price stock_available stock_specs <<< "$(grep "^$product_id|" "$PRODUCTS_DB")"
  if [[ $new_quantity -gt $stock_available ]]; then
    echo -e "${RED}Not enough stock available!${NC}"
    sleep 1
    view_cart
    return
  fi

  for i in "${!cart[@]}"; do
    IFS='|' read -r id name price quantity <<< "${cart[$i]}"
    if [[ "$id" == "$product_id" ]]; then
      cart[$i]="$id|$name|$price|$new_quantity"
      echo -e "${GREEN}Quantity updated${NC}"
      sleep 1
      view_cart
      return
    fi
  done

  echo -e "${RED}Product not found in cart${NC}"
  sleep 1
  view_cart
}

# Checkout process
checkout() {
  if [[ ${#cart[@]} -eq 0 ]]; then
    echo -e "${RED}Your cart is empty!${NC}"
    sleep 1
    main_menu
    return
  fi

  clear
  echo -e "${YELLOW}Checkout${NC}"
  
  # Calculate total
  total=0
  for item in "${cart[@]}"; do
    IFS='|' read -r id name price quantity <<< "$item"
    total=$((total + price * quantity))
  done

  echo -e "Total: ${GREEN}\$$total${NC}"
  echo -e "${BLUE}1. Guest checkout"
  echo "2. Login"
  echo -e "3. Register${NC}"
  read -p "Choose an option: " choice

  case $choice in
    1) guest_checkout ;;
    2) login ;;
    3) register ;;
    *) echo -e "${RED}Invalid option!${NC}"; sleep 1; checkout ;;
  esac
}

# Guest checkout
guest_checkout() {
  echo -e "${YELLOW}Guest Checkout${NC}"
  read -p "Enter your email: " email
  read -p "Enter shipping address: " address
  read -p "Enter payment method (cash/credit): " payment

  # Validate payment method
  if [[ "$payment" != "cash" && "$payment" != "credit" ]]; then
    echo -e "${RED}Please enter either 'cash' or 'credit'${NC}"
    sleep 1
    checkout
    return
  fi

  # Save order
  order_id=$(date +%s)
  for item in "${cart[@]}"; do
    IFS='|' read -r id name price quantity <<< "$item"
    echo "$order_id|guest|$email|$id|$name|$price|$quantity|$address|$payment|$(date +%F)" >> "$ORDERS_DB"
    
    # Update stock
    awk -F'|' -v id="$id" -v qty="$quantity" '
      BEGIN { OFS="|" }
      $1 == id { $5 = $5 - qty } 
      { print }
    ' "$PRODUCTS_DB" > temp && mv temp "$PRODUCTS_DB"
  done

  echo -e "${GREEN}Order placed successfully! Order ID: $order_id${NC}"
  cart=()
  sleep 2
  main_menu
}

# Account management
account_menu() {
  clear
  echo -e "${YELLOW}Account${NC}"
  echo -e "${BLUE}1. Login"
  echo "2. Register"
  echo -e "3. Back to menu${NC}"
  read -p "Choose an option: " choice

  case $choice in
    1) login ;;
    2) register ;;
    3) main_menu ;;
    *) echo -e "${RED}Invalid option!${NC}"; sleep 1; account_menu ;;
  esac
}

login() {
  echo -e "${YELLOW}Login${NC}"
  read -p "Enter email: " email
  read -p "Enter password: " password

  # Simple validation
  if [[ -z "$email" || -z "$password" ]]; then
    echo -e "${RED}Email and password are required!${NC}"
    sleep 1
    account_menu
    return
  fi

  # Check user exists (simplified)
  if grep -q "^$email|" "$USERS_DB"; then
    echo -e "${GREEN}Login successful${NC}"
    sleep 1
    main_menu
  else
    echo -e "${RED}Invalid credentials${NC}"
    sleep 1
    account_menu
  fi
}

register() {
  echo -e "${YELLOW}Register${NC}"
  read -p "Enter email: " email
  read -p "Enter password: " password
  read -p "Confirm password: " password2

  # Validate inputs
  if [[ -z "$email" || -z "$password" ]]; then
    echo -e "${RED}Email and password are required!${NC}"
    sleep 1
    account_menu
    return
  fi

  if [[ "$password" != "$password2" ]]; then
    echo -e "${RED}Passwords don't match!${NC}"
    sleep 1
    account_menu
    return
  fi

  # Check if user already exists
  if grep -q "^$email|" "$USERS_DB"; then
    echo -e "${RED}User already exists!${NC}"
    sleep 1
    account_menu
    return
  fi

  # Save user (insecure - just for demo)
  echo "$email|$password" >> "$USERS_DB"
  echo -e "${GREEN}Registration successful!${NC}"
  sleep 1
  account_menu
}

# Search products
search_products() {
  clear
  read -p "Enter search term: " term
  if [[ -z "$term" ]]; then
    echo -e "${RED}Please enter a search term${NC}"
    sleep 1
    browse_products
    return
  fi

  echo -e "${YELLOW}Search Results for '$term'${NC}"
  echo "------------------------------------------------------------"
  
  grep -i "$term" "$PRODUCTS_DB" | while IFS='|' read -r id name brand price stock specs; do
    printf "%-3s | %-20s | %-10s | \$%-7s | %-5s | %-30s\n" "$id" "$name" "$brand" "$price" "$stock" "$specs"
  done
  
  echo "------------------------------------------------------------"
  read -p "Press enter to continue..."
  browse_products
}

# Main program
init_db
declare -a cart=()
main_menu
