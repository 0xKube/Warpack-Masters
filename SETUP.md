## Declare MintableERC20Token (Sepolia)

```
sncast --accounts-file sncast_accounts_manual.json \
  --account deployer \
  declare --contract-name MintableERC20Token \
  --url https://api.cartridge.gg/x/starknet/sepolia
```

- Class hash: `0x72313c5be9b40fd661ed143cf1036606cb2fd1839c545ac1a52bedf4781af6f`
- Tx: `0x68aafcc40a49c525785fdf5b6a4bbd1612e93372f2b9bedf93f4eace0a92230`

## Deploy the Gold ERC20

```
sncast --wait --accounts-file sncast_accounts_manual.json \
  --account deployer \
  deploy --class-hash 0x72313c5be9b40fd661ed143cf1036606cb2fd1839c545ac1a52bedf4781af6f \
  --constructor-calldata 0x00 0x476f6c64 0x04 0x00 0x676f6c64 0x04 \
    0x0324887e3ed05ca2ca03f9245f97c6edcb48d8b85865a8c8af3035a5b1c6142b \
    0x0324887e3ed05ca2ca03f9245f97c6edcb48d8b85865a8c8af3035a5b1c6142b \
    0x0324887e3ed05ca2ca03f9245f97c6edcb48d8b85865a8c8af3035a5b1c6142b \
  --url https://api.cartridge.gg/x/starknet/sepolia
```

- Contract: `0x00a1c64e2d85db6b90a3a2c309b494aba992cffa1029856b4f9208395f409872`
- Tx: `0x009bae05459182ce65705b11660eb5503402bc1ab574b1292555ac1f39951b2f`

## Grant `MINTER_ROLE`

```
sncast --wait --accounts-file sncast_accounts_manual.json --account deployer \
  invoke --contract-address 0x00a1c64e2d85db6b90a3a2c309b494aba992cffa1029856b4f9208395f409872 \
  --function grant_role \
  --calldata 0x032df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6 \
            0x522fe07fe4ddff54b38779f3739e6ac16bba449a18de1e8ff389342f2a680af \
  --url https://api.cartridge.gg/x/starknet/sepolia

sncast --wait --accounts-file sncast_accounts_manual.json --account deployer \
  invoke --contract-address 0x00a1c64e2d85db6b90a3a2c309b494aba992cffa1029856b4f9208395f409872 \
  --function grant_role \
  --calldata 0x032df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6 \
            0x228f2dc15821c4720369b3fc90cd2ce2168e69036132f896b52c80227845edc \
  --url https://api.cartridge.gg/x/starknet/sepolia
```

- Fight system tx: `0x00e0494b4d5af7a016bc4d032f61f7417c0587bd31ed23c05effa8dd5831b442`
- Actions tx: `0x073a08d0da78b5b0117b162baa5cf1455e51216632d84d378d155b0006f82baf`

## Register Gold in the Token Factory

```
sncast --wait --accounts-file sncast_accounts_manual.json --account deployer \
  invoke --contract-address 0x796b11c38460d19e96a8bb95f7309e5195f2d90e3df616b9edd7755d63fa1be \
  --function reigster_gold \
  --calldata 0x00a1c64e2d85db6b90a3a2c309b494aba992cffa1029856b4f9208395f409872 \
  --url https://api.cartridge.gg/x/starknet/sepolia
```

- Tx: `0x01480a7e1c964b00be17ab272cb879e558aaf996a09abe11d49a0f17202b2bc2`
