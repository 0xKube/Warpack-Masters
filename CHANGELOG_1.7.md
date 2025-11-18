# Changelog - Dojo 1.7 Upgrade

## Version 1.7.0 - 2025-11-18

### 🚀 Major Upgrades

- **Dojo**: 1.6.0-alpha.2 → 1.7.2
- **Cairo**: 2.10.1 → 2.12.2
- **OpenZeppelin Contracts**: v1.0.0 → v2.0.0

### 💥 Breaking Changes

#### Model Renames (Dojo 1.7 26-character limit)

- `CharacterItemsStorageCounter` → `CharItemStorageCounter`
- `CharacterItemsInventoryCounter` → `CharItemInventoryCounter`

**Impact**: Client developers must update all references to these models in:
- Entity queries
- GraphQL queries
- TypeScript types
- Database schemas

#### Dojo Test API Updates

- All test files updated to use new `spawn_test_world(world::TEST_CLASS_HASH, ...)` API
- Test resource registration no longer requires `.try_into().unwrap()`

### ✨ New Features

#### Dojo 1.7 Improvements

- ✅ Procedural macros instead of compiler plugins (faster compilation)
- ✅ Better enum support with `DojoStore` trait
- ✅ Improved type safety with `Default` derives
- ✅ Fixed uninitialized storage issues

#### OpenZeppelin v2.0.0

- ✅ Immutable token decimals (standardized to 18)
- ✅ Updated component architecture
- ✅ Better upgradeable contract patterns

### 🔧 Technical Changes

#### Contract Updates

- Added `DojoStore` and `Default` derives to `WMClass` enum
- Added `DojoStore` to `Position` struct
- Updated ERC20 contracts to use `DefaultConfig` for `ImmutableConfig`
- Fixed import paths for OpenZeppelin v2.0.0 (`openzeppelin_upgrades::interface::IUpgradeable`)

#### Test Updates

Updated 17 test files with new Dojo 1.7 API:
- `test_spawn.cairo`
- `test_place_item.cairo`
- `test_undo_place_item.cairo`
- `test_delete_item.cairo`
- `test_fight.cairo`
- `test_rebirth.cairo`
- `test_buy_item.cairo`
- `test_sell_item.cairo`
- `test_reroll_shop.cairo`
- `test_place_item_and_fight.cairo`
- `test_crafting.cairo`
- `test_backpack_grid.cairo`
- `test_item_count.cairo`
- `test_dummy.cairo`
- `test_create_dummy.cairo`
- `test_update_dummy.cairo`
- `test_delete_dummy.cairo`

### 📦 Dependencies

#### Updated
```toml
[dependencies]
dojo = "=1.7.2"
starknet = "2.12.2"
openzeppelin_token = { tag = "v2.0.0" }
openzeppelin = { tag = "v2.0.0" }
openzeppelin_access = { tag = "v2.0.0" }
openzeppelin_upgrades = { tag = "v2.0.0" }
openzeppelin_introspection = { tag = "v2.0.0" }

[dev-dependencies]
cairo_test = "2.12.2"
dojo_cairo_test = "=1.7.2"
```

### ⚠️ Deprecation Warnings

The following deprecation warnings are present but don't affect functionality:
- `contract_address_const` is deprecated in Cairo 2.12.2 (will be fixed in future update)
- Recommendation: Use `TryInto::try_into` in const context instead

### 📝 Migration Guide

See [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) for detailed instructions on updating your client application.

### 🔍 Files Changed

**Configuration:**
- `Scarb.toml` - Updated dependencies and Cairo version

**Models:**
- `src/models/Character.cairo` - Added DojoStore/Default to WMClass
- `src/models/CharacterItem.cairo` - Renamed models, added DojoStore to Position

**Contracts:**
- `src/externals/erc20.cairo` - Updated for OpenZeppelin v2.0.0
- `src/externals/erc20_mintable.cairo` - Updated for OpenZeppelin v2.0.0

**Tests (17 files):**
- All test files updated to Dojo 1.7 API

**Total Lines Changed**: 173 references updated across 20 files

### ✅ Verification

- ✅ All contracts compile successfully with `sozo build`
- ✅ All tests pass with updated Dojo 1.7 API
- ✅ No compilation errors
- ✅ Only deprecation warnings (non-blocking)

### 🚢 Deployment

Ready for deployment to Sepolia testnet.

```bash
# Deploy to Sepolia
sozo --profile release migrate apply
```

---

**Full Changelog**: [`387546f...aa528c6`](https://github.com/0xKube/Warpack-Masters/compare/387546f...aa528c6)
