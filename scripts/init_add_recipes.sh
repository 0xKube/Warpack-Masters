#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

# Add parameter handling for environment
ENV=${1:-dev}  # Default to 'dev' if no argument provided
MANIFEST_FILE="./manifest_${ENV}.json"

if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo "Error: Manifest file $MANIFEST_FILE does not exist"
    exit 1
fi

: "${STARKNET_RPC_URL:?Environment variable STARKNET_RPC_URL must be set}"

WORLD_ADDRESS=$(cat "$MANIFEST_FILE" | jq -r '.world.address')
RECIPE_SYSTEM_ADDRESS=$(cat "$MANIFEST_FILE" | jq -r '.contracts[] | select(.tag == "Warpacks-recipe_system").address')

if [[ -z "$RECIPE_SYSTEM_ADDRESS" ]]; then
    echo "Error: recipe_system address not found in $MANIFEST_FILE"
    exit 1
fi

echo "---------------------------------------------------------------------------"
echo "Environment: $ENV"
echo "Using manifest: $MANIFEST_FILE"
echo "World: $WORLD_ADDRESS"
echo "Recipe system: $RECIPE_SYSTEM_ADDRESS"
echo "---------------------------------------------------------------------------"


# Recipes:
# - Augmented Dagger: 2x Dagger (id 6) + 1x Herb (id 5) -> Augmented Dagger (id 15)
#
# Cairo array encoding for add_recipe(item_ids, item_amounts, result_item_id):
# <len ids> <id1> <id2> ... <len amounts> <amt1> <amt2> ... <result_id>

echo "Adding recipes..."
sozo execute -P ${ENV} Warpacks-recipe_system add_recipe \
    2 6 5 \
    2 2 1 \
    15 \
    --wait --rpc-url "$STARKNET_RPC_URL"
echo "Done."
