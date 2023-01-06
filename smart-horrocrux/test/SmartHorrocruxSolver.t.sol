// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/ChallengeSmartHorrocrux.sol";
import "../src/SmartHorrocruxSolver.sol";

contract SmartHorrocruxTest is Test {
    SmartHorrocrux smartHorrocrux;
    SmartHorrocruxSolver smartHorrocruxSolver;

    function setUp() external {
        smartHorrocrux = new SmartHorrocrux{value: 2}();
        smartHorrocruxSolver = new SmartHorrocruxSolver();
    }

    function testAttack() external {
        // Attack
        smartHorrocruxSolver.solve{value: 1}(address(smartHorrocrux));

        // Check attack success
        require(_isChallengeComplete(), "NOT SOLVED"); // This fails for whatever reason, but SmartHorrocrux does get self-destructed
    }

    /////////////
    // HELPERS //
    /////////////

    function _isChallengeComplete() internal view returns (bool) {
        uint256 size;
        address smartHorrocruxAddr = address(smartHorrocrux);
        assembly {
            size := extcodesize(smartHorrocruxAddr)
        }
        return size == 0;
    }
}