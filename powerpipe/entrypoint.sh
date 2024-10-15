#!/bin/bash

echo "Running entrypoint.sh script..."


if [ -n "$INSTALL_MODS" ]; then
    echo "INSTALL_MODS variable is defined: $INSTALL_MODS"
    for mod in $INSTALL_MODS; do
        echo "Installing Mod: $mod"
        ./powerpipe mod install "$mod" > /dev/null
    done
fi

echo "Updating Mods..."
./powerpipe mod update > /dev/null

echo "Mod List:"
./powerpipe mod list

echo "Starting Powerpipe:"
./powerpipe server
