// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "../src/SmartHorrocruxSolver.sol";

contract SmartHorrocruxTest is Script {
    function run(address _smartHorrocruxAddr) external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Deploy contracts
        SmartHorrocruxSolver smartHorrocruxSolver = new SmartHorrocruxSolver();

        // Attack
        smartHorrocruxSolver.solve{value: 1}(_smartHorrocruxAddr);

        vm.stopBroadcast();
    }
}
