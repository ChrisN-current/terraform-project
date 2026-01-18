#!/bin/bash
set -euxo pipefail
mkdir -p /var/www/html
echo "Hello, World!" > /var/www/html/index.html
cd /var/www/html

# Start web server on the provided port
nohup python3 -m http.server ${server_port} > /var/log/webserver.log 2>&1 &
