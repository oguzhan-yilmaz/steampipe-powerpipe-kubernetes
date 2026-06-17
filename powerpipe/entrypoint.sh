#!/bin/bash

echo "Running entrypoint.sh script..."

STEAMPIPE_HOST="${STEAMPIPE_HOST:-steampipe}"
STEAMPIPE_DATABASE_PASSWORD="${STEAMPIPE_DATABASE_PASSWORD:-${PGPASSWORD}}"

if [ -z "$STEAMPIPE_DATABASE_PASSWORD" ]; then
    echo "STEAMPIPE_DATABASE_PASSWORD or PGPASSWORD must be set" >&2
    exit 1
fi

POWERPIPE_MOD_LOCATION="${POWERPIPE_MOD_LOCATION:-/home/powerpipe/mod}"
export POWERPIPE_MOD_LOCATION

# Override the default Steampipe connection (replaces deprecated POWERPIPE_DATABASE / --database).
mkdir -p "${POWERPIPE_INSTALL_DIR}/config"
cat > "${POWERPIPE_INSTALL_DIR}/config/default.ppc" <<EOF
connection "steampipe" "default" {
  host     = "${STEAMPIPE_HOST}"
  port     = 9193
  username = "steampipe"
  password = "${STEAMPIPE_DATABASE_PASSWORD}"
  db       = "steampipe"
  sslmode = "disable"
}
EOF

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
./powerpipe server --listen network
