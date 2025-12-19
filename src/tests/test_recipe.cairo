#[cfg(test)]
mod tests {
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorageTrait;
    use dojo_cairo_test::{
        ContractDef, ContractDefTrait, NamespaceDef, TestResource, WorldStorageTestTrait,
        spawn_test_world,
    };
    use starknet::testing::set_contract_address;
    use warpack_masters::models::CharacterItem::{
        StorageCounter, CharacterItemStorage, m_StorageCounter, m_StorageItem,
    };
    use warpack_masters::models::Item::{m_Item, m_ItemsCounter};
    use warpack_masters::models::Recipe::{RecipeV2, m_Recipe, m_RecipesCounter};
    use warpack_masters::systems::actions::{IActionsDispatcher, IActionsDispatcherTrait, actions};
    use warpack_masters::systems::item::{IItemDispatcher, item_system};
    use warpack_masters::systems::recipe::{
        IRecipeDispatcher, IRecipeDispatcherTrait, recipe_system,
    };
    use warpack_masters::utils::test_utils::add_items;

    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "Warpacks",
            resources: [
                TestResource::Model(m_Item::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_ItemsCounter::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_StorageItem::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_StorageCounter::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_Recipe::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_RecipesCounter::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Contract(item_system::TEST_CLASS_HASH),
                TestResource::Contract(recipe_system::TEST_CLASS_HASH),
                TestResource::Contract(actions::TEST_CLASS_HASH),
                TestResource::Event(actions::e_StorageSlotUpdated::TEST_CLASS_HASH),
            ]
                .span(),
        };
        ndef
    }

    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"Warpacks", @"item_system")
                .with_writer_of([dojo::utils::bytearray_hash(@"Warpacks")].span()),
            ContractDefTrait::new(@"Warpacks", @"recipe_system")
                .with_writer_of([dojo::utils::bytearray_hash(@"Warpacks")].span()),
            ContractDefTrait::new(@"Warpacks", @"actions")
                .with_writer_of([dojo::utils::bytearray_hash(@"Warpacks")].span()),
        ]
            .span()
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_add_recipe() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"recipe_system").unwrap();
        let mut recipe_system = IRecipeDispatcher { contract_address };

        add_items(ref item_system);

        recipe_system.add_recipe(array![1, 2], array![1, 1], 3);

        let recipe: RecipeV2 = world.read_model(1);
        assert(recipe.id == 1, 'wrong recipe id');
        assert(*recipe.item_ids[0] == 1, 'wrong item_id at index 0');
        assert(*recipe.item_ids[1] == 2, 'wrong item_id at index 1');
        assert(*recipe.item_amounts[0] == 1, 'wrong item_amount at index 0');
        assert(*recipe.item_amounts[1] == 1, 'wrong item_amount at index 1');
        assert(recipe.result_item_id == 3, 'wrong result_item_id');
        assert(recipe.enabled == true, 'recipe should be enabled');
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_add_recipe_with_same_item_id() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"recipe_system").unwrap();
        let mut recipe_system = IRecipeDispatcher { contract_address };

        add_items(ref item_system);

        recipe_system.add_recipe(array![1], array![2], 2);

        let recipe: RecipeV2 = world.read_model(1);
        assert(recipe.id == 1, 'wrong recipe id');
        assert(*recipe.item_ids[0] == 1, 'wrong item_id at index 0');
        assert(*recipe.item_amounts[0] == 2, 'wrong item_amount at index 0');
        assert(recipe.result_item_id == 2, 'wrong result_item_id');
        assert(recipe.enabled == true, 'recipe should be enabled');
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('player not world owner', 'ENTRYPOINT_FAILED'))]
    fn test_add_recipe_without_permission() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"recipe_system").unwrap();
        let mut recipe_system = IRecipeDispatcher { contract_address };

        add_items(ref item_system);

        let alice = warpack_masters::utils::address::address_from(0x1);
        set_contract_address(alice);
        recipe_system.add_recipe(array![1, 2], array![1, 1], 3);
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('item is not enabled', 'ENTRYPOINT_FAILED'))]
    fn test_add_recipe_item1_doesnt_exists() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"recipe_system").unwrap();
        let mut recipe_system = IRecipeDispatcher { contract_address };

        add_items(ref item_system);

        recipe_system.add_recipe(array![100, 2], array![1, 1], 3);
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('item is not enabled', 'ENTRYPOINT_FAILED'))]
    fn test_add_recipe_item2_doesnt_exists() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"recipe_system").unwrap();
        let mut recipe_system = IRecipeDispatcher { contract_address };

        add_items(ref item_system);

        recipe_system.add_recipe(array![1, 200], array![1, 1], 3);
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('result item is not enabled', 'ENTRYPOINT_FAILED'))]
    fn test_add_recipe_result_doesnt_exists() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"recipe_system").unwrap();
        let mut recipe_system = IRecipeDispatcher { contract_address };

        add_items(ref item_system);

        recipe_system.add_recipe(array![1, 2], array![1, 1], 300);
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_craft_item() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"recipe_system").unwrap();
        let mut recipe_system = IRecipeDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"actions").unwrap();
        let mut actions = IActionsDispatcher { contract_address };

        add_items(ref item_system);

        recipe_system.add_recipe(array![1, 2], array![1, 1], 3);

        let alice = warpack_masters::utils::address::address_from(0x1);
        world.write_model(@CharacterItemStorage { player: alice, id: 1, itemId: 1 });
        world.write_model(@CharacterItemStorage { player: alice, id: 2, itemId: 2 });
        world.write_model(@StorageCounter { player: alice, count: 2 });

        set_contract_address(alice);
        actions.craft_item(1, array![1, 2]);

        let item_at_1: CharacterItemStorage = world.read_model((alice, 1));
        assert(item_at_1.itemId == 0, 'item 1 should be consumed');
        let item_at_2: CharacterItemStorage = world.read_model((alice, 2));
        assert(item_at_2.itemId == 3, 'wrong crafted itemId');
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('recipe is not enabled', 'ENTRYPOINT_FAILED'))]
    fn test_craft_item_with_disabled_recipe() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"actions").unwrap();
        let mut actions = IActionsDispatcher { contract_address };

        let alice = warpack_masters::utils::address::address_from(0x1);
        set_contract_address(alice);
        actions.craft_item(999, array![1, 2]);
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('item not enough', 'ENTRYPOINT_FAILED'))]
    fn test_craft_item_insufficient_items() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"recipe_system").unwrap();
        let mut recipe_system = IRecipeDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"actions").unwrap();
        let mut actions = IActionsDispatcher { contract_address };

        add_items(ref item_system);

        recipe_system.add_recipe(array![1, 2], array![2, 1], 3); // Requires 2 of item 1

        let alice = warpack_masters::utils::address::address_from(0x1);
        world
            .write_model(
                @CharacterItemStorage { player: alice, id: 1, itemId: 1 },
            ); // Only 1 of item 1
        world.write_model(@CharacterItemStorage { player: alice, id: 2, itemId: 2 });
        world.write_model(@StorageCounter { player: alice, count: 2 });

        set_contract_address(alice);
        actions.craft_item(1, array![1, 2]);
    }
}
