# Deploy / Ops Log

Фиксируем все важные ончейн-операции (execute/migrate), чтобы команда могла сверять состояние сети с кодом.

## Формат записи
- `date`: UTC timestamp
- `env`: профиль/сеть (`release`/`dev`, Sepolia/Katana и т.п.)
- `action`: что сделано
- `command`: точная команда
- `tx`: хэш транзакции (если есть)
- `notes`: важные детали/риски

## Записи
- date: 2025-12-16 16:59 UTC  
  env: release (Sepolia)  
  action: добавлен предмет DAI в item_system (`add_item`)  
  command: `sozo execute -P release Warpacks-item_system add_item 50 str:'DAI' 3 1 1 1 1 0 0 0 100 0 0 0 --wait --rpc-url https://api.cartridge.gg/x/starknet/sepolia`  
  tx: `0x038a3de842f6555efc596140b7e849c4698a219dbb41c4d06b6368754e824c29`  
  notes: Item registered manually.
    **Breakdown of arguments**: `50 str:'DAI' 3 1 1 1 1 0 0 0 100 0 0 0`
    - `id`: 50
    - `name`: "DAI"
    - `itemType`: 3 (Resource/Material)
    - `rarity`: 1 (Common)
    - `width`: 1
    - `height`: 1
    - `price`: 1 (Gold cost)
    - `effectType`: 0 (None)
    - `effectStacks`: 0
    - `effectActivationType`: 0
    - `chance`: 100%
    - `cooldown`: 0
    - `energyCost`: 0
    - `isPlugin`: false
    **Context**: Added only on-chain (not in `items.cairo` seed) to serve as a bridgeable ERC20 item.
- date: 2025-12-16 17:05 UTC  
  env: release (Sepolia)  
  action: sozo migrate (release)  
  command: `SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target XDG_CACHE_HOME=.scarb_cache STARKNET_RPC_URL=https://api.cartridge.gg/x/starknet/sepolia sozo migrate --profile release --wait --use-blake2s-casm-class-hash`  
  tx: n/a (world already synced)  
  notes: миграция прошла без изменений; manifest обновлён (адрес мира остался `0x07c7e6cbe015e7a1ee77c4e29b859894c8eae03ac1ff69361df6bd8c262c9d47`). IPFS upload пропущен (нет credentials).
- date: 2025-12-16 17:35 UTC
  env: release (Sepolia)
  action: sozo migrate (release) - RETRY
  command: `SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target XDG_CACHE_HOME=.scarb_cache STARKNET_RPC_URL=https://api.cartridge.gg/x/starknet/sepolia sozo migrate --profile release --wait --use-blake2s-casm-class-hash`
  tx: n/a
  notes: Found changes (2 classes declared, resources registered). Previous migration might have missed changes due to stale cache/target.
- date: 2025-12-16 17:36 UTC
  env: release (Sepolia)
  action: register DAI token (`register_token_for_item`)
  command: `sozo execute -P release Warpacks-token_factory register_token_for_item 50 str:DAI str:DAI 0x050D4dA9f66589eadAA1D5e31CF73B08Ac1a67c8B4DCD88e6Fd4Fe501C628aF2 --wait --rpc-url https://api.cartridge.gg/x/starknet/sepolia`
  tx: `0x0597f1908115d25d626dc7bfb79a76a78167c1d2c831ad1cba7f2dd8ccf49cf0`
  notes: Successful. Token 0x050D... registered for item 50.
- date: 2025-12-16 17:40 UTC
  env: release (Sepolia)
  action: add recipe (2 DAI + 1 Dagger -> 1 Greatsword)
  command: `sozo execute -P release Warpacks-recipe_system add_recipe 2 50 6 2 2 1 22 --wait --rpc-url https://api.cartridge.gg/x/starknet/sepolia`
  tx: `0x00d4b8a1a8efc6a99ab93f2f752ab345ec4f1aa1272a402be1508966db1fe036`
  notes: Recipe added.
    **Breakdown of arguments**: `2 50 6 2 2 1 22`
    - `item_ids_len`: 2
    - `item_ids`: [50 (DAI), 6 (Dagger)]
    - `amounts_len`: 2
    - `amounts`: [2 (DAI), 1 (Dagger)]
    - `result_item_id`: 22 (Greatsword)
    **Logic**: Player must consume 2 DAI and 1 Dagger to craft 1 Greatsword.
- date: 2025-12-16 18:05 UTC
  env: release (Sepolia)
  action: migrate (add `update_token_for_item`)
  command: `sozo build --profile release && sozo migrate --profile release ...`
  tx: n/a
  notes: Updated `token_factory` contract to allow updating token addresses.
- date: 2025-12-16 18:06 UTC
  env: release (Sepolia)
  action: update DAI token address (`update_token_for_item`)
  command: `sozo execute -P release Warpacks-token_factory update_token_for_item 50 0x6f2a0dfeff180133de890ad69c6ba294574c5f34a67890fd22464f348c4d03c --wait --rpc-url https://api.cartridge.gg/x/starknet/sepolia`
  tx: `0x00844a2998321bcc92c5e05f47aee57952ddc4ff31608baa4a33c6aa350d58de`
  notes: Updated item 50 (DAI) token address to `0x6f2a0dfeff180133de890ad69c6ba294574c5f34a67890fd22464f348c4d03c`.
- date: 2025-12-16 18:48 UTC
  env: release (Sepolia)
  action: migrate (add `is_legacy` support)
  command: `sozo build --profile release && sozo migrate --profile release ...`
  tx: n/a
  notes: Added `is_legacy` field to `TokenRegistry`; updated `token_factory` and `storage_bridge` to handle legacy tokens (CamelCase selectors).
- date: 2025-12-16 18:50 UTC
  env: release (Sepolia)
  action: update DAI token to legacy (`update_token_for_item`)
  command: `sozo execute -P release Warpacks-token_factory update_token_for_item 50 0x6f2a0dfeff180133de890ad69c6ba294574c5f34a67890fd22464f348c4d03c 1 --wait --rpc-url https://api.cartridge.gg/x/starknet/sepolia`
  tx: `0x070c8ebff375e393cae6faa086b447221118df3538c579f4c43b242936314833`
  notes: Marked DAI (item 50) as legacy token (`is_legacy=true`).
- date: 2025-12-16 19:25 UTC
  env: release (Sepolia)
  action: migrate (relax rarity validation)
  command: `sozo build --profile release && sozo migrate --profile release ...`
  tx: n/a
  notes: Updated `item_system` to allow `rarity=0` for any item type.
- date: 2025-12-16 19:27 UTC
  env: release (Sepolia)
  action: update DAI rarity to 0
  command: `sozo execute -P release Warpacks-item_system add_item 50 str:'DAI' 3 0 1 1 1 0 0 0 100 0 0 0 --wait --rpc-url https://api.cartridge.gg/x/starknet/sepolia`
  tx: `0x023498d5bcfc7cfadf8f683cc419e5c522beaab01fb96df784875eb5cd1ac56c`
  notes: Rarity set to 0 to prevent DAI from appearing in Shop Rerolls.
- date: 2025-12-16 19:35 UTC
  env: release (Sepolia)
  action: batch update items (`batch_add_items`)
  command: `sozo build --profile release && sozo migrate ... && sozo execute -P release Warpacks-item_system batch_add_items ...`
  tx: `0x0218fd6def1b0190885b6ec11866d977134f755cb5e8976abecc8e40b12224f4`
  notes: Redeployed items to update stats for `AmuletOfFury` (effectStacks 1->2, chance 45->55).





