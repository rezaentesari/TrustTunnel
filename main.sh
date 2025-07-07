#!/bin/bash

# Define colors for better terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
RESET='\033[0m' # No Color

# --- New: Uninstall TrustTunnel Action ---
uninstall_trusttunnel_action() {
  clear
  echo ""
  echo -e "${RED}⚠️ Are you sure you want to uninstall TrustTunnel and remove all associated files and services? (y/N): ${RESET}"
  read -p "" confirm
  echo ""

  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "🧹 Uninstalling TrustTunnel..."

    # Find and remove all trusttunnel-* services
    echo "Searching for TrustTunnel services to remove..."
    # List all unit files that start with 'trusttunnel-'
    mapfile -t trusttunnel_services < <(sudo systemctl list-unit-files --full --no-pager | grep '^trusttunnel-.*\.service' | awk '{print $1}')

    if [ ${#trusttunnel_services[@]} -gt 0 ]; then
      echo "🛑 Stopping and disabling TrustTunnel services..."
      for service_file in "${trusttunnel_services[@]}"; do
        local service_name=$(basename "$service_file") # Get just the service name from the file path
        echo "  - Processing $service_name..."
        sudo systemctl stop "$service_name" > /dev/null 2>&1
        sudo systemctl disable "$service_name" > /dev/null 2>&1
        sudo rm -f "/etc/systemd/system/$service_name" > /dev/null 2>&1
      done
      sudo systemctl daemon-reload
      print_success "All TrustTunnel services have been stopped, disabled, and removed."
    else
      echo "⚠️ No TrustTunnel services found to remove."
    fi

    # Remove rstun folder if exists
    if [ -d "rstun" ]; then
      echo "🗑️ Removing 'rstun' folder..."
      rm -rf rstun
      print_success "'rstun' folder removed successfully."
    else
      echo "⚠️ 'rstun' folder not found."
    fi

    print_success "TrustTunnel uninstallation complete."
  else
    echo -e "${YELLOW}❌ Uninstall cancelled.${RESET}"
  fi
  echo ""
  echo -e "${YELLOW}Press Enter to return to main menu...${RESET}"
  read -p ""
}
install_trusttunnel_action() {
  clear
  echo ""
  draw_line "$CYAN" "=" 40
  echo -e "${CYAN}        📥 Installing TrustTunnel${RESET}"
  draw_line "$CYAN" "=" 40
  echo ""

  # Delete existing rstun folder if it exists
  if [ -d "rstun" ]; then
    echo -e "${YELLOW}🧹 Removing existing 'rstun' folder...${RESET}"
    rm -rf rstun
    print_success "Existing 'rstun' folder removed."
  fi

  echo -e "${CYAN}🚀 Detecting system architecture...${RESET}"
  local arch=$(uname -m)
  local download_url=""
  local filename=""
  local supported_arch=true # Flag to track if architecture is directly supported

  case "$arch" in
    "x86_64")
      filename="rstun-linux-x86_64.tar.gz"
      ;;
    "aarch64" | "arm64")
      filename="rstun-linux-aarch64.tar.gz"
      ;;
    "armv7l") # Corrected filename for armv7l
      filename="rstun-linux-armv7.tar.gz"
      ;;
    *)
      supported_arch=false # Mark as unsupported
      echo -e "${RED}❌ Error: Unsupported architecture detected: $arch${RESET}"
      echo -e "${YELLOW}Do you want to try installing the x86_64 version as a fallback? (y/N): ${RESET}"
      read -p "" fallback_confirm
      echo ""
      if [[ "$fallback_confirm" =~ ^[Yy]$ ]]; then
        filename="rstun-linux-x86_64.tar.gz"
        echo -e "${CYAN}Proceeding with x86_64 version as requested.${RESET}"
      else
        echo -e "${YELLOW}Installation cancelled. Please download rstun manually for your system from https://github.com/neevek/rstun/releases${RESET}"
        echo ""
        echo -e "${YELLOW}Press Enter to return to main menu...${RESET}"
        read -p ""
        return 1 # Indicate failure
      fi
      ;;
  esac

  download_url="https://github.com/neevek/rstun/releases/download/release%2F0.7.1/${filename}"

  echo -e "${CYAN}Downloading $filename for $arch...${RESET}"
  if wget -q --show-progress "$download_url" -O "$filename"; then
    print_success "Download complete!"
  else
    echo -e "${RED}❌ Error: Failed to download $filename. Please check your internet connection or the URL.${RESET}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to main menu...${RESET}"
    read -p ""
    return 1 # Indicate failure
  fi

  echo -e "${CYAN}📦 Extracting files...${RESET}"
  if tar -xzf "$filename"; then
    mv "${filename%.tar.gz}" rstun # Rename extracted folder to 'rstun'
    print_success "Extraction complete!"
  else
    echo -e "${RED}❌ Error: Failed to extract $filename. Corrupted download?${RESET}"
    echo ""
    echo -e "${YELLOW}Press Enter to return to main menu...${RESET}"
    read -p ""
    return 1 # Indicate failure
  fi

  echo -e "${CYAN}➕ Setting execute permissions...${RESET}"
  find rstun -type f -exec chmod +x {} \;
  print_success "Permissions set."

  echo -e "${CYAN}🗑️ Cleaning up downloaded archive...${RESET}"
  rm "$filename"
  print_success "Cleanup complete."

  echo ""
  print_success "TrustTunnel installation complete!"
  echo ""
  echo -e "${YELLOW}Press Enter to return to main menu...${RESET}"
  read -p ""
}
# Function to draw a colored line for menu separation
draw_line() {
  local color="$1"
  local char="$2"
  local length=${3:-40} # Default length 40 if not provided
  printf "${color}"
  for ((i=0; i<length; i++)); do
    printf "$char"
  done
  printf "${RESET}\n"
}

# Function to print success messages in green
print_success() {
  local message="$1"
  echo -e "\033[0;32m✅ $message\033[0m" # Green color for success messages
}

# Function to show service logs and return to a "menu"
show_service_logs() {
  local service_name="$1"
  clear # Clear the screen before showing logs
  echo -e "\033[0;34m--- Displaying logs for $service_name ---\033[0m" # Blue color for header

  # Display the last 50 lines of logs for the specified service
  # --no-pager ensures the output is direct to the terminal without opening 'less'
  sudo journalctl -u "$service_name" -n 50 --no-pager

  echo ""
  echo -e "\033[1;33mPress any key to return to the previous menu...\033[0m" # Yellow color for prompt
  read -n 1 -s -r # Read a single character, silent, raw input

  clear 
}




draw_green_line() {
  echo -e "${GREEN}+--------------------------------------------------------+${RESET}"
}


set -e

# Install required tools
sudo apt update
sudo apt install -y build-essential curl pkg-config libssl-dev git figlet certbot rustc cargo

# Default path for the Cargo environment file.
CARGO_ENV_FILE="$HOME/.cargo/env"

echo "Checking for Rust installation..."

# Check if 'rustc' command is available in the system's PATH.
if command -v rustc >/dev/null 2>&1; then
  # If 'rustc' is found, Rust is already installed.
  echo "✅ Rust is already installed: $(rustc --version)"
  RUST_IS_READY=true
else
  # If 'rustc' is not found, start the installation.
  echo "🦀 Rust is not installed. Installing..."
  RUST_IS_READY=false

  # Download and run the rustup installer.
  if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
    echo "✅ Rust installed successfully."

    # Source the Cargo environment file for the current script session.
    if [ -f "$CARGO_ENV_FILE" ]; then
      source "$CARGO_ENV_FILE"
      echo "♻️ Cargo environment file sourced for this script session."
    else
      # Fallback if the environment file is not found.
      echo "⚠️ Cargo environment file ($CARGO_ENV_FILE) not found. You might need to set PATH manually."
      export PATH="$HOME/.cargo/bin:$PATH"
    fi

    # Display the installed version for confirmation.
    if command -v rustc >/dev/null 2>&1; then
      echo "✅ Installed Rust version: $(rustc --version)"
      RUST_IS_READY=true
    else
      echo "❌ Rust is installed but 'rustc' is not available in the current PATH."
    fi

    echo ""
    echo "------------------------------------------------------------------"
    echo "⚠️ Important: To make Rust available in your terminal,"
    echo "    you need to restart your terminal or run this command:"
    echo "    source \"$CARGO_ENV_FILE\""
    echo "    Run this command once in each new terminal session."
    echo "------------------------------------------------------------------"

  else
    # Error message if installation fails.
    echo "❌ An error occurred during Rust installation. Please check your internet connection or try again."
  fi
fi

# --- Continue with the rest of the script if Rust is ready ---
if [ "$RUST_IS_READY" = true ]; then
  echo ""
  echo "🚀 Rust is ready. Continuing with the rest of your script..."
  # Add your subsequent commands here. For example:
  # rustc --version
  # cargo new my_rust_project
  # cd my_rust_project
  # cargo run
  echo "This is a placeholder for the rest of your script."
  echo "You can replace these lines with your actual Rust-related commands."
else
  echo ""
  echo "🛑 Rust is not ready. Skipping the rest of the script."
fi

if [ "$RUST_IS_READY" = true ]; then
while true; do
  # Clear terminal and show logo
  clear
  echo -e "${CYAN}"
  figlet -f slant "TrustTunnel"
  echo -e "${CYAN}"
  echo -e "\033[1;33m=========================================================="
  echo -e "Developed by ErfanXRay => https://github.com/Erfan-XRay/TrustTunnel"
  echo -e "Telegram Channel => @Erfan_XRay"
  echo -e "\033[0m${WHITE}Reverse tunnel over QUIC ( Based on rstun project)${WHITE}${RESET}"
  draw_green_line
  echo -e "${GREEN}|${RESET}              ${BOLD_GREEN}TrustTunnel Main Menu${RESET}                  ${GREEN}|${RESET}"
  draw_green_line
  # Menu
  echo "Select an option:"
  echo -e "${MAGENTA}1) Install TrustTunnel${RESET}"
  echo -e "${CYAN}2) Tunnel Management${RESET}"
  echo -e "${RED}3) Uninstall TrustTunnel${RESET}"
  echo "4) Exit"
  read -p "👉 Your choice: " choice

  case $choice in
    1)
      install_trusttunnel_action
      ;;
    2)
    clear # Clear screen for a fresh menu display
    echo ""
    draw_line "$GREEN" "=" 40 # Top border
    echo -e "${CYAN}        🌐 Choose Tunnel Mode${RESET}"
    draw_line "$GREEN" "=" 40 # Separator
    echo ""
    echo -e "  ${YELLOW}1)${RESET} ${MAGENTA}Server (Iran)${RESET}" # Magenta for Server
    echo -e "  ${YELLOW}2)${RESET} ${BLUE}Client (Kharej)${RESET}" # Blue for Client
    echo -e "  ${YELLOW}3)${RESET} ${WHITE}Return to main menu${RESET}" # White for generic option
    echo ""
    draw_line "$GREEN" "-" 40 # Bottom border
    echo -e "👉 ${CYAN}Your choice:${RESET} " # Moved prompt to echo -e
    read -p "" tunnel_choice # Removed prompt from read -p
    echo "" # Add a blank line for better spacing after input

      case $tunnel_choice in
        1)
          clear

          # زیرمنوی مدیریت سرور
          while true; do
              clear # Clear screen for a fresh menu display
              echo ""
              draw_line "$GREEN" "=" 40 # Top border
              echo -e "${CYAN}        🔧 TrustTunnel Server Management${RESET}"
              draw_line "$GREEN" "=" 40 # Separator
              echo ""
              echo -e "  ${YELLOW}1)${RESET} ${WHITE}Add new server${RESET}"
              echo -e "  ${YELLOW}2)${RESET} ${WHITE}Show service logs${RESET}"
              echo -e "  ${YELLOW}3)${RESET} ${WHITE}Delete service${RESET}"
              echo -e "  ${YELLOW}4)${RESET} ${WHITE}Back to main menu${RESET}"
              echo ""
              draw_line "$GREEN" "-" 40 # Bottom border
              echo -e "👉 ${CYAN}Your choice:${RESET} " 
              read -p "" srv_choice 
              echo "" 
            case $srv_choice in
              1)

              clear


          if [ ! -f "rstun/rstund" ]; then
            echo "❗ Server build not found. Please run option 1 first."
            read -p "Press Enter to return to main menu..."
            continue
          fi
          read -p "🌐 Please enter your domain pointed to this server (e.g., server.example.com): " domain
          read -p "🌐 Please enter your email: " email
          cert_path="/etc/letsencrypt/live/$domain"
          if [ -d "$cert_path" ]; then
            echo "✅ SSL certificate for $domain already exists. Skipping Certbot."
          else
            echo "🔐 Requesting SSL certificate with Certbot..."
            sudo certbot certonly --standalone -d "$domain" --non-interactive --agree-tos -m "$email"
          fi


          if [ -d "$cert_path" ]; then
            echo "✅ SSL certificate obtained successfully."


            read -p "Enter tunneling address port (default = 6060): " listen_port
            listen_port=${listen_port:-6060}  
            read -p "Enter tcp upstream port (default = 8800): " tcp_upstream_port
            tcp_upstream_port=${tcp_upstream_port:-8800}  
            read -p "Enter udp upstream port (default = 8800): " udp_upstream_port
            udp_upstream_port=${udp_upstream_port:-8800}  
            read -p "Enter password: " password
            if [[ -z "$password" ]]; then
              echo "❌ Password cannot be empty!"
              exit 1
            fi

            

            cert_path="/etc/letsencrypt/live/$domain"

            if systemctl is-active --quiet trusttunnel.service || systemctl is-enabled --quiet trusttunnel.service; then
              echo "🛑 Stopping existing Trusttunnel service..."
              sudo systemctl stop trusttunnel.service
              echo "🗑️ Disabling and removing existing Trusttunnel service..."
              sudo systemctl disable trusttunnel.service
              sudo rm -f /etc/systemd/system/trusttunnel.service
              sudo systemctl daemon-reload
            fi

            service_file="/etc/systemd/system/trusttunnel.service"

cat <<EOF | sudo tee $service_file
              [Unit]
              Description=TrustTunnel Service
              After=network.target

              [Service]
              Type=simple
              ExecStart=$(pwd)/rstun/rstund --addr 0.0.0.0:$listen_port --tcp-upstream $tcp_upstream_port   --udp-upstream $udp_upstream_port  --password $password --cert $cert_path/fullchain.pem --key $cert_path/privkey.pem
              Restart=always
              RestartSec=5
              User=$(whoami)

              [Install]
              WantedBy=multi-user.target
EOF

          echo "🔧 Reloading systemd daemon..."
          sudo systemctl daemon-reload

          echo "🚀 Enabling and starting Trusttunnel service..."
          sudo systemctl enable trusttunnel.service
          sudo systemctl start trusttunnel.service

          echo "✅ TrustTunnel service started!"





          else
            echo "❌ Failed to obtain SSL certificate. Cant start server without ssl ..."
          fi

          ;;
          2)
           clear
          # Show service logs
                service_file="/etc/systemd/system/trusttunnel.service"
                if [ -f "$service_file" ]; then
                  show_service_logs "trusttunnel.service"
                else
                  echo "❌ Service 'trusttunnel.service' not found. Cannot show logs."
                  
                fi
                break
          ;;
          3)
           clear
          service_file="/etc/systemd/system/trusttunnel.service"
                if [ -f "$service_file" ]; then
                  echo "🛑 Stopping and deleting trusttunnel.service..."
                  sudo systemctl stop trusttunnel.service
                  sudo systemctl disable trusttunnel.service
                  sudo rm -f "$service_file"
                  sudo systemctl daemon-reload
                  echo "✅ Service deleted."
                else
                  echo "❌ Service 'trusttunnel.service' not found. Nothing to delete."
                fi
                break
          ;;

          4)
            break
          ;;

          *)
            echo "❌ Invalid option."
          ;;
          esac
          done
          ;;
        2)
          clear
           
        while true; do
          clear # Clear screen for a fresh menu display
          echo ""
          draw_line "$GREEN" "=" 40 # Top border
          echo -e "${CYAN}        📡 TrustTunnel Client Management${RESET}"
          draw_line "$GREEN" "=" 40 # Separator
          echo ""
          echo -e "  ${YELLOW}1)${RESET} ${WHITE}Add new client${RESET}"
          echo -e "  ${YELLOW}2)${RESET} ${WHITE}Show Client Log${RESET}"
          echo -e "  ${YELLOW}3)${RESET} ${WHITE}Delete a client${RESET}"
          echo -e "  ${YELLOW}4)${RESET} ${WHITE}Back to main menu${RESET}"
          echo ""
          draw_line "$GREEN" "-" 40 # Bottom border
          echo -e "👉 ${CYAN}Your choice:${RESET} " 
          read -p "" client_choice 
          echo "" 

          case $client_choice in
            1)
            clear
        # اضافه کردن کلاینت جدید
        read -p "Enter client name (e.g., asiatech, respina, server2): " client_name
        service_name="trusttunnel-$client_name"
        service_file="/etc/systemd/system/${service_name}.service"

        if [ -f "$service_file" ]; then
          echo "❌ Service with this name already exists."
          continue
        fi

        read -p "🌐 Server address and port (e.x., server.yourdomain.com:6060): " server_addr
        read -p "Tunnel mode ? (tcp/udp/both): " tunnel_mode
        read -p "🔑 Password: " password
        read -p "🔢 How many ports to tunnel? " port_count
        
        mappings=""
        for ((i=1; i<=port_count; i++)); do
          read -p "Port #$i: " port
          mapping="IN^0.0.0.0:$port^0.0.0.0:$port"
          [ -z "$mappings" ] && mappings="$mapping" || mappings="$mappings,$mapping"
        done

        # Determine the mapping arguments based on the tunnel_mode
        mapping_args=""
        case "$tunnel_mode" in
          "tcp")
            mapping_args="--tcp-mappings \"$mappings\""
            ;;
          "udp")
            mapping_args="--udp-mappings \"$mappings\""
            ;;
          "both")
            mapping_args="--tcp-mappings \"$mappings\" --udp-mappings \"$mappings\""
            ;;
          *)
            echo "⚠️ Invalid tunnel mode specified. Using 'both' as default."
            mapping_args="--tcp-mappings \"$mappings\" --udp-mappings \"$mappings\""
            ;;
        esac



cat <<EOF | sudo tee $service_file
[Unit]
Description=TrustTunnel Client - $client_name
After=network.target

[Service]
Type=simple
ExecStart=$(pwd)/rstun/rstunc --server-addr "$server_addr" --password "$password" $mapping_args
Restart=always
RestartSec=5
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOF

        sudo systemctl daemon-reload
        sudo systemctl enable "$service_name"
        sudo systemctl start "$service_name"
        print_success "Client '$client_name' started as $service_name"
        read -p "Do you want to view the logs for $client_name now? (y/n): " view_logs_choice
        if [[ "$view_logs_choice" =~ ^[Yy]$ ]]; then
          show_service_logs "$service_name"
        fi
        break;
        ;;
      2)
        clear
        echo "🔍 Searching for clients ..."

        # List all systemd services that start with trusttunnel-
        services=($(systemctl list-units --type=service --all | grep 'trusttunnel-' | awk '{print $1}' | sed 's/.service$//'))

        if [ ${#services[@]} -eq 0 ]; then
            echo "❌ No clients found."
            break
        fi

        echo "📋 Please select a service to see log:"
        select selected_service in "${services[@]}"; do
            if [ -n "$selected_service" ]; then
                show_service_logs "$selected_service"
                break
            else
                echo "⚠️ Invalid selection. Please enter a valid number."
            fi
        done
        break
        ;;
      3)
      

          clear
          echo "🔍 Searching for clients ..."

          # List all systemd services that start with trusttunnel-
          services=($(systemctl list-units --type=service --all | grep 'trusttunnel-' | awk '{print $1}' | sed 's/.service$//'))
          
          if [ ${#services[@]} -eq 0 ]; then
              echo "❌ No clients found."
              break
          fi

          echo "📋 Please select a service to delete:"
          select selected_service in "${services[@]}"; do
              if [ -n "$selected_service" ]; then
                  service_file="/etc/systemd/system/${selected_service}.service"
                  echo "🛑 Stopping $selected_service..."
                  sudo systemctl stop "$selected_service"
                  echo "🗑️ Disabling $selected_service..."
                  sudo systemctl disable "$selected_service"
                  echo "🗑️ Removing service file..."
                  sudo rm -f "$service_file"
                  sudo systemctl daemon-reload
                  echo "✅ Client '$selected_service' deleted."
                  break
              else
                  echo "⚠️ Invalid selection. Please enter a valid number."
              fi
          done
          break
        ;;

      4)
          break
        ;;
      *)
        echo "❌ Invalid option."
        ;;
          esac

          echo ""
          read -p "Press Enter to continue..."
        done

                esac
      ;;
    3)
          uninstall_trusttunnel_action ;;
   

    4)
        exit 0 
        break
    ;;
    *)
      echo "❌ Invalid choice. Exiting."
      ;;
  esac
  echo ""
  read -p "Press Enter to return to main menu..."
done
else
echo ""
  echo "🛑 Rust is not ready. Skipping the rest of the script."
fi


