#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

# Usage: scripts/init_register_gold.sh [env] <gold_address>
# gold_address can also be provided via GOLD_ADDRESS env var.

ENV=${1:-dev}
GOLD_ADDRESS=${2:-${GOLD_ADDRESS:-}}
MANIFEST_FILE="./manifest_${ENV}.json"
MINTER_ROLE="0x032df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"

if [[ -z "$GOLD_ADDRESS" ]]; then
    echo "Error: Gold address is required (pass as 2nd arg or set GOLD_ADDRESS env var)"
    exit 1
fi

if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo "Error: Manifest file $MANIFEST_FILE does not exist"
    exit 1
fi

: "${STARKNET_RPC_URL:?Environment variable STARKNET_RPC_URL must be set}"

WORLD_ADDRESS=$(cat "$MANIFEST_FILE" | jq -r '.world.address')
TOKEN_FACTORY_ADDRESS=$(cat "$MANIFEST_FILE" | jq -r '.contracts[] | select(.tag == "Warpacks-token_factory").address')
ACTIONS_ADDRESS=$(cat "$MANIFEST_FILE" | jq -r '.contracts[] | select(.tag == "Warpacks-actions").address')
FIGHT_SYSTEM_ADDRESS=$(cat "$MANIFEST_FILE" | jq -r '.contracts[] | select(.tag == "Warpacks-fight_system").address')

if [[ -z "$TOKEN_FACTORY_ADDRESS" || -z "$ACTIONS_ADDRESS" || -z "$FIGHT_SYSTEM_ADDRESS" ]]; then
    echo "Error: Missing contract addresses in $MANIFEST_FILE"
    exit 1
fi

echo "---------------------------------------------------------------------------"
echo "Environment: $ENV"
echo "Using manifest: $MANIFEST_FILE"
echo "World: $WORLD_ADDRESS"
echo "Token Factory: $TOKEN_FACTORY_ADDRESS"
echo "Gold: $GOLD_ADDRESS"
echo "Actions: $ACTIONS_ADDRESS"
echo "Fight system: $FIGHT_SYSTEM_ADDRESS"
echo "---------------------------------------------------------------------------"

echo "Registering Gold in token_factory..."
sozo execute -P ${ENV} Warpacks-token_factory reigster_gold "$GOLD_ADDRESS" --wait --rpc-url "$STARKNET_RPC_URL"

for TARGET in "$ACTIONS_ADDRESS" "$FIGHT_SYSTEM_ADDRESS"; do
    echo "Granting MINTER_ROLE to $TARGET..."
    sozo execute -P ${ENV} "$GOLD_ADDRESS" grant_role "$MINTER_ROLE" "$TARGET" --wait --rpc-url "$STARKNET_RPC_URL"
done
