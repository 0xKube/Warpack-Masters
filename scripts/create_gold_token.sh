#!/bin/bash

set -euo pipefail

pushd $(dirname "$0")/..

 

# Add parameter handling for environment

ENV=${1:-release}  # Default to 'release'

MANIFEST_FILE="./manifest_${ENV}.json"

 

if [[ ! -f "$MANIFEST_FILE" ]]; then

    echo "Error: Manifest file $MANIFEST_FILE does not exist"

    exit 1

fi

 

: "${STARKNET_RPC_URL:?Environment variable STARKNET_RPC_URL must be set}"

 

export WORLD_ADDRESS=$(cat $MANIFEST_FILE | jq -r '.world.address')

export ACTIONS_ADDRESS=$(cat $MANIFEST_FILE | jq -r '.contracts[] | select(.tag == "Warpacks-actions").address')

 

# ERC20 Mintable class hash (declared earlier)

export ERC20_CLASS_HASH=0x05149c08b262aa481b02e5ca23138e8324fcd963d017aa834224c69547adc081

 

# Get account address from dojo_${ENV}.toml

export ACCOUNT_ADDRESS=0x123232bf1c29849c80483d4b1ce48a67fd6e46b6d5f784c75d733cb53e3fbf8

 

echo "---------------------------------------------------------------------------"

echo "Environment: $ENV"

echo "World: $WORLD_ADDRESS"

echo "Actions: $ACTIONS_ADDRESS"

echo "Account (admin): $ACCOUNT_ADDRESS"

echo "ERC20 Class Hash: $ERC20_CLASS_HASH"

echo "---------------------------------------------------------------------------"

 

# Create gold token with:

# - admin: account address (can grant roles)

# - minter: actions contract (can mint tokens)

# - upgrader: account address (can upgrade contract)

sozo execute -P ${ENV} Warpacks-token_factory create_gold_token \

  $ACCOUNT_ADDRESS \

  $ACTIONS_ADDRESS \

  $ACCOUNT_ADDRESS \

  $ERC20_CLASS_HASH \

  --wait --rpc-url $STARKNET_RPC_URL

 

echo "---------------------------------------------------------------------------"

echo "Gold token created and registered successfully!"

echo "---------------------------------------------------------------------------"

