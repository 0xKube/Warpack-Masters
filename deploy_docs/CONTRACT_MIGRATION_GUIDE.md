# Contract Migration Guide (Sepolia, Dojo 1.8.x)

Это сжатый чек-лист, как мы мигрируем изменения контрактов Warpack Masters на Starknet Sepolia. Команды основаны на последней миграции (world `0x07c7e6cbe015e7a1ee77c4e29b859894c8eae03ac1ff69361df6bd8c262c9d47`).

## 0. Предусловия
- Установлено: `sozo 1.8.2`, `scarb 2.13.1`, `cairo 2.13.1`.
- Env:
  - `STARKNET_RPC_URL=https://starknet-sepolia.g.alchemy.com/starknet/version/rpc/v0_9/iOVGW3WTTEPV8_IPJI5X68y5_lMStBKN`
  - `STARKNET_ACCOUNT` / `STARKNET_PRIVATE_KEY` указывают на деплойер (см. `account.json`).
- Используем локальные кэши, чтобы не писать в `$HOME`:
  - `SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target XDG_CACHE_HOME=.scarb_cache`
  - Если DNS до scarbs.xyz нестабилен: добавить `SCARB_OFFLINE=true`.

## 1. Сборка
```bash
SCARB_OFFLINE=true \
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target XDG_CACHE_HOME=.scarb_cache \
sozo build --profile release
```

## 2. Миграция на Sepolia
```bash
SCARB_OFFLINE=true \
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target XDG_CACHE_HOME=.scarb_cache \
sozo migrate --profile release --wait --use-blake2s-casm-class-hash
```
- Проверяем вывод: мир должен остаться `0x07c7...c9d47`, manifest обновится.
- После миграции **скопировать `manifest_release.json` во фронт** (иначе Torii/фронт смотрят на старые адреса).

## 3. (Опционально) Перерегистрировать Gold и MINTER_ROLE
Если менялись адреса систем (actions/fight/token_factory) или нужно “освежить” роли:
```bash
SCARB_OFFLINE=true \
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target XDG_CACHE_HOME=.scarb_cache \
STARKNET_RPC_URL=$STARKNET_RPC_URL \
scripts/init_register_gold.sh release 0x0689731c6c6df7798e601d730f18a0eae7f9a138f9ac9c54d27d94b423b29eca
```
Скрипт:
- Регистрирует Gold в `token_factory`.
- Выдаёт MINTER_ROLE (`0x032d…956a6`) для `actions` и `fight`.

## 4. (Опционально) Засеять данные
Если окружение свежее или нужно обновить каталоги:
```bash
# Каталог предметов
SCARB_OFFLINE=true STARKNET_RPC_URL=$STARKNET_RPC_URL scripts/init_batch_add_items.sh release

# Преднастроенные dummy (упадёт с "name already exists", если уже есть)
SCARB_OFFLINE=true STARKNET_RPC_URL=$STARKNET_RPC_URL scripts/init_pre_dummies.sh release

# Рецепты (Augmented Dagger)
SCARB_OFFLINE=true STARKNET_RPC_URL=$STARKNET_RPC_URL scripts/init_add_recipes.sh release
```
Каждый скрипт читает адреса из свежего `manifest_release.json`.

## 5. Что проверить после миграции
- `manifest_release.json` содержит актуальные адреса контрактов (actions/fight/token_factory).
- В бою не возникает `Caller is missing role` (значит MINTER_ROLE на Gold выдан).
- Фронт смотрит на новый manifest + Torii endpoint `https://api.cartridge.gg/x/warpack-masters/torii/graphql`.

## Быстрый tl;dr
1) build с кэшами, 2) migrate с `--use-blake2s-casm-class-hash`, 3) скопировать manifest во фронт, 4) при необходимости `init_register_gold.sh` + seeding скрипты.***
