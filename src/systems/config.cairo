#[dojo::contract]
mod config_system {
    use dojo::model::ModelStorage;
    use starknet::ContractAddress;
    use warpack_masters::constants::constants::GAME_CONFIG_ID;
    use warpack_masters::models::Game::GameConfig;
    use warpack_masters::utils::address::zero_address;


    fn dojo_init(ref self: ContractState, contract_address: ContractAddress) {
        let mut world = self.world(@"Warpacks");

        world
            .write_model(
                @GameConfig {
                    id: GAME_CONFIG_ID,
                    strk_address: contract_address,
                    treasury_address: zero_address(),
                },
            );
    }
}
