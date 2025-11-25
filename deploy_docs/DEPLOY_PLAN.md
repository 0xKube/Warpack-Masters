# Deployment Plan - Warpack Masters

## Goal
Deploy the "Warpack Masters" game to Starknet Sepolia, including the Dojo world, systems, and the external Gold ERC20 token.

## Proposed Changes

### 1. Build and Migrate World
- Run [scripts/deploy_sepolia.sh](file:///Users/kirill/Desktop/code/yakub/Warpack-Masters/scripts/deploy_sepolia.sh) to build the project and migrate the world to Sepolia.
- This will update [manifest_release.json](file:///Users/kirill/Desktop/code/yakub/Warpack-Masters/manifest_release.json) with the latest contract addresses.

### 2. Update Setup Configuration
- Read [manifest_release.json](file:///Users/kirill/Desktop/code/yakub/Warpack-Masters/manifest_release.json) to extract the deployed addresses for:
    - `actions` contract
    - `fight_system` contract
    - `token_factory` contract
- Update [scripts/setup_contracts_starkli.sh](file:///Users/kirill/Desktop/code/yakub/Warpack-Masters/scripts/setup_contracts_starkli.sh) with these new addresses.

### 3. Deploy Gold Token and Configure
- Execute the updated [scripts/setup_contracts_starkli.sh](file:///Users/kirill/Desktop/code/yakub/Warpack-Masters/scripts/setup_contracts_starkli.sh) to:
    - Declare `MintableERC20Token` class.
    - Deploy the Gold Token contract.
    - Grant `MINTER_ROLE` to `fight_system` and `actions`.
    - Register the Gold Token in `token_factory`.

## Verification Plan

### Automated Verification
- The `sozo migrate` command performs self-checks.
- The `starkli` commands will return transaction hashes. We can check their status.

### Manual Verification
- Verify the deployment on a block explorer (Voyager/Starkscan) using the addresses outputted by the scripts.
- Check that the `token_factory` has the correct Gold Token address registered.
