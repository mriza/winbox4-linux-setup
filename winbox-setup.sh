#!/bin/bash

# Variables
URL="https://mikrotik.com/download"
DEST_DIR="/opt/winbox"
DESKTOP_FILE="/usr/share/applications/winbox.desktop"
ICON_PATH="$DEST_DIR/assets/img/winbox.png"
VERSION_FILE="$DEST_DIR/version"
ZIP_FILE="$DEST_DIR/WinBox_Linux.zip"

# Function to download and extract WinBox
install_winbox() {
    # Download the download page
    echo "Fetching MikroTik download page..."
    PAGE_CONTENT=$(curl -s "$URL")

    # Parse the page for the WinBox Linux download link (regex to match the dynamic part)
    DOWNLOAD_LINK=$(echo "$PAGE_CONTENT" | grep -oP 'https://download\.mikrotik\.com/routeros/winbox/[^"]+/WinBox_Linux\.zip')

    if [ -z "$DOWNLOAD_LINK" ]; then
      echo "Error: Could not find WinBox_Linux.zip download link."
      exit 1
    fi

    echo "Found WinBox Linux download link: $DOWNLOAD_LINK"

    # Extract version information from the URL (e.g., "4.0beta9" from "4.0beta9/WinBox_Linux.zip")
    CURRENT_VERSION=$(echo "$DOWNLOAD_LINK" | grep -oP 'winbox/\K[^/]+')

    echo "Current WinBox version available: $CURRENT_VERSION"

    # If the version file exists, read the installed version
    if [ -f "$VERSION_FILE" ]; then
        INSTALLED_VERSION=$(cat "$VERSION_FILE")
        echo "Installed version: $INSTALLED_VERSION"
    else
        INSTALLED_VERSION="none"
        echo "No previous version installed."
    fi

    # Compare versions
    if [ "$INSTALLED_VERSION" != "$CURRENT_VERSION" ]; then
        echo "Updating to version $CURRENT_VERSION..."

        # Download the file with a progress bar
        echo "Downloading $DOWNLOAD_LINK..."
        curl -L --progress-bar "$DOWNLOAD_LINK" -o "$ZIP_FILE"

        # Check if the file was downloaded
        if [ ! -f "$ZIP_FILE" ]; then
            echo "Error: Download failed."
            exit 1
        fi

        echo "Download complete. Extracting to $DEST_DIR..."

        # Extract the zip file
        sudo unzip -o "$ZIP_FILE" -d "$DEST_DIR"

        # Cleanup the ZIP file after extraction
        echo "Cleaning up..."
        rm "$ZIP_FILE"

        # Store the current version in the 'version' file
        echo "$CURRENT_VERSION" | sudo tee "$VERSION_FILE" > /dev/null

        echo "WinBox successfully installed/updated to $CURRENT_VERSION in $DEST_DIR"
    else
        echo "WinBox is already up-to-date (version $INSTALLED_VERSION). No update required."
    fi
}

# Function to create .desktop file
create_desktop_file() {
    echo "Creating .desktop file for system-wide usage..."

    # Check if icon exists
    if [ ! -f "$ICON_PATH" ]; then
        echo "Icon file not found at $ICON_PATH, please place the icon correctly."
        exit 1
    fi

    # Create the .desktop file
    sudo bash -c "cat > $DESKTOP_FILE" << EOL
[Desktop Entry]
Version=1.0
Type=Application
Name=WinBox
Comment=MikroTik WinBox
Exec=$DEST_DIR/WinBox # Adjust this if the executable has a different name
Icon=$ICON_PATH
Terminal=false
Categories=Network;Utility;
EOL

    # Make sure the .desktop file is executable
    sudo chmod +x "$DESKTOP_FILE"

    echo "Desktop entry created at $DESKTOP_FILE"
}

# Function to uninstall WinBox
uninstall_winbox() {
    if [ -d "$DEST_DIR" ]; then
        echo "Removing WinBox from $DEST_DIR..."
        sudo rm -rf "$DEST_DIR"
    else
        echo "Error: WinBox is not installed."
        exit 1
    fi

    if [ -f "$DESKTOP_FILE" ]; then
        echo "Removing desktop entry..."
        sudo rm "$DESKTOP_FILE"
    fi

    echo "WinBox successfully uninstalled."
}

# Ensure the user is using sudo
if [ "$EUID" -ne 0 ]; then
  echo "This script needs to be run as root. Please enter your password."
  sudo "$0" "$@"
  exit
fi

# Check if the user provided the required parameter
if [ $# -eq 0 ]; then
    echo "Usage: $0 [--install|-i] or [--update|-u] or [--remove|-rm]"
    exit 1
fi

# Handle parameters
case "$1" in
  --install|-i)
    if [ -d "$DEST_DIR" ]; then
        echo "Error: WinBox is already installed in $DEST_DIR."
        exit 1
    else
        echo "Installing WinBox..."
        sudo mkdir -p "$DEST_DIR"
        sudo mkdir -p "$DEST_DIR/assets/img"
        sudo chown $USER:$USER "$DEST_DIR"
        install_winbox
        create_desktop_file
    fi
    ;;
    
  --update|-u)
    if [ ! -d "$DEST_DIR" ]; then
        echo "Error: WinBox is not installed. Please install it first."
        exit 1
    else
        echo "Checking for WinBox updates in $DEST_DIR..."
        install_winbox
    fi
    ;;

  --remove|-rm)
    echo "Uninstalling WinBox..."
    uninstall_winbox
    ;;

  *)
    echo "Invalid option. Use --install|-i for new installation, --update|-u for updating, or --remove|-rm for uninstalling."
    exit 1
    ;;
esac
