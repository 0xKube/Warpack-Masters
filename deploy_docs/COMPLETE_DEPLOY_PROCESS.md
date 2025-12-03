# Complete Deployment Process Documentation

This document outlines the step-by-step process to deploy the "Warpack Masters" Dojo world to Starknet Sepolia. It reflects the latest (Nov 2025) deployment to the new world address.

## 1. Prerequisites & Environment Setup

Before deployment, the following environment variables and tools were configured:

*   **Tools**: `sozo` (Dojo toolchain), `scarb` (Cairo package manager).
*   **Configuration Files**:
    *   `Scarb.toml`: Dojo v1.8.0, Cairo/scarb v2.13.1.
    *   `dojo_release.toml`: Configured for the `release` profile with Sepolia RPC and account credentials.
*   **Environment Variables**:
    *   `STARKNET_RPC`: `https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_9/iOVGW3WTTEPV8_IPJI5X68y5_lMStBKN`.
    *   `STARKNET_ACCOUNT`: Path to `account.json`.
    *   `STARKNET_PRIVATE_KEY`: The deployer's private key.

## 2. World Deployment (Migration)

The core Dojo world deployment was handled by the `sozo` toolchain.

### Steps:
1.  **Build the Project** (with local caches to avoid $HOME perms):
    ```bash
    SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
      sozo build --profile release
    ```
    This compiled the Cairo contracts into Sierra artifacts in `target/release`.

2.  **Migrate to Sepolia** (blake2s class hash for Sepolia):
    ```bash
    SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
      sozo migrate --profile release --wait --use-blake2s-casm-class-hash
    ```
    *   **Outcome**: Successful. `manifest_release.json` updated (скопировать в фронт при деплое).
    *   **World Address**: `0x07c7e6cbe015e7a1ee77c4e29b859894c8eae03ac1ff69361df6bd8c262c9d47`.

## 3. Post-Deployment Setup (GameConfig + Gold Token & Wiring)

### GameConfig (STRK + rebirth fee)

*   **STRK address (immutable):** `config_system`'s `dojo_init` takes the STRK token address as calldata. Set it in `dojo_release.toml` before migrating; if a wrong address is used you must redeploy.
*   **Rebirth fee (owner adjustable):** After deploy, the world owner can tune/disable the fee (in STRK wei) at any time:
    ```bash
    SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
      sozo execute --profile release --wait --use-blake2s-casm-class-hash \
        --account-address <DEPLOYER> --private-key <PK> --rpc-url <RPC> \
        Warpacks-config_system set_rebirth_fee <FEE_WEI>
    ```
    The fee accrues on the `actions` system; use `withdraw_strk` there to move funds. Setting `0` disables charging.

After world deployment, Gold ERC20 was declared, deployed, and wired with sozo 1.8.2 (no starkli needed):

1. **Declare**:
   ```bash
   SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
     sozo declare --profile release --wait --use-blake2s-casm-class-hash \
       --account-address <DEPLOYER> --private-key <PK> \
       --rpc-url <RPC> target/release/warpack_masters_MintableERC20Token.contract_class.json
   ```
   Class hash: `0x053f5b433645cbd46405fd90e2855902361fee093dd8031cba1e8464ab15a4a1`.

2. **Deploy**:
   ```bash
   sozo deploy --profile release --wait --use-blake2s-casm-class-hash \
     --account-address <DEPLOYER> --private-key <PK> --rpc-url <RPC> \
     0x053f5b433645cbd46405fd90e2855902361fee093dd8031cba1e8464ab15a4a1 \
     --constructor-calldata str:Gold str:gold <DEPLOYER> <DEPLOYER> <DEPLOYER>
   ```
   Gold address: `0x0689731c6c6df7798e601d730f18a0eae7f9a138f9ac9c54d27d94b423b29eca`.

3. **Register in token_factory**:
   ```bash
   sozo execute --profile release --wait --use-blake2s-casm-class-hash \
     --account-address <DEPLOYER> --private-key <PK> --rpc-url <RPC> \
     Warpacks-token_factory reigster_gold 0x0689731c6c6df7798e601d730f18a0eae7f9a138f9ac9c54d27d94b423b29eca
   ```

4. **Grant MINTER_ROLE** (`0x032df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6`) to the systems that call `mint` (fight_system, actions), otherwise spawn/combat rewards will revert with `Caller is missing role`. Fast path:
   ```bash
   STARKNET_RPC_URL=<RPC> scripts/init_register_gold.sh release 0x0689731c6c6df7798e601d730f18a0eae7f9a138f9ac9c54d27d94b423b29eca
   ```
   The script reads `manifest_release.json`, registers Gold in token_factory, and grants MINTER_ROLE to both systems. Manual alternative if needed:
   ```bash
   sozo execute ... <GoldAddress> grant_role <MINTER_ROLE> <fight_system_address>
   sozo execute ... <GoldAddress> grant_role <MINTER_ROLE> <actions_address>
   ```
   - fight_system: `0x1e9c91163b28a0cf2ebeb8311df4f57f7788b8f9bc10707d8f5243df57d97ea`
   - actions: `0x6cf6450c132752fbf3ace05d82f5d61fac097a6f62d0abd0b2b04a204ac16e6`

## 4b. Seed game data (items + dummies)

After wiring Gold, seed baseline data; otherwise spawn/fight flows will miss items/dummy targets:
```bash
STARKNET_RPC_URL=<RPC> scripts/init_batch_add_items.sh release          # items catalog
STARKNET_RPC_URL=<RPC> scripts/init_pre_dummies.sh release              # predefined dummy opponents
```
Both scripts read addresses from `manifest_release.json`.

Optional, if you need crafting/token plumbing in this environment:
```bash
STARKNET_RPC_URL=<RPC> scripts/init_add_recipes.sh release              # craft recipes (currently 2*Dagger+Herb)
STARKNET_RPC_URL=<RPC> scripts/init_batch_create_tokens.sh release      # ERC20 tokens per item (uses token_factory)
```

`scripts/init_add_recipes.sh` details: adds recipe “2x Dagger (id 6) + 1x Herb (id 5) -> Augmented Dagger (id 15)”; reads addresses from `manifest_release.json`.

## 4. Summary of Deployed Components

*   **World Address**: `0x07c7e6cbe015e7a1ee77c4e29b859894c8eae03ac1ff69361df6bd8c262c9d47`
*   **Key system addresses** (from `manifest_release.json`):
    - actions: `0x6cf6450c132752fbf3ace05d82f5d61fac097a6f62d0abd0b2b04a204ac16e6`
    - fight_system: `0x1e9c91163b28a0cf2ebeb8311df4f57f7788b8f9bc10707d8f5243df57d97ea`
    - token_factory: `0x1bf08ba7685ca7dd87c12375ada60ed042fb90c1ef5b33c354c7134734c6605`
*   **Gold Token**: Class `0x053f5b433645cbd46405fd90e2855902361fee093dd8031cba1e8464ab15a4a1`, address `0x0689731c6c6df7798e601d730f18a0eae7f9a138f9ac9c54d27d94b423b29eca`.
*   **Torii (Cartridge Slot)**: Config `torii_slot.toml` uses new world and RPC; deployed via `slot deployments update warpack-masters torii --config torii_slot.toml`. GraphQL: `https://api.cartridge.gg/x/warpack-masters/torii/graphql`.

## Frontend wiring & pitfalls

*   Env for the new world:  
    `NEXT_PUBLIC_RPC_URL=https://api.cartridge.gg/x/starknet/sepolia`  
    `NEXT_PUBLIC_GRAPHQL_URL=https://api.cartridge.gg/x/warpack-masters/torii/graphql`  
    `NEXT_PUBLIC_WORLD_ADDRESS=0x07c7e6cbe015e7a1ee77c4e29b859894c8eae03ac1ff69361df6bd8c262c9d47`  
    `NEXT_PUBLIC_CARTRIDGE_SLOT=warpack-masters`  
    `NEXT_PUBLIC_CARTRIDGE_NAMESPACE=Warpacks`
*   **Обязательно копируйте свежий `manifest_release.json` в фронт** после каждой миграции, иначе адреса систем/моделей не совпадут с Torii.
*   Ошибка `can't reach deployment ... torii.ext-warpack-masters.svc...` возникает, если фронт смотрит на старый Torii. После `slot deployments delete warpack-masters torii -f` и `slot deployments create ...` новый endpoint: `https://api.cartridge.gg/x/warpack-masters/torii/graphql`.
*   Сообщение `Player already exists` воспроизводилось, когда фронт был на старом мире `0xd622...` с уже созданным игроком. При использовании env/manifest выше (новый мир `0x07c7...d47`) спавн работает.
