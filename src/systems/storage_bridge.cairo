#[starknet::interface]
pub trait IStorageBridge<TContractState> {
    fn deposit_item(ref self: TContractState, storage_item_id: u32);
    fn withdraw_item(ref self: TContractState, item_id: u32);
}

#[starknet::interface]
trait ILegacyERC20<TState> {
    fn transfer(ref self: TState, recipient: starknet::ContractAddress, amount: u256) -> bool;
    fn transferFrom(
        ref self: TState,
        sender: starknet::ContractAddress,
        recipient: starknet::ContractAddress,
        amount: u256,
    ) -> bool;
}

#[dojo::contract]
pub mod storage_bridge {
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorageTrait;
    use openzeppelin_interfaces::erc20::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use warpack_masters::models::CharacterItem::{StorageCounter, StorageItem};
    use warpack_masters::models::Item::Item;
    use warpack_masters::models::TokenRegistry::TokenRegistry;
    use warpack_masters::utils::storage_pointers as ptrs;
    use super::IStorageBridge;
    use super::{ILegacyERC20Dispatcher, ILegacyERC20DispatcherTrait};

    #[derive(Copy, Drop, Serde)]
    #[dojo::event(historical: true)]
    struct DepositItem {
        #[key]
        player: ContractAddress,
        itemId: u32,
        tokenAmount: u256,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event(historical: true)]
    struct WithdrawItem {
        #[key]
        player: ContractAddress,
        itemId: u32,
        tokenAmount: u256,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event(historical: true)]
    struct StorageSlotUpdated {
        #[key]
        player: ContractAddress,
        #[key]
        slot: u32,
        itemId: u32,
    }

    #[abi(embed_v0)]
    impl StorageBridgeImpl of IStorageBridge<ContractState> {
        // Convert storage item to token
        fn deposit_item(ref self: ContractState, storage_item_id: u32) {
            let mut world = self.world(@"Warpacks");
            let caller = get_caller_address();

            // Verify the storage item exists and belongs to the player
            let storage_item_ptr = ptrs::storage_item(caller, storage_item_id);
            let item_id: u32 = world.read_member(storage_item_ptr, selector!("itemId"));
            assert(item_id != 0, 'Storage item does not exist');

            // Get item details to verify it exists
            let item: Item = world.read_model(item_id);
            assert(item.itemType != 0, 'Item does not exist');

            // Remove the item from player's storage
            self._remove_items_from_storage(caller, storage_item_id);

            // Get the token address for this item
            let registry: TokenRegistry = world.read_model(item_id);
            assert(
                registry.token_address != warpack_masters::utils::address::zero_address(),
                'Token not registered',
            );
            assert(registry.is_active, 'Token not active');

            // Transfer tokens to the player
            let token_amount = 1 * 1_000_000_000_000_000_000;

            if registry.is_legacy {
                let token_contract = ILegacyERC20Dispatcher {
                    contract_address: registry.token_address,
                };
                token_contract.transfer(caller, token_amount);
            } else {
                let token_contract = IERC20Dispatcher { contract_address: registry.token_address };
                token_contract.transfer(caller, token_amount);
            }

            world
                .emit_event(
                    @DepositItem { player: caller, itemId: item_id, tokenAmount: token_amount },
                );
        }

        // Convert token to storage item
        fn withdraw_item(ref self: ContractState, item_id: u32) {
            let mut world = self.world(@"Warpacks");
            let caller = get_caller_address();

            // Verify item exists
            let item: Item = world.read_model(item_id);
            assert(item.itemType != 0, 'Item does not exist');

            // Get the token address for this item
            let registry: TokenRegistry = world.read_model(item_id);
            assert(
                registry.token_address != warpack_masters::utils::address::zero_address(),
                'Token not registered',
            );
            assert(registry.is_active, 'Token not active');

            let token_amount = 1 * 1_000_000_000_000_000_000;

            if registry.is_legacy {
                let token_contract = ILegacyERC20Dispatcher {
                    contract_address: registry.token_address,
                };
                token_contract.transferFrom(caller, get_contract_address(), token_amount);
            } else {
                let token_contract = IERC20Dispatcher { contract_address: registry.token_address };
                token_contract.transfer_from(caller, get_contract_address(), token_amount);
            }

            // Add items to player's storage
            self._add_items_to_storage(caller, item_id);

            world
                .emit_event(
                    @WithdrawItem { player: caller, itemId: item_id, tokenAmount: token_amount },
                );
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _remove_items_from_storage(
            ref self: ContractState, player: ContractAddress, storage_item_id: u32,
        ) {
            let mut world = self.world(@"Warpacks");

            let storage_item_ptr = ptrs::storage_item(player, storage_item_id);
            let existing_id: u32 = world.read_member(storage_item_ptr, selector!("itemId"));
            assert(existing_id != 0, 'Storage item does not exist');
            world.write_member(storage_item_ptr, selector!("itemId"), 0);
            world
                .emit_event(
                    @StorageSlotUpdated { player, slot: storage_item_id, itemId: 0 },
                );
        }

        fn _add_items_to_storage(ref self: ContractState, player: ContractAddress, item_id: u32) {
            let mut world = self.world(@"Warpacks");

            let storage_counter_ptr = ptrs::storage_counter(player);
            let current_count: u32 = world.read_member(storage_counter_ptr, selector!("count"));
            let mut slot = current_count;

            loop {
                if slot == 0 {
                    break;
                }

                let storage_item_ptr = ptrs::storage_item(player, slot);
                let existing_id: u32 = world.read_member(storage_item_ptr, selector!("itemId"));
                if existing_id == 0 {
                    world.write_member(storage_item_ptr, selector!("itemId"), item_id);
                    world.emit_event(@StorageSlotUpdated { player, slot, itemId: item_id });
                    return;
                }

                slot -= 1;
            }

            let new_count = current_count + 1;
            world.write_member(storage_counter_ptr, selector!("count"), new_count);

            world.write_model(@StorageItem { player, id: new_count, itemId: item_id });
            world.emit_event(@StorageSlotUpdated { player, slot: new_count, itemId: item_id });
        }
    }
}
