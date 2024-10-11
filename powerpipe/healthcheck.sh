#!/bin/bash

# Perform the health check by sending a HEAD request
response=$(curl -I http://steampipe:9033 2>/dev/null)

# Check if the response contains "200 OK"
if echo "$response" | grep -q "200 OK"; then
    echo "Health check passed: Received 200 OK."
    exit 0
else
    echo "Health check failed: Did not receive 200 OK."
    exit 1
fi
