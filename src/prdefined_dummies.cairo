use core::fmt::{Display, Error, Formatter};
use warpack_masters::models::CharacterItem::Position;


#[derive(Copy, Drop, Serde)]
pub struct PredefinedItem {
    pub itemId: u32,
    pub position: Position,
    // rotation: 0, 90, 180, 270
    pub rotation: u32,
    pub plugins: Span<(u8, u32, u32)>,
}

impl PointDisplay of Display<PredefinedItem> {
    fn fmt(self: @PredefinedItem, ref f: Formatter) -> Result<(), Error> {
        let mut str: ByteArray = format!(
            "{},{},{},{}", *self.itemId, *self.position.x, *self.position.y, *self.rotation,
        );
        let plugin_len = (*self.plugins).len();
        str += format!(",{}", plugin_len);
        if plugin_len > 0 {
            let mut i = 0;
            loop {
                if i == plugin_len {
                    break;
                }
                let (effectType, chance, stacks) = *(*self.plugins).at(i);
                str += format!(",{},{},{}", effectType, chance, stacks);
                i += 1;
            }
        }

        f.buffer.append(@str);
        Result::Ok(())
    }
}


pub mod Dummy0 {
    use warpack_masters::items::{Backpack, Dagger, Herb, Pack, Spike};
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    pub const level: u32 = 0;
    pub const name: felt252 = 'Noobie';
    pub const wmClass: WMClass = WMClass::Warlock;
    pub const health: u32 = 25;

    pub fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Dagger::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Herb::id,
                    position: Position { x: 4, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Spike::id,
                    position: Position { x: 5, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy1 {
    use warpack_masters::items::{Backpack, Pack, Shield, Spike, Sword};
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 1;
    const name: felt252 = 'Dumbie';
    const wmClass: WMClass = WMClass::Warrior;
    const health: u32 = 35;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Sword::id,
                    position: Position { x: 5, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Shield::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Spike::id,
                    position: Position { x: 4, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}


pub mod Dummy2 {
    use warpack_masters::items::{Backpack, Bow, HealingPotion, Pack, Spike};
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 2;
    const name: felt252 = 'Bertie';
    const wmClass: WMClass = WMClass::Archer;
    const health: u32 = 45;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 5, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Spike::id,
                    position: Position { x: 4, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy3 {
    use warpack_masters::items::{AugmentedDagger, Backpack, Crossbow, Pack, Poison, Shield, Spike};
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 3;
    const name: felt252 = 'Jodie';
    const wmClass: WMClass = WMClass::Warlock;
    const health: u32 = 55;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedDagger::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![(6, 55, 1)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Poison::id,
                    position: Position { x: 4, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Spike::id,
                    position: Position { x: 5, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Crossbow::id,
                    position: Position { x: 3, y: 2 },
                    rotation: 0,
                    plugins: array![(6, 80, 3), (6, 55, 1), (6, 55, 1)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Shield::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy4 {
    use warpack_masters::items::{
        AugmentedSword, Backpack, Club, LeatherArmor, Pack, Pouch, SpikeShield,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 4;
    const name: felt252 = 'Robertie';
    const wmClass: WMClass = WMClass::Warrior;
    const health: u32 = 65;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pouch::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedSword::id,
                    position: Position { x: 5, y: 2 },
                    rotation: 0,
                    plugins: array![(7, 65, 1), (7, 50, 3)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Club::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: SpikeShield::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: LeatherArmor::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 90,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy5 {
    use warpack_masters::items::{Backpack, Bow, Buckler, Crossbow, HealingPotion, MagicWater, Pack};
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 5;
    const name: felt252 = 'Hartie';
    const wmClass: WMClass = WMClass::Archer;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 5, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Crossbow::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Crossbow::id,
                    position: Position { x: 3, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Buckler::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MagicWater::id,
                    position: Position { x: 4, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy6 {
    use warpack_masters::items::{
        AugmentedDagger, Backpack, Crossbow, Herb, Pack, PlagueFlower, Poison, Satchel,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 6;
    const name: felt252 = 'Bardie';
    const wmClass: WMClass = WMClass::Warlock;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 4, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedDagger::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![(6, 80, 3)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedDagger::id,
                    position: Position { x: 5, y: 3 },
                    rotation: 0,
                    plugins: array![(6, 55, 1)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Crossbow::id,
                    position: Position { x: 5, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: PlagueFlower::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Poison::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Herb::id,
                    position: Position { x: 4, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy7 {
    use warpack_masters::items::{
        AugmentedDagger, Backpack, Hammer, Helmet, LeatherArmor, Pack, RageGauntlet, Satchel,
        SpikeShield,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 7;
    const name: felt252 = 'Tartie';
    const wmClass: WMClass = WMClass::Warrior;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 4, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Hammer::id,
                    position: Position { x: 2, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedDagger::id,
                    position: Position { x: 3, y: 0 },
                    rotation: 0,
                    plugins: array![(7, 55, 2)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: RageGauntlet::id,
                    position: Position { x: 3, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: SpikeShield::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: LeatherArmor::id,
                    position: Position { x: 4, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Helmet::id,
                    position: Position { x: 5, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy8 {
    use warpack_masters::items::{
        Backpack, Bow, Buckler, HealingPotion, MagicWater, Pack, Poison, RageGauntlet, Satchel,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 8;
    const name: felt252 = 'Koolie';
    const wmClass: WMClass = WMClass::Archer;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![(6, 55, 1)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 5, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Buckler::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: RageGauntlet::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MagicWater::id,
                    position: Position { x: 3, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 3, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Poison::id,
                    position: Position { x: 5, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy9 {
    use warpack_masters::items::{
        Backpack, Crossbow, HealingPotion, MagicWater, MailArmor, Pack, PlagueFlower, Poison,
        Satchel,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 9;
    const name: felt252 = 'Goobie';
    const wmClass: WMClass = WMClass::Warlock;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: PlagueFlower::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MailArmor::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Poison::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Poison::id,
                    position: Position { x: 2, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Crossbow::id,
                    position: Position { x: 3, y: 2 },
                    rotation: 0,
                    plugins: array![(6, 80, 3), (6, 55, 1), (6, 55, 1)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MagicWater::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 5, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy10 {
    use warpack_masters::items::{
        Backpack, Buckler, Greatsword, HealingPotion, KnightHelmet, MagicWater, Pack, Satchel,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 10;
    const name: felt252 = 'Goodie';
    const wmClass: WMClass = WMClass::Warrior;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Greatsword::id,
                    position: Position { x: 2, y: 0 },
                    rotation: 0,
                    plugins: array![(7, 50, 3)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Buckler::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: KnightHelmet::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MagicWater::id,
                    position: Position { x: 4, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy11 {
    use warpack_masters::items::{
        AugmentedDagger, Backpack, Bow, Buckler, Crossbow, KnightHelmet, MagicWater, Pack, Satchel,
        SpikeShield,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 11;
    const name: felt252 = 'Zippie';
    const wmClass: WMClass = WMClass::Archer;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 4, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 2, y: 3 },
                    rotation: 0,
                    plugins: array![(7, 50, 3)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 3, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Crossbow::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 90,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Buckler::id,
                    position: Position { x: 4, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: KnightHelmet::id,
                    position: Position { x: 5, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MagicWater::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: SpikeShield::id,
                    position: Position { x: 2, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedDagger::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![(6, 80, 3), (6, 80, 3)].span(),
                },
            );

        items
    }
}

pub mod Dummy12 {
    use warpack_masters::items::{
        AugmentedDagger, Backpack, Crossbow, HealingPotion, MailArmor, Pack, PlagueFlower, Poison,
        Pouch, Satchel,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 12;
    const name: felt252 = 'Peppie';
    const wmClass: WMClass = WMClass::Warlock;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pouch::id,
                    position: Position { x: 6, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: PlagueFlower::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Shield::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedDagger::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MailArmor::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 6, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Poison::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Crossbow::id,
                    position: Position { x: 5, y: 4 },
                    rotation: 0,
                    plugins: array![(6, 55, 1)].span(),
                },
            );

        items
    }
}

pub mod Dummy13 {
    use warpack_masters::items::{
        AugmentedSword, Backpack, BladeArmor, Buckler, Greatsword, Hammer, HealingPotion,
        KnightHelmet, MagicWater, Pack,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 13;
    const name: felt252 = 'Bubbie';
    const wmClass: WMClass = WMClass::Warrior;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Greatsword::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![(7, 50, 3)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Hammer::id,
                    position: Position { x: 7, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedSword::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![(7, 65, 1), (7, 55, 2), (7, 50, 3)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: BladeArmor::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Buckler::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 6, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MagicWater::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: KnightHelmet::id,
                    position: Position { x: 5, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy14 {
    use warpack_masters::items::{
        AmuletOfFury, AugmentedSword, Backpack, Bow, HealingPotion, KnightHelmet, MagicWater,
        MailArmor, Pack, Satchel, SpikeShield,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 14;
    const name: felt252 = 'Nettie';
    const wmClass: WMClass = WMClass::Archer;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 4, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 7, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedSword::id,
                    position: Position { x: 6, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: KnightHelmet::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 90,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: SpikeShield::id,
                    position: Position { x: 4, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MailArmor::id,
                    position: Position { x: 3, y: 3 },
                    rotation: 90,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AmuletOfFury::id,
                    position: Position { x: 3, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 3, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MagicWater::id,
                    position: Position { x: 2, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy15 {
    use warpack_masters::items::{
        AugmentedSword, Backpack, Buckler, Crossbow, HealingPotion, MailArmor, Pack, PlagueFlower,
        Poison,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 15;
    const name: felt252 = 'Quillie';
    const wmClass: WMClass = WMClass::Warlock;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: PlagueFlower::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: PlagueFlower::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MailArmor::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Buckler::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Crossbow::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![(6, 80, 3), (6, 80, 3), (6, 55, 1), (6, 55, 1)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedSword::id,
                    position: Position { x: 7, y: 1 },
                    rotation: 0,
                    plugins: array![(7, 65, 1), (7, 50, 3)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 6, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Poison::id,
                    position: Position { x: 6, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Poison::id,
                    position: Position { x: 7, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy16 {
    use warpack_masters::items::{
        AugmentedDagger, Backpack, Greatsword, HealingPotion, KnightHelmet, MailArmor, Pack,
        Satchel, SpikeShield, VampiricArmor,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 16;
    const name: felt252 = 'Winkie';
    const wmClass: WMClass = WMClass::Warrior;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 6, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: VampiricArmor::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Greatsword::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![(7, 50, 3)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedDagger::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedDagger::id,
                    position: Position { x: 7, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MailArmor::id,
                    position: Position { x: 6, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: SpikeShield::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: KnightHelmet::id,
                    position: Position { x: 2, y: 5 },
                    rotation: 90,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 4, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy17 {
    use warpack_masters::items::{
        AmuletOfFury, AugmentedSword, Backpack, BladeArmor, Bow, HealingPotion, KnightHelmet,
        MagicWater, MailArmor, Pack, Satchel,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 17;
    const name: felt252 = 'Rennie';
    const wmClass: WMClass = WMClass::Archer;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 2, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 3, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedSword::id,
                    position: Position { x: 7, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: KnightHelmet::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 90,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: BladeArmor::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MailArmor::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 90,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 7, y: 4 },
                    rotation: 90,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AmuletOfFury::id,
                    position: Position { x: 3, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MagicWater::id,
                    position: Position { x: 6, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy18 {
    use warpack_masters::items::{
        AugmentedSword, Backpack, Bow, HealingPotion, MailArmor, Pack, PlagueFlower, Poison,
        Satchel, VampiricArmor,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 18;
    const name: felt252 = 'Huggie';
    const wmClass: WMClass = WMClass::Warlock;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 6, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: PlagueFlower::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: PlagueFlower::id,
                    position: Position { x: 6, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MailArmor::id,
                    position: Position { x: 4, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: VampiricArmor::id,
                    position: Position { x: 2, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedSword::id,
                    position: Position { x: 5, y: 3 },
                    rotation: 90,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 90,
                    plugins: array![(6, 80, 3), (6, 80, 3), (6, 55, 1)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Poison::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 5, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy19 {
    use warpack_masters::items::{
        AmuletOfFury, AugmentedSword, Backpack, BladeArmor, Buckler, Greatsword, Hammer,
        HealingPotion, Helmet, KnightHelmet, MagicWater, Pack, RageGauntlet,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 19;
    const name: felt252 = 'Dottie';
    const wmClass: WMClass = WMClass::Warrior;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Greatsword::id,
                    position: Position { x: 2, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: BladeArmor::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedSword::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Hammer::id,
                    position: Position { x: 7, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: KnightHelmet::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: RageGauntlet::id,
                    position: Position { x: 3, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AmuletOfFury::id,
                    position: Position { x: 6, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Buckler::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 4, y: 6 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Helmet::id,
                    position: Position { x: 5, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MagicWater::id,
                    position: Position { x: 5, y: 6 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy20 {
    use warpack_masters::items::{
        AmuletOfFury, AugmentedSword, Backpack, Bow, Crossbow, KnightHelmet, MagicWater, MailArmor,
        Pack, PlagueFlower, Satchel, VampiricArmor,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 20;
    const name: felt252 = 'Quackie';
    const wmClass: WMClass = WMClass::Archer;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 6, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 6, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 2, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Bow::id,
                    position: Position { x: 3, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedSword::id,
                    position: Position { x: 2, y: 3 },
                    rotation: 0,
                    plugins: array![(7, 65, 1), (7, 50, 3)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Crossbow::id,
                    position: Position { x: 3, y: 3 },
                    rotation: 0,
                    plugins: array![(6, 80, 3)].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: PlagueFlower::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: VampiricArmor::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MailArmor::id,
                    position: Position { x: 6, y: 1 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AmuletOfFury::id,
                    position: Position { x: 3, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MagicWater::id,
                    position: Position { x: 7, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MagicWater::id,
                    position: Position { x: 7, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: KnightHelmet::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
    }
}

pub mod Dummy21 {
    use warpack_masters::items::{
        AugmentedDagger, Backpack, Crossbow, HealingPotion, MailArmor, Pack, PlagueFlower, Poison,
        Pouch, Satchel,
    };
    use warpack_masters::models::Character::WMClass;
    use warpack_masters::models::CharacterItem::Position;
    use super::PredefinedItem;

    const level: u32 = 21;
    const name: felt252 = 'Goldie';
    const wmClass: WMClass = WMClass::Warlock;
    const health: u32 = 80;

    fn get_items() -> Array<PredefinedItem> {
        let mut items: Array<PredefinedItem> = array![];
        items
            .append(
                PredefinedItem {
                    itemId: Backpack::id,
                    position: Position { x: 4, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pack::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Satchel::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Pouch::id,
                    position: Position { x: 6, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: PlagueFlower::id,
                    position: Position { x: 2, y: 2 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: PlagueFlower::id,
                    position: Position { x: 2, y: 4 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: AugmentedDagger::id,
                    position: Position { x: 4, y: 3 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: MailArmor::id,
                    position: Position { x: 4, y: 0 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: HealingPotion::id,
                    position: Position { x: 6, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Poison::id,
                    position: Position { x: 4, y: 5 },
                    rotation: 0,
                    plugins: array![].span(),
                },
            );

        items
            .append(
                PredefinedItem {
                    itemId: Crossbow::id,
                    position: Position { x: 5, y: 4 },
                    rotation: 0,
                    plugins: array![(6, 55, 1)].span(),
                },
            );

        items
    }
}
