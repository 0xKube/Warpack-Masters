#!/bin/bash
set -e

# Configuration
RPC_URL="https://api.cartridge.gg/x/starknet/sepolia"
ACCOUNT_ADDR="0x0324887e3ed05ca2ca03f9245f97c6edcb48d8b85865a8c8af3035a5b1c6142b"
PRIVATE_KEY="0x045aca0e8c736048378f74c797df6c38ea33e7f3c74bf22712c0eac56344ac64"
PUBLIC_KEY="0x2c74670b0891f90d27f712537e697f6f42138f6396467277147d25700a654"
CLASS_HASH_ACCOUNT="0x3957f9f5a1cbfe918cedc2015c85200ca51a5f7506ecb6de98a5207b759bf8a"

ACCOUNTS_FILE="sncast_accounts_manual.json"
ACCOUNT_NAME="deployer"

echo "Creating manual accounts file..."
cat <<EOF > "$ACCOUNTS_FILE"
{
  "alpha-sepolia": {
    "$ACCOUNT_NAME": {
      "address": "$ACCOUNT_ADDR",
      "private_key": "$PRIVATE_KEY",
      "public_key": "$PUBLIC_KEY",
      "class_hash": "$CLASS_HASH_ACCOUNT",
      "deployed": true
    }
  }
}
EOF

echo "Declaring MintableERC20Token..."
sncast --accounts-file "$ACCOUNTS_FILE" --account "$ACCOUNT_NAME" declare --contract-name MintableERC20Token --url "$RPC_URL"
