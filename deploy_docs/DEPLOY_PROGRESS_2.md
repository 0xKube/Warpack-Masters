# Deployment Progress (Nov 2025 refresh)

## Tooling
- Dojo/sozo: 1.8.2 (Dojo tag v1.8.0), Cairo/scarb: 2.13.1, `--use-blake2s-casm-class-hash` for Sepolia.
- Account: deployer `0x0324887e3ed05ca2ca03f9245f97c6edcb48d8b85865a8c8af3035a5b1c6142b`.
- RPC: Alchemy Sepolia `https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_9/iOVGW3WTTEPV8_IPJI5X68y5_lMStBKN`.

## World migration
- Built with fresh caches: `SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target sozo build --profile release`.
- Migrated with blake2s CASM hashing:  
  `sozo migrate --profile release --wait --use-blake2s-casm-class-hash`.
- New world address: `0x07c7e6cbe015e7a1ee77c4e29b859894c8eae03ac1ff69361df6bd8c262c9d47`.
- All 34 classes declared, 34 resources registered, 9 contracts initialized, permissions synced.  
  Manifest updated: `manifest_release.json`.

-## Gold token
- Declared MintableERC20Token via sozo: class hash `0x053f5b433645cbd46405fd90e2855902361fee093dd8031cba1e8464ab15a4a1`.
- Deployed Gold with admin/minter/upgrader = deployer:  
  Address `0x0689731c6c6df7798e601d730f18a0eae7f9a138f9ac9c54d27d94b423b29eca` (tx `0x063a873016fb4b54f85d4624136ea6dd4816edee5c1a4406d31709838fae642b`).
- Registered Gold in token_factory (tx `0x014e55bcac0513ab76e404c3864529f679377fc7d80565a45e091d379731af91`).
- Granted `MINTER_ROLE` (`0x032df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6`) to systems that mint gold: fight_system `0x1e9c91163b28a0cf2ebeb8311df4f57f7788b8f9bc10707d8f5243df57d97ea` and actions `0x6cf6450c132752fbf3ace05d82f5d61fac097a6f62d0abd0b2b04a204ac16e6`.
  - (latest refresh via `scripts/init_register_gold.sh release <gold>` after UI error “Caller is missing role”): register tx `0x0271e50e8bf1834b3ff80fdfb985d8e85d47c46ec153241ce316f102652bc5a0`, grant actions tx `0x061289505819d4483b6ab60b79371e4bef8025614cfc37805e3af162ee587df0`, grant fight tx `0x03b3c2baae8c774eb5aeacec3e39992bc6e1be4774c31f1610f633bf09a8aa76`.

## Data seeding (release world)
- Items seeded: `scripts/init_batch_add_items.sh release` (tx `0x02b02632bbdda9c7deef3d2f0d87bfaa537cc8415122f4e0b79b810b6f9043e9`).
- Predefined dummies seeded: `scripts/init_pre_dummies.sh release` (series of txs, first `0x055f9cb309b31b06be996e1c0a923a0afc699d8fab17be467dc6b757a62d6d17`, last `0x059ea7aafc61ec67666a26dc55801bfa3e96673d68dbb19ac5b51fe6783a26f5`).

## Torii
- Updated `torii_slot.toml` world to `0x07c7e6cbe015e7a1ee77c4e29b859894c8eae03ac1ff69361df6bd8c262c9d47`, rpc `https://api.cartridge.gg/x/starknet/sepolia`.
- Applied update: `slot deployments update warpack-masters torii --config torii_slot.toml`.
- GraphQL endpoint remains `https://api.cartridge.gg/x/warpack-masters/torii/graphql` (now indexing the new world).

## Findings / pitfalls
- Сообщение фронта `can't reach deployment ... http://torii.ext-warpack-masters.svc.us-east4/graphql` оказалось ссылкой на старый Torii. После удаления `slot deployments delete warpack-masters torii -f` и пересоздания с новым world адресом все отдается по `https://api.cartridge.gg/x/warpack-masters/torii/graphql`.
- Ошибка `Player already exists` была из-за того, что фронт смотрел на старый world `0xd622...` где под этим аккаунтом уже есть персонаж. При обновлении env + `manifest_release.json` на новые значения (`0x07c7...d47`) спавн проходит.
- Всегда копируйте свежий `manifest_release.json` в фронт — только тогда адреса систем/моделей совпадут с Torii/миром.

## Artifacts/paths
- World manifest: `manifest_release.json` (world addr above). **Скопируйте в фронт при деплое**, чтобы адреса систем/моделей совпадали.
- Token class artifact: `target/release/warpack_masters_MintableERC20Token.contract_class.json`.
- Account details stored in `sncast_accounts_manual.json` and `account.json` (for sepolia deployer).

## Next steps
- Point Torii/frontend to the new world address and manifest.
- If metadata upload is needed, set IPFS creds and rerun `sozo metadata` (migration skipped IPFS upload).***
