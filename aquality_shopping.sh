#!/bin/bash

# Aquility Shopping App
# A simple command-line shopping application

# Database files
ITEMS_DB="items.db"
CART_DB="cart.db"

# Initialize databases if they don't exist
init_db() {
    if [ ! -f "$ITEMS_DB" ]; then
        echo "Creating items database..."
        echo "ID|Name|Price|Stock" > "$ITEMS_DB"
        echo "1|Laptop|999.99|10" >> "$ITEMS_DB"
        echo "2|Smartphone|699.99|15" >> "$ITEMS_DB"
        echo "3|Headphones|149.99|20" >> "$ITEMS_DB"
        echo "4|Tablet|349.99|8" >> "$ITEMS_DB"
        echo "5|Smartwatch|199.99|12" >> "$ITEMS_DB"
    fi

    if [ ! -f "$CART_DB" ]; then
        echo "Creating cart database..."
        echo "ID|Name|Price|Quantity" > "$CART_DB"
    fi
}

# Display available items
show_items() {
    echo -e "\nAvailable Items:"
    echo "----------------------------------------"
    printf "%-5s %-15s %-10s %-5s\n" "ID" "Name" "Price" "Stock"
    echo "----------------------------------------"
    
    tail -n +2 "$ITEMS_DB" | while IFS='|' read -r id name price stock; do
        printf "%-5s %-15s %-10s %-5s\n" "$id" "$name" "$price" "$stock"
    done
}

# Add item to cart
add_to_cart() {
    local item_id=$1
    local quantity=$2
    
    # Check if item exists
    if ! grep -q "^$item_id|" "$ITEMS_DB"; then
        echo "Error: Item ID $item_id not found."
        return 1
    fi
    
    # Get item details
    IFS='|' read -r id name price stock <<< "$(grep "^$item_id|" "$ITEMS_DB")"
    
    # Check stock
    if [ "$stock" -lt "$quantity" ]; then
        echo "Error: Not enough stock. Only $stock available."
        return 1
    fi
    
    # Check if item already in cart
    if grep -q "^$id|" "$CART_DB"; then
        # Update quantity
        current_qty=$(grep "^$id|" "$CART_DB" | cut -d'|' -f4)
        new_qty=$((current_qty + quantity))
        sed -i "/^$id|/d" "$CART_DB"
        echo "$id|$name|$price|$new_qty" >> "$CART_DB"
    else
        # Add new item to cart
        echo "$id|$name|$price|$quantity" >> "$CART_DB"
    fi
    
    echo "Added $quantity x $name to cart."
}

# View cart
view_cart() {
    local total=0
    
    echo -e "\nYour Shopping Cart:"
    echo "----------------------------------------"
    printf "%-5s %-15s %-10s %-8s %-10s\n" "ID" "Name" "Price" "Qty" "Subtotal"
    echo "----------------------------------------"
    
    tail -n +2 "$CART_DB" | while IFS='|' read -r id name price qty; do
        subtotal=$(echo "$price * $qty" | bc)
        printf "%-5s %-15s %-10s %-8s %-10s\n" "$id" "$name" "$price" "$qty" "$subtotal"
        total=$(echo "$total + $subtotal" | bc)
    done
    
    echo "----------------------------------------"
    printf "Total: $%.2f\n" "$total"
    echo "----------------------------------------"
}

# Checkout
checkout() {
    if [ ! -s "$CART_DB" ] || [ $(wc -l < "$CART_DB") -le 1 ]; then
        echo "Your cart is empty. Nothing to checkout."
        return
    fi
    
    view_cart
    
    read -p "Confirm checkout (y/n)? " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        # Update stock levels
        tail -n +2 "$CART_DB" | while IFS='|' read -r id name price qty; do
            current_stock=$(grep "^$id|" "$ITEMS_DB" | cut -d'|' -f4)
            new_stock=$((current_stock - qty))
            sed -i "/^$id|/d" "$ITEMS_DB"
            grep "^$id|" "$ITEMS_DB" | while IFS='|' read -r id2 name2 price2 stock2; do
                echo "$id2|$name2|$price2|$new_stock" >> "$ITEMS_DB.tmp"
            done
            mv "$ITEMS_DB.tmp" "$ITEMS_DB"
        done
        
        # Clear cart
        echo "ID|Name|Price|Quantity" > "$CART_DB"
        echo "Thank you for your purchase!"
    else
        echo "Checkout cancelled."
    fi
}

# Remove item from cart
remove_from_cart() {
    local item_id=$1
    
    if ! grep -q "^$item_id|" "$CART_DB"; then
        echo "Error: Item ID $item_id not found in cart."
        return 1
    fi
    
    item_name=$(grep "^$item_id|" "$CART_DB" | cut -d'|' -f2)
    sed -i "/^$item_id|/d" "$CART_DB"
    echo "Removed $item_name from cart."
}

# Main menu
main_menu() {
    while true; do
        echo -e "\nAquility Shopping App"
        echo "1. Browse Products"
        echo "2. View Cart"
        echo "3. Checkout"
        echo "4. Exit"
        
        read -p "Enter your choice: " choice
        
        case $choice in
            1)
                show_items
                echo -e "\nOptions:"
                echo "a. Add item to cart"
                echo "b. Back to main menu"
                
                read -p "Enter your choice: " browse_choice
                
                if [ "$browse_choice" = "a" ]; then
                    read -p "Enter item ID: " item_id
                    read -p "Enter quantity: " quantity
                    add_to_cart "$item_id" "$quantity"
                fi
                ;;
            2)
                if [ ! -s "$CART_DB" ] || [ $(wc -l < "$CART_DB") -le 1 ]; then
                    echo "Your cart is empty."
                else
                    view_cart
                    echo -e "\nOptions:"
                    echo "a. Remove item from cart"
                    echo "b. Back to main menu"
                    
                    read -p "Enter your choice: " cart_choice
                    
                    if [ "$cart_choice" = "a" ]; then
                        read -p "Enter item ID to remove: " item_id
                        remove_from_cart "$item_id"
                    fi
                fi
                ;;
            3)
                checkout
                ;;
            4)
                echo "Thank you for using Aquility. Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}

# Initialize the app
init_db
main_menu
