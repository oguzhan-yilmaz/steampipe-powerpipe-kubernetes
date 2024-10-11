#!/bin/bash

# Run the service status command and capture its output
output=$(./steampipe service status)

# Check if the output contains "service is running"
if echo "$output" | grep -q "Steampipe service is running"; then
    echo "Health check passed: Service is running."
    exit 0
else
    echo "Health check failed: Service is not running."
    exit 1
fi
