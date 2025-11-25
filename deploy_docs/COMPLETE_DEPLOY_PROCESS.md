# Complete Deployment Process Documentation

This document outlines the step-by-step process undertaken to deploy the "Warpack Masters" Dojo world to Starknet Sepolia. It reflects the actions taken, challenges encountered, and the logical workflow derived from the deployment session.

## 1. Prerequisites & Environment Setup

Before deployment, the following environment variables and tools were configured:

*   **Tools**: `sozo` (Dojo toolchain), `scarb` (Cairo package manager), `starkli` (Starknet CLI).
*   **Configuration Files**:
    *   `Scarb.toml`: Verified dependencies (Dojo v1.7.1, Cairo v2.12.2).
    *   `dojo_release.toml`: Configured for the `release` profile with Sepolia RPC and account credentials.
*   **Environment Variables**:
    *   `STARKNET_RPC`: Set to Alchemy/BlastAPI/Lava/DRPC endpoints (troubleshooting involved switching these).
    *   `STARKNET_ACCOUNT`: Path to `account.json`.
    *   `STARKNET_PRIVATE_KEY`: The deployer's private key.

## 2. World Deployment (Migration)

The core Dojo world deployment was handled by the `sozo` toolchain.

### Steps:
1.  **Build the Project**:
    ```bash
    sozo build --profile release
    ```
    This compiled the Cairo contracts into Sierra artifacts in `target/release`.

2.  **Migrate to Sepolia**:
    ```bash
    sozo migrate --profile release
    ```
    *   **Process**: This command calculated the world diff, declared necessary classes, and deployed/updated the World contract and its systems.
    *   **Outcome**: Successful. The `manifest_release.json` file was updated with the deployed contract addresses.

## 3. Post-Deployment Setup (Gold Token & Wiring)

After the world was deployed, the external "Gold" ERC20 token needed to be deployed and registered within the game systems. This phase involved significant troubleshooting.

### Objectives:
1.  Deploy `MintableERC20Token` (Gold).
2.  Grant `MINTER_ROLE` to `fight_system` and `actions` contracts.
3.  Register the Gold token in the `token_factory`.

### Attempted Workflows:

#### Approach A: Manual Deployment via `starkli` (Initial Plan)
We attempted to use a shell script (`setup_contracts_starkli.sh`) to orchestrate the setup.
1.  **Extract Addresses**: Parsed `manifest_release.json` to get addresses for `actions`, `fight_system`, and `token_factory`.
2.  **Declare Class**: Tried to declare `MintableERC20Token` using `starkli declare`.
    *   **Issue**: Encountered persistent `JSON-RPC error: code=-32602, message="Invalid params", data={"reason":"Invalid block id"}`.
    *   **Troubleshooting**: Switched RPC providers (Alchemy -> BlastAPI -> Lava -> DRPC). The error persisted across all providers, indicating a likely incompatibility between the local `starkli` version and the RPC nodes.

#### Approach B: Deployment via `sozo execute` (Alternative Strategy)
To bypass `starkli` issues, we pivoted to using `sozo` to leverage the `token_factory` contract's logic.
1.  **Logic**: The `token_factory` contract has a `create_gold_token` function that can deploy the token internally using `deploy_syscall`.
2.  **Requirement**: The `MintableERC20Token` class hash must be passed to this function.
3.  **Action**: Calculated the class hash using `starkli class-hash`:
    *   Hash: `0x072313c5be9b40fd661ed143cf1036606cb2fd1839c545ac1a52bedf4781af6f`
4.  **Execution**:
    ```bash
    sozo --profile release execute Warpacks-token_factory create_gold_token <ADMIN> <MINTER> <UPGRADER> <CLASS_HASH>
    ```
    *   **Outcome**: Failed with `Class with hash ... is not declared`.
    *   **Root Cause**: `deploy_syscall` requires the class to be declared on Starknet first. Since `starkli declare` failed (Approach A), the class was never declared.

### Final Resolution Path
The deployment process requires a working method to declare the `MintableERC20Token` class. Since `starkli` was failing, the working solution involves:
1.  **Declare the Class**: Use a compatible tool (e.g., `sncast` or a compatible `starkli` version) to declare `target/release/warpack_masters_MintableERC20Token.contract_class.json`.
2.  **Deploy & Register**: Once declared, either:
    *   Call `token_factory.create_gold_token` via `sozo execute` (cleanest method).
    *   OR manually deploy via `sncast`/`starkli` and then call `token_factory.reigster_gold`.

## 4. Summary of Deployed Components

*   **World Address**: `0xd622721bcdf3816ae358da7e46bd804f51f72908cbb348cd78484c6cabed56`
*   **Systems**: Deployed and registered in the world (e.g., `actions`, `fight_system`).
*   **Gold Token**: Requires manual declaration and deployment as a post-migration step.
