WARNING: Legacy запись для старого мира `0xd622...` (до ноябрьского редеплоя). Актуальные шаги и адреса смотрите в `DEPLOY_PROGRESS_2.md` / `COMPLETE_DEPLOY_PROCESS.md`. Фронт/Torii с этими командами дадут `Player already exists`/connection refused, если не переключить env на новый мир.

## Что сделано

1. Добавил пин `starknet-foundry 0.52.0` в `.tool-versions` и через `asdf install` поставил свежий Foundry, чтобы получить `sncast` с поддержкой RPC 0.9. Старая 0.48.1 дергала несовместимые RPC и ловила `Invalid block id`.
2. `sncast 0.52.0` успешно пересобрал проект и задекларировал `MintableERC20Token` на Sepolia:
   ```
   sncast --accounts-file sncast_accounts_manual.json --account deployer declare --contract-name MintableERC20Token --url https://api.cartridge.gg/x/starknet/sepolia
   ```
   Class hash `0x72313c5be9b40fd661ed143cf1036606cb2fd1839c545ac1a52bedf4781af6f`, tx `0x68aafcc40a49c525785fdf5b6a4bbd1612e93372f2b9bedf93f4eace0a92230`.

## Новое

### 1. Деплой Gold ERC20
```
sncast --wait --accounts-file sncast_accounts_manual.json --account deployer \
  deploy --class-hash 0x72313c5be9b40fd661ed143cf1036606cb2fd1839c545ac1a52bedf4781af6f \
  --constructor-calldata 0x00 0x476f6c64 0x04 0x00 0x676f6c64 0x04 \
  0x0324887e3ed05ca2ca03f9245f97c6edcb48d8b85865a8c8af3035a5b1c6142b \
  0x0324887e3ed05ca2ca03f9245f97c6edcb48d8b85865a8c8af3035a5b1c6142b \
  0x0324887e3ed05ca2ca03f9245f97c6edcb48d8b85865a8c8af3035a5b1c6142b \
  --url https://api.cartridge.gg/x/starknet/sepolia
```
- Контракт задеплоен по адресу `0x00a1c64e2d85db6b90a3a2c309b494aba992cffa1029856b4f9208395f409872`.
- Tx: `0x009bae05459182ce65705b11660eb5503402bc1ab574b1292555ac1f39951b2f`.

### 2. Выдача MINTER_ROLE
```
sncast --wait --accounts-file sncast_accounts_manual.json --account deployer invoke \
  --contract-address 0x00a1c64e2d85db6b90a3a2c309b494aba992cffa1029856b4f9208395f409872 \
  --function grant_role \
  --calldata 0x032df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6 \
            0x522fe07fe4ddff54b38779f3739e6ac16bba449a18de1e8ff389342f2a680af
sncast --wait --accounts-file sncast_accounts_manual.json --account deployer invoke \
  --contract-address 0x00a1c64e2d85db6b90a3a2c309b494aba992cffa1029856b4f9208395f409872 \
  --function grant_role \
  --calldata 0x032df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6 \
            0x228f2dc15821c4720369b3fc90cd2ce2168e69036132f896b52c80227845edc
```
- Tx fight_system: `0x00e0494b4d5af7a016bc4d032f61f7417c0587bd31ed23c05effa8dd5831b442`.
- Tx actions: `0x073a08d0da78b5b0117b162baa5cf1455e51216632d84d378d155b0006f82baf`.

### 3. Регистрация в token_factory
```
sncast --wait --accounts-file sncast_accounts_manual.json --account deployer invoke \
  --contract-address 0x796b11c38460d19e96a8bb95f7309e5195f2d90e3df616b9edd7755d63fa1be \
  --function reigster_gold \
  --calldata 0x00a1c64e2d85db6b90a3a2c309b494aba992cffa1029856b4f9208395f409872 \
  --url https://api.cartridge.gg/x/starknet/sepolia
```
- Tx: `0x01480a7e1c964b00be17ab272cb879e558aaf996a09abe11d49a0f17202b2bc2`.

На этом деплой Gold ERC20 + выдача прав + регистрация завершены. Следующие действия: проверить, что `token_factory.get_token_address` возвращает новый адрес в игре и обновить документацию/конфиги клиента при необходимости.

## Проверки

- Убедились, что `Warpacks-token_factory` возвращает нужный адрес:
  ```
  sncast call --contract-address 0x796b11c38460d19e96a8bb95f7309e5195f2d90e3df616b9edd7755d63fa1be \
    --function get_token_address \
    --calldata 9999 \
    --url https://api.cartridge.gg/x/starknet/sepolia
  ```
  Ответ: `0x00a1c64e2d85db6b90a3a2c309b494aba992cffa1029856b4f9208395f409872`.

- Обновили `deploy_docs/SETUP.md`, `scripts/setup_contracts.sh` и `scripts/init_register_gold.sh`, чтобы там фигурировали новые class hash/адрес Gold, регистрация в token_factory и актуальные команды `sncast`.

## Spawn персонажа

1. Подготовили стейт предметов на release окружении:
   ```
   export STARKNET_RPC_URL=https://api.cartridge.gg/x/starknet/sepolia
   scripts/init_batch_add_items.sh release
   ```
   Tx: `0x077c1c66263eba832dac9d7d17232e42a375b010264cefe3dc66df9850356266`.

2. Заспаунили игрока `Alice` классом Warrior:
   ```
   sncast --wait --accounts-file sncast_accounts_manual.json --account deployer \
     invoke --contract-address 0x228f2dc15821c4720369b3fc90cd2ce2168e69036132f896b52c80227845edc \
     --function spawn \
     --calldata 280991720293 0 \
     --url https://api.cartridge.gg/x/starknet/sepolia
   ```
   Tx: `0x069e7907d6b92ffd0e19faeb0aee56d488e5122d3c3475bc63f0c110a4f11589`.

3. Проверили модель `Warpacks-Character` через sozo:
   ```
   export STARKNET_RPC_URL=https://api.cartridge.gg/x/starknet/sepolia
   sozo model get -P release Warpacks-Character \
     0x0324887e3ed05ca2ca03f9245f97c6edcb48d8b85865a8c8af3035a5b1c6142b \
     --world 0xd622721bcdf3816ae358da7e46bd804f51f72908cbb348cd78484c6cabed56 \
     --rpc-url $STARKNET_RPC_URL
   ```
   Ответ содержит `name: 0x...416c696365 (\"Alice\"), wmClass: WMClass::Warrior, birthCount: 1`, что подтверждает успешный spawn.

## Torii на Slot

1. Установлен Slot CLI (`curl -L https://slot.cartridge.sh | bash`, далее `slotup`), авторизация через `slot auth login`.
2. Создан конфиг `torii_slot.toml`:
   ```toml
   world_address = "0xd622721bcdf3816ae358da7e46bd804f51f72908cbb348cd78484c6cabed56"
   rpc = "https://api.cartridge.gg/x/starknet/sepolia"

   [indexing]
   preconfirmed = true
   namespaces = ["Warpacks"]
   external_contracts = true

   [server]
   http_addr = "0.0.0.0"
   http_port = 8080
   http_cors_origins = ["*"]

   [relay]
   port = 9090
   webrtc_port = 9091
   websocket_port = 9092

   [grpc]
   grpc_addr = "0.0.0.0"
   grpc_port = 50051
   ```
3. Деплой: `slot deployments create warpack-masters torii -c torii_slot.toml`. Slot поднял Torii v1.8.9 (basic tier) по адресу `https://api.cartridge.gg/x/warpack-masters/torii/graphql` (после редеплоя мира обновляйте `torii_slot.toml`, запускайте `slot deployments update ...`, и копируйте свежий `manifest_release.json` в фронт).
4. Мониторинг: `slot deployments logs warpack-masters torii -f`. Обновления/перезапуски — через `slot deployments update ...` с тем же конфигом.
