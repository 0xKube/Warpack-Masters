## Warpack Masters: Cairo 2.12 / Dojo 1.7 Upgrade Plan

### Summary

- Workspace targets Scarb/Cairo `2.12.2`, Dojo `v1.7.1`, and OpenZeppelin `v3.0.0-alpha.3`; lockfile regenerated.
- Model renames, Introspect derives, OZ imports, and address helpers are complete. Shared pointer helpers now live in `utils/storage_pointers.cairo`, and the `actions` system is midway through the migration off snapshot mutation; remaining systems/tests still need conversion to the Dojo pointer API before deployment.
- Additional audit highlighted **missing access-control primitives, economic validation, and data-migration safeguards** that must ship alongside the toolchain upgrade to make a Sepolia/Mainnet launch viable.
- Frontend alignment: we will publish renamed selectors (`storage_counter`, `inventory_counter`, etc.), expose any new read endpoints, and share them with the frontend team once merged so clients can update Torii queries immediately.
- Runtime address helpers (`utils/address.cairo`) replace every `contract_address_const` call; the workspace compiles past Dojo’s contract-address deprecation warnings.

---

### Compatibility Gaps

> **Frontend impact quick view**  
> These items primarily touch on contract compilation and storage layout. The only external-facing change the frontend must track is any renamed model/resource selectors (used in Torii queries or SDK calls). Every other change is internal to contracts and has no bearing on client code once redeployed.

- **Model metadata (simplified)**
  - Dojo 1.7 restricts model names to ≤26 characters (`CharStorageCount`, `CharInventoryCount` exceed this). Renaming is mandatory for compilation; Torii resource names will change accordingly, so the frontend must adjust any queries that reference these selectors.
  - Models containing custom types (`WMClass`, `Position`, plugin tuples) must derive `Introspect` (or `IntrospectPacked` when layout is fixed); nested structs and enums must do the same. This requirement comes from the updated Dojo storage engine.
  - **New world advantage:** a fresh deployment eliminates migration complexity—no legacy storage needs to be preserved.

- **World API**
  - Returned models are snapshots; mutating fields in-place (for example `storageCounter.count += 1`) now fails. Use `Model::<T>::ptr_from_keys` and `world.write_member` helpers or rebuild structs before calling `write_model`. This change is imposed by Dojo 1.7’s stricter borrowing rules; it does not alter external system signatures, so the frontend can keep calling the same entrypoints.
  - Ensure each system obtains the world once (`let mut world = self.world(@"Warpacks");`) to satisfy the new borrow rules.

- **Contract address helpers**
  - `starknet::contract_address_const::<...>()` is deprecated; replace with `TryInto::try_into` or dedicated helpers for zero or literal addresses. This is required because Cairo 2.12 removes compile-time address constants; runtime conversions are the only supported path.

- **OpenZeppelin interfaces**
  - ERC20 dispatcher traits live under `openzeppelin_interfaces::erc20::{...}`.
  - Components (ERC20, Upgradeable) expect explicit config traits (`DefaultConfig`), SRC5 plus Initializable integration, and the new `openzeppelin_interfaces::upgrades::IUpgradeable`. These updates are mandatory because the OpenZeppelin 3.0 packages removed the legacy module paths entirely. The public ERC20 ABI remains unchanged, so frontend token interactions are unaffected.

- **Access control & authorization**
  - Current systems expose critical mutations without authorization guards. Dojo 1.7 introduces `#[dojo::authorization]` macros that must be implemented to enforce role-based access, fee checks, and upgrade control. Without them, mainnet deployment is unsafe.
  - Contracts lack Starknet SRC5 interface support, preventing interface discovery and violating ecosystem standards.

- **Economic model enforcement**
  - Minting, equipping, and unequipping flows do not currently validate fees or transfer tokens. Cairo 2.12/OZ 3.0 make integration with ERC20 dispatchers straightforward; the upgrade should embed payment verification at the system level.
  - Gold is managed by an external ERC20 contract today; buying an item currently burns the entire amount. We need to adjust this to burn 85% of the payment and redirect a 15% fee to the treasury address.

- **Operational safety**
  - No emergency pause or admin override exists. Upgrades should introduce owner/administrator roles capable of pausing systems and authorizing migrations to mitigate runtime incidents.

---

### Step-by-Step Implementation *(updated Oct 23 2025)*

1. **Model Updates** *(✅ complete)*
   - Renamed overlength models to Dojo-compliant identifiers (`CharStorageCount` → `StorageCounter`, `CharInventoryCount` → `InventoryCounter`, `Characters` → `Character`, etc.) and exported compatibility type aliases so dependent code can migrate incrementally.  
     *Why required:* Dojo rejects models whose names exceed 26 characters; aliases avoid breaking existing integrations while new names propagate.  
     *Frontend note:* Update Torii/SDK selectors or GraphQL queries to use the new resource names.
   - Added `#[derive(Introspect, starknet::Store)]` to every struct or enum stored in models.  
     *Why required:* The new Dojo storage metadata pipeline depends on `Introspect`; without it, registration fails. No frontend action needed.
   - Updated systems and a majority of tests to reference the new model names; remaining fixtures are being converted alongside the pointer API refactor.
   - **New world benefit:** No legacy data to migrate—deploy the corrected schemas into the fresh world and populate via onboarding flows.

2. **Dojo World API Adjustments** *(🚧 priority focus)*
   - Import `dojo::model::{Model, ModelStorage}` and `dojo::world::{WorldStorage, WorldStorageTrait}` wherever storage is touched.
- Transition every system/test from snapshot mutation (`world.read_model` → mutate → `world.write_model`) to pointer-driven access. Pointer helpers (`utils/storage_pointers.cairo`) encapsulate the common `ptr_from_keys` calls; continue wiring systems to:
    - obtain pointers via the helpers (or `Model::<T>::ptr_from_keys(keys)` when ad‑hoc keys are needed)
    - read individual members with `world.read_member(ptr, selector!("field"))`
    - write individual members with `world.write_member(ptr, selector!("field"), value)`
    - rebuild structs only when several fields change in tandem.
- Example (confirmed via Dojo docs/examples):
    ```cairo
    let vec: Vec2 = world.read_member(ptrs::position(player), selector!("vec"));

    world.write_member(ptrs::position(player), selector!("vec"), Vec2 { x: 10, y: 20 });
    ```
  - Current status: `utils/storage_pointers.cairo` contains shared pointer helpers and `systems/actions.cairo` is partially converted (spawn/rebirth/storage flows). Remaining `actions` routines plus `fight`, `storage_bridge`, `item`, and associated tests still depend on snapshot mutation.
   - Exit criteria: zero borrow-rule violations in `scarb build` and Dojo tests with Dojo 1.7.

3. **OpenZeppelin Integration** *(✅ complete)*
   - Update dispatcher imports to use the `openzeppelin_interfaces` modules.  
     *Why required:* Old paths were removed in OZ 3.0; keeping them results in missing identifier errors.
   - In external ERC20 contracts, add the required components (`SRC5Component`, `InitializableComponent`, `DefaultConfig`) and adopt the new upgrade interface.  
     *Why required:* OZ 3.0 components enforce SRC5 + initialization to support Starknet interface discovery. Public ERC20 ABI remains unchanged.
   - Review hook trait signatures and constructor patterns versus OpenZeppelin `v3.0.0-alpha.3`.
   - **Developer instructions:**
    - Add `openzeppelin_interfaces = { git = "https://github.com/openzeppelin/cairo-contracts", tag = "v3.0.0-alpha.3" }` to `Scarb.toml` so the dispatcher module resolves during `scarb build`.
    - Replace every `use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait}` (and similar legacy paths) with `use openzeppelin_interfaces::erc20::{IERC20Dispatcher, IERC20DispatcherTrait}` in systems (`actions.cairo`, `shop.cairo`, `storage_bridge.cairo`) and tests (`test_rebirth.cairo`, `test_storage_bridge.cairo`, etc.). OpenZeppelin re-exports the ERC20 dispatchers at the root `erc20` module in `packages/interfaces/src/lib.cairo`; omitting the `token::` segment avoids unresolved-import build failures.
    - Update other legacy interface imports (for example `openzeppelin_upgrades::interface::IUpgradeable`) to the matching modules under `openzeppelin_interfaces::` (`openzeppelin_interfaces::upgrades::IUpgradeable`, etc.) before modifying business logic.
    - Ensure each external ERC20 contract imports `DefaultConfig`, `ERC20Component`, and `ERC20HooksEmptyImpl` from `openzeppelin_token::erc20`, wires the `ImmutableConfig` implementation expected by v3, and exposes SRC5 + Initializable mixins.
    - After refactoring imports, run `scarb build` to confirm the dispatcher signatures resolve cleanly before adding treasury/fee logic.

4. **Access Control & Authorization**
   - Implement Starknet SRC5 compliance for all deployed contracts (world-facing systems and external ERC20s).  
     *Why required:* SRC5 is the Starknet-standard interface registry; without it, downstream tooling cannot query supported interfaces.
   - Add `#[dojo::authorization]` guards that validate fees, ownership, and roles before executing world mutations.  
     *Why required:* Prevents unauthorized minting/equipping and is essential for mainnet security.
   - Introduce a single admin address (configurable constant) responsible for upgrade approvals, emergency pauses, and treasury management. Document how to rotate this address if governance moves to a multisig later.

5. **Economic Safeguards** *(🚧 helpers landed; validation pending)*
   - Integrated ERC20 fee collection into core systems via OZ v3 dispatchers and added a reusable `FeeBreakdown` helper set (`_compute_fee_split`, `_collect_gold_fee`, `_distribute_gold_fee`, `_treasury_address`).  
     *Why required:* Enforces the economic model on-chain and protects treasury revenue.
   - Persist the treasury destination explicitly (for example extend `GameConfig` with `treasury_address: ContractAddress` or introduce a dedicated `TreasuryConfig` component) and gate setters behind admin-only authorization.
- Adjust the item-buy flow so that the external gold token burns 85% of the payment and routes the remaining 15% to the treasury address. Compute the split on the raw `u256` price before applying the 18-decimal multiplier, use floor division for the treasury share, and burn the remainder; document this rounding rule in tests so the economics stay predictable. (Helper scaffolding exists in `actions.cairo`; finalize once pointer migration is stable.)
   - Centralize fee configuration and treasury addresses so they can be governed securely, and cover the 85/15 split plus treasury setter in regression tests.

6. **Counter Logic Rewrite** *(🚧 blocked by pointer helpers)*
   - After pointer utilities exist, rework counter loops to iterate using pointer reads and to update counts via `write_member` instead of snapshot mutation.
   - Update shared utilities (`utils/test_utils`) to centralize safe increment/decrement helpers.

7. **Tests & Fixtures** *(🚧 pending pointer migration)*
   - Wrap pointer access in reusable helpers for tests to keep assertions concise while honoring Dojo borrow rules.
   - Mirror system-level pointer changes across fixtures to prevent panics during Dojo tests.
   - Continue building regression coverage (authorization, fee splits) once pointer refactor stabilizes.

8. **Address Constants & Helpers** *(Completed)*
   - Introduced centralized helpers in `utils/address.cairo` and replaced all `contract_address_const` usages with runtime conversions.  
     *Why required:* Cairo removed const-time address evaluation; runtime conversion is the only supported pattern.

9. **Documentation & Follow-up**
   - Document the new patterns (model naming, world access, ERC20 composition, authorization, migration steps) in project docs/readme.
   - Add regression tests around ERC20 interactions and model counters to guard against future regressions.
   - Produce runbooks for migration execution, emergency pause, and upgrade procedures.

---

### Next Actions *(Dojo 1.7 focus)*

- Stand up shared pointer utilities (`storage_pointers.cairo`) to centralize `Model::<T>::ptr_from_keys` + `write_member` patterns.
- Migrate the highest-traffic systems first (`actions`, `item`, `shop`, `storage_bridge`), then cascade to the remaining modules and utilities.
- Update tests and helper functions to consume pointer-based reads/writes; retire direct snapshot mutation.
- Once pointer migration passes `scarb build`, resume SRC5/authorization and economics tasks, followed by end-to-end test coverage.
- Schedule frontend alignment before deployment to confirm selector changes and world schema stability.

