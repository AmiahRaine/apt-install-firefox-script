#!/bin/bash
#
# Script made by Amiah to automate the process of installing firefox on Debian based systems
#
echo -e "This script will install Firefox via apt. This script will import the Mozilla signing key, and pin the .deb version.\n"

read -p "Proceed with installing firefox via apt [y/n]: " choice

if [[ "${choice}" == [Yy] ]]; then

    # Print a line across width of terminal
    echo ""
    printf '%.s─' $(seq 1 $(tput cols))
    echo ""

    ############
    # Keyrings #
    ############

    echo "Checking for /etc/apt/keyrings directory..."
    if [ -d /etc/apt/keyrings ]; then
        echo "[✓] Directory already exists."
        echo "Checking permissions of directory..."
        if [[ $(stat -L -c "%a" /etc/apt/keyrings) != 755 ]]; then
            echo "Modifying permissions of /etc/apt/keyrings to 755."
            sudo chmod 755 /etc/apt/keyrings
        else
            echo "[✓] Directory already has correct permissions (755)."
        fi
    else
        echo "Creating directory /etc/apt/keyrings..."
        sudo install -d -m 0755 /etc/apt/keyrings
    fi

    # Print a line across width of terminal
    echo ""
    printf '%.s─' $(seq 1 $(tput cols))
    echo ""

    ###############
    # Signing key #
    ###############

    echo "Importing signing key..."
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

    # Print a line across width of terminal
    echo ""
    printf '%.s─' $(seq 1 $(tput cols))
    echo ""

    ########################
    # sources.list.d stuff #
    ########################

    echo "Checking directory sources.list.d for existence of file 'mozilla.list'..."
    if [[ -f /etc/apt/sources.list.d/mozilla.list ]]; then
        echo "[✓] 'mozilla.list' already exists."
    else
        echo "Creating file 'mozilla.list' in directory /etc/apt/sources.list.d..."
        sudo touch /etc/apt/sources.list.d/mozilla.list
    fi

    echo "Checking contents of file 'mozilla.list'..."
    if fgrep -q "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" /etc/apt/sources.list.d/mozilla.list; then
        echo "[✓] mozilla.list already contains correct signing key information.";
    else
        echo "Adding imported key to file 'mozilla.list'..."
        echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
    fi

    # Print a line across width of terminal
    echo ""
    printf '%.s─' $(seq 1 $(tput cols))
    echo ""

    #######################
    # preferences.d stuff #
    #######################

    echo "Checking directory preferences.d for existence of file 'mozilla'..."
    if [[ -f /etc/apt/preferences.d/mozilla ]]; then
        echo "[✓] The file 'mozilla' already exists."
    else
        echo "Creating file 'mozilla' in directory /etc/apt/preferences.d..."
        sudo touch /etc/apt/preferences.d/mozilla
    fi

    echo -e "Setting package priority: \n"
    echo -e "Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000" | sudo tee /etc/apt/preferences.d/mozilla

    # Print a line across width of terminal
    echo ""
    printf '%.s─' $(seq 1 $(tput cols))
    echo ""

    ###################
    # Install firefox #
    ###################

    echo -e "Updating apt sources...\n"
    sudo apt update

    # Print a line across width of terminal
    echo ""
    printf '%.s─' $(seq 1 $(tput cols))
    echo ""

    echo -e "Installing Firefox...\n"
    sudo apt install firefox

    # Print a line across width of terminal
    echo ""
    printf '%.s─' $(seq 1 $(tput cols))
    echo ""

    echo "Finished!"

else
    echo "Firefox was not installed."
fi

