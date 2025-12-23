use warpack_masters::externals::interface::{
    IVrfProviderDispatcher, IVrfProviderDispatcherTrait, Source,
};
use core::integer::u256;
use core::poseidon::poseidon_hash_span;
use core::traits::{Into, TryInto};
use starknet::{ContractAddress, get_caller_address};
use warpack_masters::constants::constants::VRF_PROVIDER_ADDRESS;

#[derive(Drop, Copy, Clone)]
pub struct RandomStream {
    pub base: felt252,
    pub cursor: u32,
}

// Requires the transaction to be prefixed with IVrfProvider.request_random using the same Source::Nonce.
pub fn random_stream_from_vrf_nonce() -> RandomStream {
    let vrf_address: ContractAddress = VRF_PROVIDER_ADDRESS.try_into().unwrap();
    let vrf = IVrfProviderDispatcher { contract_address: vrf_address };
    let base = vrf.consume_random(Source::Nonce(get_caller_address()));
    RandomStream { base, cursor: 0 }
}

// Returns a bounded random value in [0, max_exclusive) and advances the stream.
pub fn random_stream_next(ref rng: RandomStream, max_exclusive: u32) -> u32 {
    assert(max_exclusive > 0, 'random max must be > 0');

    let mixed = poseidon_hash_span(array![rng.base, rng.cursor.into()].span());
    rng.cursor += 1;

    let mixed_u256: u256 = mixed.into();
    let max_u256 = u256 { low: max_exclusive.into(), high: 0 };
    let bounded_u256 = mixed_u256 % max_u256;
    bounded_u256.low.try_into().unwrap()
}
