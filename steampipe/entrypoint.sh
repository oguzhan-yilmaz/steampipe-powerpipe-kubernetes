#!/bin/bash

echo "Running entrypoint.sh script..."

if [ -n "$INSTALL_PLUGINS" ]; then
    echo "Installing Plugins: $INSTALL_PLUGINS"
    for mod in $INSTALL_PLUGINS; do
        echo "Installing Plugin: $mod"
        ./steampipe plugin install "$mod" > /dev/null
    done
fi

echo "Updating Plugins..."
./steampipe plugin update --all

echo "Steampipe Plugins:"
./steampipe plugin list

echo "Starting Steampipe:"
./steampipe service start --foreground
