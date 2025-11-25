#!/bin/bash
set -e

# Navigate to the project root if not already there
# Assuming script is run from project root or scripts/ directory
if [ -f "Scarb.toml" ]; then
    :
elif [ -f "../Scarb.toml" ]; then
    cd ..
else
    echo "Error: Could not find Scarb.toml. Please run from project root."
    exit 1
fi

echo "Building project..."
sozo build --profile release

echo "Deploying to Sepolia..."
# The credentials are now in dojo_release.toml, so we just specify the profile
sozo migrate --profile release
