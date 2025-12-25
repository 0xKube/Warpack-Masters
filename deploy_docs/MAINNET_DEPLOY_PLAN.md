# MAINNET_DEPLOY_PLAN.md — Warpack Masters (Dojo) Starknet Mainnet Deployment Plan

> Цель: задеплоить новый Dojo world и весь пост-деплой “обвязки” (GameConfig/STRK fee, Gold ERC20, wiring ролей, сидинг данных, Torii/Slot, фронт) **на Starknet Mainnet**, не экспозя приватные ключи в Codex/облако.

---

## 0) Жёсткие правила безопасности (обязательно)

### Что нельзя делать
- **Нельзя** вставлять seed phrase / private key / keystore password в чат/контекст Codex (ни в текст, ни в файлы).
- **Нельзя** запускать mainnet-деплой из *Codex Cloud delegation* (любая облачная среда = не место для mainnet-ключей).
- **Нельзя** хранить ключи внутри репозитория (включая `.env`, `account.json` с нешифрованным ключом и т.п.), если Codex может это прочитать.

### Что делать вместо этого
- Все шаги, где есть подпись транзакций, выполняй **в отдельном локальном терминале** (не через “Run” из Codex), чтобы Codex не видел ни env, ни stdout/stderr.
- Ключи держи только локально: лучше всего **шифрованный keystore** + пароль руками, либо аппаратный кошелёк/мультисиг для прав владения.
- Владение и “опасные” админ-права (owner/roles) — по возможности сразу передавать на **мультисиг** (Safe) или “холодный” адрес.

---

## 1) Подготовка окружения (один раз)

### 1.1. Версии тулчейна (как в последнем успешном деплое)
- `sozo` / Dojo toolchain: v1.8.x
- `scarb`: v2.13.x
- Cairo: совместимый с указанным scarb

Проверь:
```bash
sozo --version
scarb --version
```

### 1.2. (Опционально) “анти-утечка” для Codex
Если у тебя Codex установлен в IDE, настрой так, чтобы он не подхватывал твои секретные env vars:
- включи allowlist на переменные окружения (только PATH/HOME и т.п.)
- включи режим, где он не исполняет команды без твоего клика

*(Это делается в `~/.codex/config.toml`, но сами ключи туда НЕ добавляй.)*

---

## 2) Preflight checklist (перед первым mainnet запуском)

1) **Сделай dry-run на Sepolia** текущего коммита (build + migrate) — чтобы mainnet не был “первой попыткой”.
2) В репозитории:
   - нет ключей в файлах (`.env*`, `account.json` с приватником, `*.keystore` и т.п.)
   - `.gitignore` покрывает любые локальные файлы с секретами
3) У deployer-аккаунта:
   - достаточно ETH/STRK на комиссии (gas) на mainnet
   - адрес deployer-а корректный и контролируется тобой
4) **STRK address** для mainnet подтверждён из официального источника (см. пункт 4.2).

---

## 3) Конфиги под mainnet (без секретов в репе)

### 3.1. Создай `dojo_mainnet.toml` (или профиль `mainnet` в существующем файле)
Идея: в репозитории храним **только** “несекретные” параметры.
Пример:

```toml
# dojo_mainnet.toml (НЕ хранить тут приватный ключ)
[env]
rpc_url = "<MAINNET_RPC_URL>"
account_address = "<DEPLOYER_ADDRESS_HEX>"
# account_file / accounts path — по твоей схеме
# Если используешь account.json, путь лучше задавать локально через env (например STARKNET_ACCOUNT), а не коммитить.
```

> Важно: если у тебя сегодня всё работает через env:
> - `STARKNET_RPC_URL`
> - `DOJO_ACCOUNT_ADDRESS`
> - `DOJO_PRIVATE_KEY`
> - (опционально) `STARKNET_ACCOUNT` если используешь account.json
>
> То оставь в репо только `rpc_url` и `account_address`, а пути/ключ — только локально.

### 3.2. Локальные env vars (в отдельном терминале, без истории)
Открой отдельный терминал и отключи историю:
```bash
export HISTFILE=/dev/null
set +o history 2>/dev/null || true
```

Далее выставь переменные **только в этом терминале**:
```bash
export STARKNET_RPC_URL="<MAINNET_RPC_URL>"
export DOJO_ACCOUNT_ADDRESS="<DEPLOYER_ADDRESS_HEX>"
export DOJO_PRIVATE_KEY="<PASTE_PRIVATE_KEY_HERE_MANUALLY>"
# опционально, если используешь account.json:
# export STARKNET_ACCOUNT="<ABS_PATH_TO_ACCOUNT_JSON>"
```

> Совет: не сохраняй эти команды в скрипты/файлы. Вводи вручную.

---

## 4) Деплой World (Migration)

### 4.1. Build (mainnet профиль)
(Как у тебя было, с локальными кешами)
```bash
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
  sozo build --profile=mainnet
```

Проверка: в `target/mainnet` есть артефакты Sierra.

### 4.2. Критически важно: STRK address для mainnet
- `config_system` получает STRK address через `dojo_init` во время миграции.
- Если ошибёшься адресом STRK на mainnet — придётся **передеплоить world**.

**Действия:**
1) Найди официальный STRK token address для mainnet.
2) Внеси его в конфиг, который читает твоя миграция (например, `dojo_mainnet.toml` для профиля mainnet).

*(Я специально не вписываю адрес тут, чтобы ты случайно не зафиксировал неверный — возьми из официального источника и вставь.)*

### 4.3. Migrate to Mainnet
```bash
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
  sozo migrate --profile=mainnet --wait --use-blake2s-casm-class-hash
```

**Результат:**
- обновится `manifest_mainnet.json`.
- появится новый **World Address** (запиши его сюда):

```text
MAINNET WORLD ADDRESS: 0x05a709be85a3f656230e4887a1c212fdf90d50e7b67c047cf5c153e030603e61
```

### 4.4. После миграции — “заморозь” артефакты
1) Скопируй свежий `manifest_mainnet.json` в фронтенд (в ту папку, откуда он читается).
2) Закоммить “несекретные” изменения (manifest обычно коммитят, если это часть релизного артефакта) **в отдельную ветку релиза**.
3) Зафиксируй:
   - git commit hash
   - world address
   - время деплоя

---

## 5) Post-Deployment: GameConfig (STRK + rebirth fee)

### 5.1. Быстрая проверка через Torii GraphQL
После поднятия/обновления Torii (см. пункт 8), проверь модель:

```graphql
query {
  warpacksGameConfigModels {
    edges { node { id rebirth_fee strk_address } }
  }
}
```

Ожидаемо:
- `strk_address` = твой mainnet STRK address
- `rebirth_fee` != 0 (если fee должен быть включён)

### 5.2. Установить/обновить rebirth_fee
**Предпочтение:** НЕ передавать ключ в аргументах команд. Используй env vars и локальный терминал.

Пример (если твой `sozo execute` поддерживает всё через текущие env):
```bash
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
  sozo execute --profile=mainnet --wait --use-blake2s-casm-class-hash \
    Warpacks-config_system set_rebirth_fee <FEE_WEI>
```

Если тебе всё же нужно явно передавать account/rpc (оставь `<PK>` пустым и используй env):
```bash
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
  sozo execute --profile=mainnet --wait --use-blake2s-casm-class-hash \
    --account-address "$DOJO_ACCOUNT_ADDRESS" --rpc-url "$STARKNET_RPC_URL" \
    Warpacks-config_system set_rebirth_fee <FEE_WEI>
```

> Fee аккумулируется на `actions` system; для вывода — `withdraw_strk` на `Warpacks-actions`.

### 5.3. Напоминание для игроков
После включения fee игроки должны один раз `approve` STRK на `actions` address, иначе `spawn/rebirth` упадёт на `transfer_from`.

---

## 6) Gold ERC20 (declare → deploy → register → grant MINTER_ROLE)

> В mainnet всё то же, что на Sepolia, только сеть и новые адреса систем из нового manifest.

### 6.1. Declare Gold class
```bash
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
  sozo declare --profile=mainnet --wait --use-blake2s-casm-class-hash \
    target/mainnet/warpack_masters_MintableERC20Token.contract_class.json
```

Запиши:
```text
MAINNET GOLD CLASS HASH: 0x053f5b433645cbd46405fd90e2855902361fee093dd8031cba1e8464ab15a4a1
```

### 6.2. Deploy Gold
```bash
sozo deploy --profile=mainnet --wait --use-blake2s-casm-class-hash \
  0x053f5b433645cbd46405fd90e2855902361fee093dd8031cba1e8464ab15a4a1 \
  --constructor-calldata str:CRAFT str:CRAFT "$DOJO_ACCOUNT_ADDRESS" "$DOJO_ACCOUNT_ADDRESS" "$DOJO_ACCOUNT_ADDRESS"
```

Запиши:
```text
MAINNET GOLD ADDRESS: 0x072950c042e6b14341bdf92778da468b91f03886da23598742e44ae885aeea2a
```

### 6.3. Register in token_factory
```bash
sozo execute --profile=mainnet --wait --use-blake2s-casm-class-hash \
  Warpacks-token_factory reigster_gold <MAINNET_GOLD_ADDRESS>
```

### 6.4. Grant MINTER_ROLE
MINTER_ROLE:
```text
0x032df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6
```

Рекомендуемый способ:
```bash
STARKNET_RPC_URL=<MAINNET_RPC_URL> scripts/init_register_gold.sh mainnet <MAINNET_GOLD_ADDRESS>
```

Скрипт:
- читает `manifest_mainnet.json`;
- регистрирует Gold в `token_factory`;
- выдаёт MINTER_ROLE системам, которые вызывают `mint`.

Если вручную (подставь адреса из `manifest_mainnet.json`):
```bash
sozo execute ... <GoldAddress> grant_role <MINTER_ROLE> <fight_system_address>
sozo execute ... <GoldAddress> grant_role <MINTER_ROLE> <actions_address>
```

---

## 7) Seed game data (items + dummies + опционально recipes/tokens)

После wiring Gold:
```bash
STARKNET_RPC_URL=<MAINNET_RPC_URL> scripts/init_batch_add_items.sh mainnet
STARKNET_RPC_URL=<MAINNET_RPC_URL> scripts/generated/prefine_dummies_mainnet.sh
```

Опционально:
```bash
STARKNET_RPC_URL=<MAINNET_RPC_URL> scripts/init_add_recipes.sh mainnet
STARKNET_RPC_URL=<MAINNET_RPC_URL> scripts/init_batch_create_tokens.sh mainnet
```

---

## 8) Torii / Cartridge Slot (mainnet)

### 8.1. torii_slot.toml
Создай/обнови `torii_slot_mainnet.toml` (или параметризуй существующий), чтобы:
- RPC указывал на mainnet
- world address был новый mainnet world

### 8.2. Update deployment
Примерно как у тебя было:
```bash
slot deployments update <SLOT_NAME> torii --config torii_slot_mainnet.toml
```

Если нужны “жёсткие” пересоздания:
```bash
slot deployments delete <SLOT_NAME> torii -f
slot deployments create <SLOT_NAME> torii --config torii_slot_mainnet.toml
```

Запиши:
```text
MAINNET TORII GRAPHQL: https://api.cartridge.gg/x/warpacks/torii/graphql
```

---

## 9) Frontend wiring (mainnet)

### 9.1. ENV vars
Обнови (пример — под mainnet):
```text
NEXT_PUBLIC_RPC_URL=https://api.cartridge.gg/x/starknet/mainnet
NEXT_PUBLIC_GRAPHQL_URL=https://api.cartridge.gg/x/<SLOT_NAME>/torii/graphql
NEXT_PUBLIC_WORLD_ADDRESS=<MAINNET_WORLD_ADDRESS>
NEXT_PUBLIC_CARTRIDGE_SLOT=<SLOT_NAME>
NEXT_PUBLIC_CARTRIDGE_NAMESPACE=Warpacks
```

### 9.2. Manifest sync
После каждой миграции обязательно:
- копируй свежий `manifest_mainnet.json` во фронт
- деплой фронта делай **только после** обновления manifest + Torii.

---

## 10) Smoke test (после деплоя)

1) Torii GraphQL доступен и отдаёт модели.
2) `warpacksGameConfigModels`:
   - правильный `strk_address`
   - `rebirth_fee` корректный
3) Spawn игрока:
   - не падает на “Player already exists” (проверка, что фронт смотрит на новый world)
4) Gold:
   - зарегистрирован в token_factory
   - MINTER_ROLE есть у `fight_system` и `actions`
5) Награды/боёвка:
   - mint проходит
   - нет `Caller is missing role`
6) Fee:
   - при non-zero fee rebirth требует approve STRK на actions

---

## 11) План отката / типовые фейлы

- **Неверный STRK address** в `dojo_init` → только redeploy world (миграция заново).
- `rebirth_fee = 0` и fee должен быть → `set_rebirth_fee`.
- `Caller is missing role` на Gold mint → перезапусти `init_register_gold.sh` или вручную `grant_role`.
- Фронт/тории смотрит на старый мир → обнови env + manifest + torii deployment.

---

## 12) Места, куда вписывать итоговые адреса (после mainnet деплоя)

```text
MAINNET WORLD ADDRESS:      <...>
MAINNET ACTIONS ADDRESS:    <...>  (из manifest)
MAINNET FIGHT SYSTEM:       <...>  (из manifest)
MAINNET TOKEN FACTORY:      <...>  (из manifest)

MAINNET GOLD CLASS HASH:    <...>
MAINNET GOLD ADDRESS:       <...>

MAINNET TORII GRAPHQL:      <...>
FRONTEND RPC URL:           https://api.cartridge.gg/x/starknet/mainnet
```

---

## 13) “Команды одним блоком” (шпаргалка)

> Запускать в отдельном локальном терминале, где выставлены env vars и выключена история.

```bash
# 0) build
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
  sozo build --profile=mainnet

# 1) migrate world (mainnet)
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
  sozo migrate --profile=mainnet --wait --use-blake2s-casm-class-hash

# 2) (optional) set rebirth fee
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
  sozo execute --profile=mainnet --wait --use-blake2s-casm-class-hash \
    Warpacks-config_system set_rebirth_fee <FEE_WEI>

# 3) gold declare/deploy (если не через готовые скрипты)
SCARB_CACHE=.scarb_cache SCARB_CONFIG=.scarb_config SCARB_TARGET_DIR=target \
  sozo declare --profile=mainnet --wait --use-blake2s-casm-class-hash \
    target/mainnet/warpack_masters_MintableERC20Token.contract_class.json

sozo deploy --profile=mainnet --wait --use-blake2s-casm-class-hash \
  0x053f5b433645cbd46405fd90e2855902361fee093dd8031cba1e8464ab15a4a1 \
  --constructor-calldata str:CRAFT str:CRAFT "$DOJO_ACCOUNT_ADDRESS" "$DOJO_ACCOUNT_ADDRESS" "$DOJO_ACCOUNT_ADDRESS"

# 4) wire gold + roles
STARKNET_RPC_URL=<MAINNET_RPC_URL> scripts/init_register_gold.sh mainnet <MAINNET_GOLD_ADDRESS>

# 5) seed
STARKNET_RPC_URL=<MAINNET_RPC_URL> scripts/init_batch_add_items.sh mainnet
STARKNET_RPC_URL=<MAINNET_RPC_URL> scripts/generated/prefine_dummies_mainnet.sh
```

---

**Готово.** Этот файл специально сделан с плейсхолдерами для адресов/ключей и с разделением “Codex помогает готовить” vs “подпись делаю вручную локально”.
