use starknet::ContractAddress;
use dojo::model::{Model, ModelPtr};
use warpack_masters::models::Character::{Character, CharacterName};
use warpack_masters::models::CharacterItem::{
    InventoryCounter, InventoryItem, StorageCounter, StorageItem,
};
use warpack_masters::models::Fight::BattleLogCounter;
use warpack_masters::models::Shop::Shop;
use warpack_masters::models::backpack::BackpackGrids;

pub fn character(player: ContractAddress) -> ModelPtr<Character> {
    Model::<Character>::ptr_from_keys(player)
}

pub fn character_name(name: felt252) -> ModelPtr<CharacterName> {
    Model::<CharacterName>::ptr_from_keys((name,))
}

pub fn inventory_counter(player: ContractAddress) -> ModelPtr<InventoryCounter> {
    Model::<InventoryCounter>::ptr_from_keys(player)
}

pub fn inventory_item(player: ContractAddress, id: u32) -> ModelPtr<InventoryItem> {
    Model::<InventoryItem>::ptr_from_keys((player, id))
}

pub fn storage_counter(player: ContractAddress) -> ModelPtr<StorageCounter> {
    Model::<StorageCounter>::ptr_from_keys(player)
}

pub fn storage_item(player: ContractAddress, id: u32) -> ModelPtr<StorageItem> {
    Model::<StorageItem>::ptr_from_keys((player, id))
}

pub fn backpack_grid(player: ContractAddress, x: u32, y: u32) -> ModelPtr<BackpackGrids> {
    Model::<BackpackGrids>::ptr_from_keys((player, x, y))
}

pub fn shop(player: ContractAddress) -> ModelPtr<Shop> {
    Model::<Shop>::ptr_from_keys(player)
}

pub fn battle_log_counter(player: ContractAddress) -> ModelPtr<BattleLogCounter> {
    Model::<BattleLogCounter>::ptr_from_keys(player)
}

