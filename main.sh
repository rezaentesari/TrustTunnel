#!/bin/bash

# Default path for the Cargo environment file.
CARGO_ENV_FILE="$HOME/.cargo/env"

echo "Checking for Rust installation..."

# Check if 'rustc' command is available in the system's PATH.
if command -v rustc >/dev/null 2>&1; then
  # If 'rustc' is found, Rust is already installed.
  echo "✅ Rust is already installed: $(rustc --version)"
else
  # If 'rustc' is not found, start the installation.
  echo "🦀 Rust is not installed. Installing..."

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
