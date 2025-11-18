use core::traits::TryInto;
use starknet::ContractAddress;

pub fn zero_address() -> ContractAddress {
    0.try_into().unwrap()
}

pub fn address_from(value: felt252) -> ContractAddress {
    value.try_into().unwrap()
}

