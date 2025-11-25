#!/bin/bash
set -e

# Configuration
RPC_URL="https://api.cartridge.gg/x/starknet/sepolia"
ACCOUNT_ADDR="0x0324887e3ed05ca2ca03f9245f97c6edcb48d8b85865a8c8af3035a5b1c6142b"
PRIVATE_KEY="0x045aca0e8c736048378f74c797df6c38ea33e7f3c74bf22712c0eac56344ac64"

ACTIONS_ADDR="0x228f2dc15821c4720369b3fc90cd2ce2168e69036132f896b52c80227845edc"
FIGHT_SYSTEM_ADDR="0x522fe07fe4ddff54b38779f3739e6ac16bba449a18de1e8ff389342f2a680af"
TOKEN_FACTORY_ADDR="0x796b11c38460d19e96a8bb95f7309e5195f2d90e3df616b9edd7755d63fa1be"

MINTER_ROLE="0x032df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"

export STARKNET_RPC_URL="$RPC_URL"
# Setup accounts file
ACCOUNTS_FILE="sncast_accounts.json"
ACCOUNT_NAME="deployer"
CLASS_HASH_ACCOUNT="0x3957f9f5a1cbfe918cedc2015c85200ca51a5f7506ecb6de98a5207b759bf8a"

echo "Importing account with explicit class hash..."
sncast --accounts-file "$ACCOUNTS_FILE" account import \
    --url "$RPC_URL" \
    --name "$ACCOUNT_NAME" \
    --address "$ACCOUNT_ADDR" \
    --private-key "$PRIVATE_KEY" \
    --type oz \
    --class-hash "$CLASS_HASH_ACCOUNT" \
    || echo "Account might already exist, proceeding..."

echo "Declaring MintableERC20Token..."
DECLARE_OUTPUT=$(sncast --accounts-file "$ACCOUNTS_FILE" --account "$ACCOUNT_NAME" declare --contract-name MintableERC20Token --url "$RPC_URL")
echo "$DECLARE_OUTPUT"
CLASS_HASH=$(echo "$DECLARE_OUTPUT" | grep "class_hash:" | awk '{print $2}')

if [ -z "$CLASS_HASH" ]; then
    echo "Failed to capture class hash. It might be already declared."
    CLASS_HASH=$(echo "$DECLARE_OUTPUT" | grep -oP 'class_hash: \K0x[0-9a-fA-F]+')
fi

if [ -z "$CLASS_HASH" ]; then
    echo "Could not find class hash in output. Please check if already declared."
    CLASS_HASH="0x072313c5be9b40fd661ed143cf1036606cb2fd1839c545ac1a52bedf4781af6f"
    echo "Using fallback class hash: $CLASS_HASH"
fi

echo "Class Hash: $CLASS_HASH"

echo "Deploying MintableERC20Token..."
DEPLOY_OUTPUT=$(sncast --accounts-file "$ACCOUNTS_FILE" --account "$ACCOUNT_NAME" deploy --class-hash "$CLASS_HASH" --constructor-calldata 0x00 0x476f6c64 0x04 0x00 0x676f6c64 0x04 "$ACCOUNT_ADDR" "$ACCOUNT_ADDR" "$ACCOUNT_ADDR" --url "$RPC_URL")
echo "$DEPLOY_OUTPUT"
CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep "contract_address:" | awk '{print $2}')

if [ -z "$CONTRACT_ADDRESS" ]; then
    echo "Failed to deploy contract."
    exit 1
fi

echo "Contract Address: $CONTRACT_ADDRESS"

echo "Granting Minter Role to Fight System..."
sncast --accounts-file "$ACCOUNTS_FILE" --account "$ACCOUNT_NAME" invoke --contract-address "$CONTRACT_ADDRESS" --function grant_role --calldata "$MINTER_ROLE" "$FIGHT_SYSTEM_ADDR" --url "$RPC_URL"

echo "Granting Minter Role to Actions System..."
sncast --accounts-file "$ACCOUNTS_FILE" --account "$ACCOUNT_NAME" invoke --contract-address "$CONTRACT_ADDRESS" --function grant_role --calldata "$MINTER_ROLE" "$ACTIONS_ADDR" --url "$RPC_URL"

echo "Registering Gold token in Token Factory..."
sncast --accounts-file "$ACCOUNTS_FILE" --account "$ACCOUNT_NAME" invoke --contract-address "$TOKEN_FACTORY_ADDR" --function reigster_gold --calldata "$CONTRACT_ADDRESS" --url "$RPC_URL"

echo "Setup complete!"
