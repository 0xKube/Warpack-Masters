use starknet::ContractAddress;

#[derive(Drop, Serde, Introspect, DojoStore)]
#[dojo::model]
pub struct Character {
    #[key]
    pub player: ContractAddress,
    // must be less than 31 ASCII characters
    pub name: felt252,
    pub wmClass: WMClass,
    pub gold: u32,
    pub health: u32,
    pub wins: u32,
    pub loss: u32,
    pub rating: u32,
    pub totalWins: u32,
    pub totalLoss: u32,
    pub winStreak: u32,
    pub stamina: u8,
    pub birthCount: u32,
    pub updatedAt: u64,
}

#[derive(Serde, Copy, Drop, Introspect, DojoStore, Default, PartialEq)]
pub enum WMClass {
    #[default]
    Warrior,
    Warlock,
    Archer,
}

#[derive(Drop, Serde, Introspect, DojoStore)]
#[dojo::model]
pub struct CharacterName {
    #[key]
    pub name: felt252,
    pub player: ContractAddress,
}

pub type Characters = Character;
pub type NameRecord = CharacterName;

pub use m_Character as m_Characters;
pub use m_CharacterName as m_NameRecord;

pub const PLAYER: felt252 = 'player';
pub const DUMMY: felt252 = 'dummy';
