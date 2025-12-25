#!/bin/bash
set -euo pipefail
: "${STARKNET_RPC_URL:?Environment variable STARKNET_RPC_URL must be set}"

# Pouch + Pouch -> Satchel
sozo execute -P mainnet Warpacks-recipe_system add_recipe 1 4 1 2 3 --wait --rpc-url $STARKNET_RPC_URL

# Pack + Satchel -> Backpack
sozo execute -P mainnet Warpacks-recipe_system add_recipe 2 2 3 2 1 1 1 --wait --rpc-url $STARKNET_RPC_URL

# Herb + Herb -> Healing Potion
sozo execute -P mainnet Warpacks-recipe_system add_recipe 1 5 1 2 11 --wait --rpc-url $STARKNET_RPC_URL

# Dagger + Dagger -> Augmented Dagger
sozo execute -P mainnet Warpacks-recipe_system add_recipe 1 6 1 2 15 --wait --rpc-url $STARKNET_RPC_URL

# Sword + Sword -> Augmented Sword
sozo execute -P mainnet Warpacks-recipe_system add_recipe 1 7 1 2 14 --wait --rpc-url $STARKNET_RPC_URL

# Shield + Spike -> Spike Shield
sozo execute -P mainnet Warpacks-recipe_system add_recipe 2 9 8 2 1 1 16 --wait --rpc-url $STARKNET_RPC_URL

# Shield + Helmet -> Buckler
sozo execute -P mainnet Warpacks-recipe_system add_recipe 2 9 10 2 1 1 19 --wait --rpc-url $STARKNET_RPC_URL

# Leather Armor + Shield -> Mail Armor
sozo execute -P mainnet Warpacks-recipe_system add_recipe 2 12 9 2 1 1 18 --wait --rpc-url $STARKNET_RPC_URL

# Leather Armor + Spike Shield -> Blade Armor
sozo execute -P mainnet Warpacks-recipe_system add_recipe 2 12 16 2 1 1 29 --wait --rpc-url $STARKNET_RPC_URL

# Leather Armor + Scarlet Cloak -> Vampiric Armor
sozo execute -P mainnet Warpacks-recipe_system add_recipe 2 12 32 2 1 1 21 --wait --rpc-url $STARKNET_RPC_URL

# Bow + Bow -> Longbow
sozo execute -P mainnet Warpacks-recipe_system add_recipe 1 23 1 2 34 --wait --rpc-url $STARKNET_RPC_URL

# Rage Gauntlet + Helmet -> Knight Helmet
sozo execute -P mainnet Warpacks-recipe_system add_recipe 2 27 10 2 1 1 28 --wait --rpc-url $STARKNET_RPC_URL

# Club + Club -> Hammer
sozo execute -P mainnet Warpacks-recipe_system add_recipe 1 30 1 2 25 --wait --rpc-url $STARKNET_RPC_URL

