#!/bin/bash

# Ensure tmp directory exists
mkdir -p /usr/src/app/cli_services/tmp

# Create credentials directory if not present
mkdir -p /root/.aws

# Create sample config file if not present
if [ ! -f "/root/.aws/config" ]; then
  echo "Creating sample AWS config file..."
  cat > /root/.aws/config << 'EOF'
[default]
region = <Region>
output = json

[profile my-profile]
region = <Region>
output = yml
EOF
fi

# Create sample credentials file if not present
if [ ! -f "/root/.aws/credentials" ]; then
  echo "Creating sample AWS credentials file..."
  cat > /root/.aws/credentials << 'EOF'
[default]
# This is the default profile
aws_access_key_id = <AWS ACCESS KEY>
aws_secret_access_key = <AWS SECRET KEY>

[my-profile]
aws_access_key_id = <AWS ACCESS KEY>
aws_secret_access_key = <AWS SECRET KEY>
EOF
  echo "⚠️  Please update with your actual AWS credentials."
fi

# Install node modules for interactiveUI if not present
if [ ! -d "/usr/src/app/cli_services/interactiveUI/node_modules" ]; then
  echo "Installing node modules for interactiveUI..."
  cd /usr/src/app/cli_services/interactiveUI
  npm install --silent
  cd /usr/src/app/cli_services
fi

# Execute the command passed to the container
exec "$@"
