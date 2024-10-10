#!/bin/bash

echo "Running entrypoint.sh script..."

if [ -n "$INSTALL_MODS" ]; then
    echo "Installing Mods: $INSTALL_MODS"
    ./powerpipe mod install "$INSTALL_MODS" > /dev/null
fi

echo "Updating Plugins..."
./powerpipe mod update > /dev/null

echo "Mod List:"
./powerpipe mod list

echo "Starting Powerpipe:"
./powerpipe server
