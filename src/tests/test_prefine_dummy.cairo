#[cfg(test)]
mod tests {
    use core::array::ArrayTrait;
    use core::option::OptionTrait;
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorageTrait;
    use dojo_cairo_test::{
        ContractDef, ContractDefTrait, NamespaceDef, TestResource, WorldStorageTestTrait,
        spawn_test_world,
    };
    use starknet::testing::set_contract_address;
    use warpack_masters::models::Character::{WMClass, m_NameRecord};
    use warpack_masters::models::DummyCharacter::{
        DummyCharacter, DummyCharacterCounter, m_DummyCharacter, m_DummyCharacterCounter,
    };
    use warpack_masters::models::DummyCharacterItem::{
        DummyCharacterItem, DummyCharacterItemsCounter, m_DummyCharacterItem,
        m_DummyCharacterItemsCounter,
    };
    use warpack_masters::models::Item::{m_Item, m_ItemsCounter};
    use warpack_masters::models::backpack::m_BackpackGrids;
    use warpack_masters::prdefined_dummies::Dummy0;
    use warpack_masters::systems::dummy::{IDummyDispatcher, IDummyDispatcherTrait, dummy_system};
    use warpack_masters::systems::item::{IItemDispatcher, item_system};
    use warpack_masters::utils::test_utils::add_items;

    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "Warpacks",
            resources: [
                TestResource::Model(m_BackpackGrids::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_Item::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_ItemsCounter::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_DummyCharacter::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_DummyCharacterCounter::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_DummyCharacterItem::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(
                    m_DummyCharacterItemsCounter::TEST_CLASS_HASH.try_into().unwrap(),
                ),
                TestResource::Model(m_NameRecord::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Contract(item_system::TEST_CLASS_HASH),
                TestResource::Contract(dummy_system::TEST_CLASS_HASH),
            ]
                .span(),
        };
        ndef
    }

    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"Warpacks", @"item_system")
                .with_writer_of([dojo::utils::bytearray_hash(@"Warpacks")].span()),
            ContractDefTrait::new(@"Warpacks", @"dummy_system")
                .with_writer_of([dojo::utils::bytearray_hash(@"Warpacks")].span()),
        ]
            .span()
    }

    #[test]
    #[available_gas(3000000000000000)]
    #[should_panic(expected: ('player not world owner', 'ENTRYPOINT_FAILED'))]
    fn test_prefine_dummy_non_admin() {
        let alice = warpack_masters::utils::address::address_from(0x1);

        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"dummy_system").unwrap();
        let mut dummy_system = IDummyDispatcher { contract_address };

        add_items(ref item_system);

        set_contract_address(alice);

        dummy_system.prefine_dummy(0, 'Alice', WMClass::Warrior, Dummy0::get_items());
    }

    #[test]
    #[available_gas(3000000000000000)]
    fn test_prefine_dummy() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"item_system").unwrap();
        let mut item_system = IItemDispatcher { contract_address };

        let (contract_address, _) = world.dns(@"dummy_system").unwrap();
        let mut dummy_system = IDummyDispatcher { contract_address };

        add_items(ref item_system);

        let mut level = 0;
        dummy_system.prefine_dummy(level, Dummy0::name, WMClass::Warrior, Dummy0::get_items());

        let dummyCharCounter: DummyCharacterCounter = world.read_model(level);
        assert(dummyCharCounter.count == 1, 'Should be equal 1');

        let dummyChar: DummyCharacter = world.read_model((level, 1));
        assert(dummyChar.level == level, 'Should be equal 0');
        assert(dummyChar.id == 1, 'Should be equal 1');
        assert(dummyChar.name == Dummy0::name, 'Should be equal Dummy0::name');
        assert(dummyChar.wmClass == WMClass::Warrior, 'Should be equal Warrior');
        assert(dummyChar.health == Dummy0::health, 'Should be equal Dummy0::health');
        assert(
            dummyChar.player == warpack_masters::utils::address::address_from(0x1),
            'Should be equal 0x0',
        );
        assert(dummyChar.rating == 0, 'Should be equal 0');

        let dummyCharItemsCounter: DummyCharacterItemsCounter = world
            .read_model((level, dummyChar.id));
        let mut items = Dummy0::get_items();
        assert(dummyCharItemsCounter.count == items.len(), 'Should be equal items length');

        let mut i = 1;
        loop {
            if items.len() == 0 {
                break;
            }
            let item = items.pop_front().unwrap();
            let dummyCharItem: DummyCharacterItem = world.read_model((level, dummyChar.id, i));

            assert(dummyCharItem.itemId == item.itemId, 'Should be equal item.itemId');
            assert(dummyCharItem.position.x == item.position.x, 'Should be equal item.position.x');
            assert(dummyCharItem.position.y == item.position.y, 'Should be equal item.position.y');
            assert(dummyCharItem.rotation == item.rotation, 'Should be equal item.rotation');
            i += 1;
        }
    }
}

