#!/bin/bash
GREEN="\e[32m"
BOLD_GREEN="\e[1;32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
MAGENTA="\e[35m"
WHITE="\e[37m"
RED="\e[31m"
RESET="\e[0m"

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
  echo -e "${BOLD_GREEN}"
  figlet -f slant "TrustTunnel"
  echo -e "${BOLD_GREEN}"
  echo -e "\033[1;33m=========================================================="
  echo -e "Developed by ErfanXRay => https://t.me/Erfan_XRay"
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
      clear
      # Delete existing rstun folder if it exists
      if [ -d "rstun" ]; then
        echo "🧹 Removing existing 'TrustTunnel' folder..."
        rm -rf rstun
      fi
      echo "📥 Installing TrustTunnel..."
      wget https://github.com/neevek/rstun/releases/download/release%2F0.7.1/rstun-linux-x86_64.tar.gz
      tar -xzf rstun-linux-x86_64.tar.gz
      mv rstun-linux-x86_64 rstun
      find rstun -type f -exec chmod +x {} \;
      rm rstun-linux-x86_64.tar.gz
      echo "✅ Install complete!"
      ;;
    2)
      clear
      echo ""
      echo "📡 Choose Tunnel Mode:"
      echo "1) Iran Server"
      echo "2) Kharej Client"
      read -p "👉 Your choice: " tunnel_choice

      case $tunnel_choice in
        1)
          clear

          # زیرمنوی مدیریت سرور
          while true; do
            echo ""
            echo "🔧 TrustTunnel Server Management"
            echo "1) َAdd new server"
            echo "2) Show service logs"
            echo "3) Delete service"
            echo "4) Back to main menu"
            read -p "👉 Your choice: " srv_choice
            case $srv_choice in
              1)

              


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
              ExecStart=$(pwd)/rstun/rstund --addr 0.0.0.0:$listen_port --password $password --cert $cert_path/fullchain.pem --key $cert_path/privkey.pem
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
          # Show service logs
                service_file="/etc/systemd/system/trusttunnel.service"
                if [ -f "$service_file" ]; then
                  echo "📖 Showing last 15 lines of trusttunnel.service logs. Press 'q' to exit."
                  sudo journalctl -u trusttunnel.service -n 15 --no-pager | less
                else
                  echo "❌ Service 'trusttunnel.service' not found. Cannot show logs."
                  
                fi
                break
          ;;
          3)
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
          echo ""
          echo "📡 TrustTunnel Client Management"
          echo "1) Add new client"
          echo "2) Show Client Log"
          echo "3) Delete a client"
          echo "4) Back to main menu"
          read -p "👉 Your choice: " client_choice

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

        read -p "🌐 Server address and port (e.g., 1.2.3.4:6060): " server_addr
        read -p "🔑 Password: " password
        read -p "🔢 How many ports to tunnel? " port_count

        mappings=""
        for ((i=1; i<=port_count; i++)); do
          read -p "Port #$i: " port
          mapping="IN^0.0.0.0:$port^0.0.0.0:$port"
          [ -z "$mappings" ] && mappings="$mapping" || mappings="$mappings,$mapping"
        done

cat <<EOF | sudo tee $service_file
[Unit]
Description=TrustTunnel Client - $client_name
After=network.target

[Service]
Type=simple
ExecStart=$(pwd)/rstun/rstunc --server-addr $server_addr --password $password --tcp-mappings "$mappings" --udp-mappings "$mappings"
Restart=always
RestartSec=5
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOF

        sudo systemctl daemon-reload
        sudo systemctl enable "$service_name"
        sudo systemctl start "$service_name"
        echo "✅ Client '$client_name' started as $service_name"
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
                echo "📖 Showing the last 15 lines of logs for $selected_service. Press 'q' to quit."
                sudo journalctl -u "$selected_service" -n 15 --no-pager | less
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
                  service_file="/etc/systemd/system/$$selected_service"
                  echo "🛑 Stopping $selected_service..."
                  sudo systemctl stop "$selected_service"
                  echo "🗑️ Disabling $selected_service..."
                  sudo systemctl disable "$selected_service"
                  echo "🗑️ Removing service file..."
                  sudo rm -f "$service_file"
                  sudo systemctl daemon-reload
                  echo "✅ Client '$selected_service' deleted.Press 'q' to quit."
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
          clear
              read -p "⚠️ Are you sure you want to uninstall TrustTunnel and remove all files? (y/N): " confirm
          if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "🧹 Uninstalling TrustTunnel..."

            # Stop and disable service if exists
            if systemctl list-units --full -all | grep -q "trusttunnel.service"; then
              echo "🛑 Stopping trusttunnel service..."
              sudo systemctl stop trusttunnel.service
              echo "🗑️ Disabling trusttunnel service..."
              sudo systemctl disable trusttunnel.service
              echo "🧹 Removing service file..."
              sudo rm -f /etc/systemd/system/trusttunnel.service
              sudo systemctl daemon-reload
            else
              echo "⚠️ TrustTunnel service not found."
            fi

            # Remove rstun folder if exists
            if [ -d "rstun" ]; then
              echo "🗑️ Removing 'rstun' folder..."
              rm -rf rstun
            else
              echo "⚠️ 'rstun' folder not found."
            fi

            echo "✅ TrustTunnel uninstalled successfully."
          else
            echo "❌ Uninstall cancelled."
          fi
          read -p "Press Enter to return to main menu..."
          ;;


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
