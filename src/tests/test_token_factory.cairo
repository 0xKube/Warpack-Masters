#[cfg(test)]
mod tests {
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorageTrait;
    use dojo_cairo_test::{
        ContractDef, ContractDefTrait, NamespaceDef, TestResource, WorldStorageTestTrait,
        spawn_test_world,
    };
    use starknet::testing::set_contract_address;
    use warpack_masters::externals::erc20::ERC20Token;
    use warpack_masters::items;
    use warpack_masters::models::Item::{m_Item, m_ItemsCounter};
    use warpack_masters::models::TokenRegistry::{TokenRegistry, m_TokenRegistry};
    use warpack_masters::systems::item::{IItemDispatcher, item_system};
    use warpack_masters::systems::token_factory::{
        ITokenFactoryDispatcher, ITokenFactoryDispatcherTrait, token_factory,
    };
    use warpack_masters::utils::test_utils::add_items;

    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "Warpacks",
            resources: [
                TestResource::Model(m_Item::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_ItemsCounter::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_TokenRegistry::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Contract(token_factory::TEST_CLASS_HASH),
                TestResource::Contract(item_system::TEST_CLASS_HASH),
            ]
                .span(),
        };

        ndef
    }

    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"Warpacks", @"token_factory")
                .with_writer_of([dojo::utils::bytearray_hash(@"Warpacks")].span()),
            ContractDefTrait::new(@"Warpacks", @"item_system")
                .with_writer_of([dojo::utils::bytearray_hash(@"Warpacks")].span()),
        ]
            .span()
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_create_token_for_item() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let (item_contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address: item_contract_address };

        // Add items to the world
        add_items(ref item_system);

        let owner = warpack_masters::utils::address::address_from('alice');
        let item_id = 6; // Dagger item from the items module

        // Create token for item
        let token_address = token_factory
            .create_token_for_item(
                item_id,
                items::Dagger::name(),
                "DAG",
                owner,
                ERC20Token::TEST_CLASS_HASH.try_into().unwrap(),
            );

        // Verify token registry was created
        let registry: TokenRegistry = world.read_model(item_id);
        assert(registry.item_id == item_id, 'Wrong item ID');
        assert(registry.name == items::Dagger::name(), 'Wrong token name');
        assert(registry.symbol == "DAG", 'Wrong token symbol');
        assert(registry.token_address == token_address, 'Wrong token address');
        assert(registry.is_active == true, 'Token should be active');

        // Verify token address is not zero
        assert(
            token_address != warpack_masters::utils::address::zero_address(),
            'Address should not be zero',
        );
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_batch_create_tokens_for_items() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (item_contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address: item_contract_address };

        // Add items to the world
        add_items(ref item_system);

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let owner = warpack_masters::utils::address::address_from('alice');
        token_factory
            .batch_create_tokens_for_items(owner, ERC20Token::TEST_CLASS_HASH.try_into().unwrap());
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_get_token_address() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let (item_contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address: item_contract_address };

        // Add items to the world
        add_items(ref item_system);

        let owner = warpack_masters::utils::address::address_from(0x123);
        let item_id = 9; // Shield item

        // Create token first
        let created_token_address = token_factory
            .create_token_for_item(
                item_id,
                items::Shield::name(),
                "SHD",
                owner,
                ERC20Token::TEST_CLASS_HASH.try_into().unwrap(),
            );

        // Get token address
        let retrieved_token_address = token_factory.get_token_address(item_id);

        // Verify addresses match
        assert(created_token_address == retrieved_token_address, 'Token addresses should match');
        assert(
            retrieved_token_address != warpack_masters::utils::address::zero_address(),
            'Should return valid address',
        );
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_get_token_address_nonexistent() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let item_id = 999; // Non-existent item

        // Get token address for non-existent token
        let token_address = token_factory.get_token_address(item_id);

        // Should return zero address for non-existent token
        assert(
            token_address == warpack_masters::utils::address::zero_address(),
            'Should return zero address',
        );
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('caller not world owner', 'ENTRYPOINT_FAILED'))]
    fn test_create_token_not_world_owner() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let (item_contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address: item_contract_address };

        // Add items to the world
        add_items(ref item_system);

        // Set caller to non-owner address
        let non_owner = warpack_masters::utils::address::address_from(0x999);
        set_contract_address(non_owner);

        let owner = warpack_masters::utils::address::address_from(0x123);
        let item_id = 6;

        // This should fail because caller is not world owner
        token_factory
            .create_token_for_item(
                item_id,
                items::Dagger::name(),
                "DAG",
                owner,
                ERC20Token::TEST_CLASS_HASH.try_into().unwrap(),
            );
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('Item name does not match', 'ENTRYPOINT_FAILED'))]
    fn test_create_token_wrong_item_name() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let (item_contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address: item_contract_address };

        // Add items to the world
        add_items(ref item_system);

        let owner = warpack_masters::utils::address::address_from(0x123);
        let item_id = 6; // Dagger item

        // Try to create token with wrong name
        token_factory
            .create_token_for_item(
                item_id, "WrongName", "DAG", owner, ERC20Token::TEST_CLASS_HASH.try_into().unwrap(),
            );
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('Token already exists', 'ENTRYPOINT_FAILED'))]
    fn test_create_token_already_exists() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let (item_contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address: item_contract_address };

        // Add items to the world
        add_items(ref item_system);

        let owner = warpack_masters::utils::address::address_from(0x123);
        let item_id = 6;

        // Create token first time
        token_factory
            .create_token_for_item(
                item_id,
                items::Dagger::name(),
                "DAG",
                owner,
                ERC20Token::TEST_CLASS_HASH.try_into().unwrap(),
            );

        // Try to create token again - should fail
        token_factory
            .create_token_for_item(
                item_id,
                items::Dagger::name(),
                "DAG2",
                owner,
                ERC20Token::TEST_CLASS_HASH.try_into().unwrap(),
            );
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_create_multiple_tokens() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let (item_contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address: item_contract_address };

        // Add items to the world
        add_items(ref item_system);

        let owner = warpack_masters::utils::address::address_from(0x123);

        // Create token for Dagger
        let dagger_token = token_factory
            .create_token_for_item(
                6,
                items::Dagger::name(),
                "DAG",
                owner,
                ERC20Token::TEST_CLASS_HASH.try_into().unwrap(),
            );

        // Create token for Shield
        let shield_token = token_factory
            .create_token_for_item(
                9,
                items::Shield::name(),
                "SHD",
                owner,
                ERC20Token::TEST_CLASS_HASH.try_into().unwrap(),
            );

        // Verify both tokens exist and are different
        assert(dagger_token != shield_token, 'Tokens should be different');
        assert(
            dagger_token != warpack_masters::utils::address::zero_address(),
            'Dagger token should exist',
        );
        assert(
            shield_token != warpack_masters::utils::address::zero_address(),
            'Shield token should exist',
        );

        // Verify registry entries
        let dagger_registry: TokenRegistry = world.read_model(6);
        let shield_registry: TokenRegistry = world.read_model(9);

        assert(dagger_registry.token_address == dagger_token, 'Dagger registry mismatch');
        assert(shield_registry.token_address == shield_token, 'Shield registry mismatch');
        assert(dagger_registry.symbol == "DAG", 'Dagger symbol mismatch');
        assert(shield_registry.symbol == "SHD", 'Shield symbol mismatch');
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_token_registry_fields() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let (item_contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address: item_contract_address };

        // Add items to the world
        add_items(ref item_system);

        let owner = warpack_masters::utils::address::address_from(0x123);
        let item_id = 11; // HealingPotion

        let token_address = token_factory
            .create_token_for_item(
                item_id,
                items::HealingPotion::name(),
                "HEAL",
                owner,
                ERC20Token::TEST_CLASS_HASH.try_into().unwrap(),
            );

        // Verify all registry fields
        let registry: TokenRegistry = world.read_model(item_id);
        assert(registry.item_id == item_id, 'Item ID mismatch');
        assert(registry.name == items::HealingPotion::name(), 'Name mismatch');
        assert(registry.symbol == "HEAL", 'Symbol mismatch');
        assert(registry.token_address == token_address, 'Token address mismatch');
        assert(registry.is_active == true, 'Should be active');
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_register_token_for_item() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (item_contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address: item_contract_address };
        add_items(ref item_system);

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let token_address = warpack_masters::utils::address::address_from('dai');
        token_factory.register_token_for_item(6, items::Dagger::name(), "DAG", token_address);

        let registry: TokenRegistry = world.read_model(6);
        assert(registry.item_id == 6, 'Item ID mismatch');
        assert(registry.name == items::Dagger::name(), 'Name mismatch');
        assert(registry.symbol == "DAG", 'Symbol mismatch');
        assert(registry.token_address == token_address, 'Token address mismatch');
        assert(registry.is_active == true, 'Should be active');
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('caller not world owner', 'ENTRYPOINT_FAILED'))]
    fn test_register_token_not_world_owner() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (item_contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address: item_contract_address };
        add_items(ref item_system);

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let non_owner = warpack_masters::utils::address::address_from(0x999);
        set_contract_address(non_owner);

        let token_address = warpack_masters::utils::address::address_from('dai');
        token_factory.register_token_for_item(6, items::Dagger::name(), "DAG", token_address);
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('Token already exists', 'ENTRYPOINT_FAILED'))]
    fn test_register_token_already_exists() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (item_contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address: item_contract_address };
        add_items(ref item_system);

        let (contract_address, _) = world.dns(@"token_factory").unwrap();
        let token_factory = ITokenFactoryDispatcher { contract_address };

        let token_address = warpack_masters::utils::address::address_from('dai');
        token_factory.register_token_for_item(6, items::Dagger::name(), "DAG", token_address);

        let another_address = warpack_masters::utils::address::address_from('bob');
        token_factory.register_token_for_item(6, items::Dagger::name(), "DAG", another_address);
    }
}
