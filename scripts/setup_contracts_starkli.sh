#!/bin/bash
set -e

# RPC URL (Alchemy)
RPC_URL="https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_9/iOVGW3WTTEPV8_IPJI5X68y5_lMStBKN"

# Alternative RPCs (Uncomment one if the above fails with "Invalid block id")
# RPC_URL="https://starknet-sepolia.public.blastapi.io/rpc/v0_9"
# RPC_URL="https://rpc.starknet.lava.build/rpc/v0_9"
# RPC_URL="https://free-rpc.nethermind.io/sepolia-juno/"
# RPC_URL="https://starknet-sepolia.drpc.org"

# Account Configuration
ACCOUNT_ADDR="0x0324887e3ed05ca2ca03f9245f97c6edcb48d8b85865a8c8af3035a5b1c6142b"
PRIVATE_KEY="0x045aca0e8c736048378f74c797df6c38ea33e7f3c74bf22712c0eac56344ac64"

# Contract Addresses (from manifest)
ACTIONS_ADDR="0x228f2dc15821c4720369b3fc90cd2ce2168e69036132f896b52c80227845edc"
FIGHT_SYSTEM_ADDR="0x522fe07fe4ddff54b38779f3739e6ac16bba449a18de1e8ff389342f2a680af"
TOKEN_FACTORY_ADDR="0x796b11c38460d19e96a8bb95f7309e5195f2d90e3df616b9edd7755d63fa1be"

# Role Constants
MINTER_ROLE="0x032df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"

export STARKNET_RPC="$RPC_URL"
export STARKNET_ACCOUNT="account.json"
export STARKNET_PRIVATE_KEY="$PRIVATE_KEY"

echo "Declaring MintableERC20Token..."
# Declare and capture class hash
# We use grep/sed to extract the class hash from the output if possible, 
# but starkli declare outputs the class hash to stdout/stderr.
# A safer way is to use the --watch flag or just run it and let the user see the output, 
# but for automation we want to capture it.
# However, if it's already declared, starkli will just return the hash.

CLASS_HASH=$(starkli declare target/release/warpack_masters_MintableERC20Token.contract_class.json --private-key "$PRIVATE_KEY" --account account.json --compiler-version 2.12.2 | grep -oE '0x[0-9a-fA-F]+' | head -n 1)

if [ -z "$CLASS_HASH" ]; then
    echo "Error: Failed to capture Class Hash."
    exit 1
fi

echo "Class Hash: $CLASS_HASH"

echo "Deploying MintableERC20Token..."
# Constructor args: name (Gold), symbol (gold), admin, minter, upgrader
# 0x00 0x476f6c64 0x04 0x00 0x676f6c64 0x04 <admin> <minter> <upgrader>
# We use the captured CLASS_HASH

DEPLOY_OUTPUT=$(starkli deploy "$CLASS_HASH" 0x00 0x476f6c64 0x04 0x00 0x676f6c64 0x04 "$ACCOUNT_ADDR" "$ACCOUNT_ADDR" "$ACCOUNT_ADDR" --private-key "$PRIVATE_KEY" --account account.json)

CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep -oE '0x[0-9a-fA-F]{63,64}' | head -n 1)

if [ -z "$CONTRACT_ADDRESS" ]; then
    echo "Error: Failed to capture Contract Address."
    echo "Output was: $DEPLOY_OUTPUT"
    exit 1
fi

echo "Gold Token Deployed at: $CONTRACT_ADDRESS"

echo "Granting Minter Role..."
starkli invoke "$CONTRACT_ADDRESS" grant_role "$MINTER_ROLE" "$FIGHT_SYSTEM_ADDR" --private-key "$PRIVATE_KEY" --account account.json
starkli invoke "$CONTRACT_ADDRESS" grant_role "$MINTER_ROLE" "$ACTIONS_ADDR" --private-key "$PRIVATE_KEY" --account account.json

echo "Registering Gold Token in World..."
# Note: 'reigster_gold' is the function name in the contract (typo preserved)
starkli invoke "$TOKEN_FACTORY_ADDR" reigster_gold "$CONTRACT_ADDRESS" --private-key "$PRIVATE_KEY" --account account.json

echo "Done! Verification:"
echo "Gold Token: $CONTRACT_ADDRESS"
echo "Token Factory: $TOKEN_FACTORY_ADDR"
