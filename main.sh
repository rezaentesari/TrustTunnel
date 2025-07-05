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
sudo apt install -y build-essential curl pkg-config libssl-dev git figlet certbot

# If the Cargo environment file exists, source it to update the PATH
if [ -f "$CARGO_ENV_FILE" ]; then
  source "$CARGO_ENV_FILE"
fi

# Now, check if Rust is installed by looking for the 'rustc' command
if command -v rustc >/dev/null 2>&1; then
  # If 'rustc' is found, it means Rust is already installed
  echo "✅ Rust از قبل نصب شده است: $(rustc --version)"
else
  # If 'rustc' is not found, start the installation process
  echo "🦀 Rust نصب نشده است. در حال نصب..."

  # Run the installer with the -y flag to automate the process
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

  # Source the environment file again to make Rust available in the current session
  if [ -f "$CARGO_ENV_FILE" ]; then
    source "$CARGO_ENV_FILE"
  else
    # A fallback in case the env file was not created
    export PATH="$HOME/.cargo/bin:$PATH"
  fi

  # Display the installed version for confirmation
  echo "✅ Rust با موفقیت نصب شد: $(rustc --version)"
fi


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
      git clone https://github.com/neevek/rstun.git
      cd rstun
      echo "🔨 Building project..."
      cargo build --release
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

              


          if [ ! -f "rstun/target/release/rstund" ]; then
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
              ExecStart=$(pwd)/rstun/target/release/rstund --addr 0.0.0.0:$listen_port --password $password --cert $cert_path/fullchain.pem --key $cert_path/privkey.pem
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
          echo "2) List clients"
          echo "3) Delete a client"
          echo "4) Show Client Log"
          echo "5) Back to main menu"
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
ExecStart=$(pwd)/rstun/target/release/rstunc --server-addr $server_addr --password $password --tcp-mappings "$mappings" --udp-mappings "$mappings"
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
        echo "📝 Available clients:"
        systemctl list-unit-files --type=service --no-legend \
        | grep '^trusttunnel-.*\.service' \
        | awk '{print $1}' \
        | sed -E 's/^trusttunnel-(.*)\.service$/\1/'
        ;;
      3)
      clear
        read -p "Enter client name to delete (e.g., c1): " del_name
          del_service="trusttunnel-$del_name"
          service_file="/etc/systemd/system/${del_service}.service"

          if [ -f "$service_file" ]; then
            echo "🛑 Stopping $del_service..."
            sudo systemctl stop "$del_service"
            echo "🗑️ Disabling $del_service..."
            sudo systemctl disable "$del_service"
            echo "🗑️ Removing service file..."
            sudo rm -f "$service_file"
            sudo systemctl daemon-reload
            echo "✅ Client '$del_name' deleted."
          else
            echo "⚠️ Client '$del_name' not found."
          fi
          break
        ;;

      4)
        clear
             read -p "Enter client name to view logs (e.g., c1): " log_name
              log_service="trusttunnel-$log_name"
              service_file="/etc/systemd/system/${log_service}.service"

              if [ -f "$service_file" ]; then
                echo "📖 Showing last 15 lines of logs for $log_service. Press 'q' to return."
                sudo journalctl -u "${log_service}.service" -n 15 --no-pager | less
              else
                echo "❌ Client '$log_name' not found."
              fi
              break
      ;;
      5)
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
