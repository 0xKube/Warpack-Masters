use starknet::ContractAddress;

#[derive(Drop, Serde, Introspect, DojoStore)]
#[dojo::model]
pub struct TokenRegistry {
    #[key]
    pub item_id: u32,
    pub name: ByteArray,
    pub symbol: ByteArray,
    pub token_address: ContractAddress,
    pub is_active: bool,
}
