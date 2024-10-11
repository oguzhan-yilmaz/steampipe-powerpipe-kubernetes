#!/bin/bash

echo "Running entrypoint.sh script..."


if [ -n "$INSTALL_PLUGINS" ]; then
    echo "Installing Plugins: $INSTALL_PLUGINS"
    ./steampipe plugin install "$INSTALL_PLUGINS" > /dev/null
fi

echo "Updating Plugins..."
./steampipe plugin update --all > /dev/null

echo "Plugin List:"
./steampipe plugin list


printenv 


echo "Starting Steampipe:"
./steampipe service start --foreground
