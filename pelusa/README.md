# README

## Introduction

The challenge is really just about passing through some validation checks.

One of the checks require the contract address to fit a pattern, so a bruteforcer is needed. The script here does everything.

## Forking to test script

### Run fork
```
anvil --fork-url https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161 --fork-block-number "PELUSA_DEPLOY_BLOCK_NUM" 
```

### Run script
```
source ./.env
forge script --private-key $PRIVATE_KEY -s "run(address,address,uint256)" --rpc-url http://127.0.0.1:8545 -vvv --target-contract PelusaScript ./script/Pelusa.s.sol "PELUSA_ADDR" "PELUSA_DEPLOYER_ADDR" "PELUSA_DEPLOY_BLOCK_NUM"
```

## Solving challenge

### Run script

```
forge script --private-key $PRIVATE_KEY -s "run(address,address,uint256)" --rpc-url http://127.0.0.1:8545 -vvv --target-contract PelusaScript --broadcast ./script/Pelusa.s.sol "PELUSA_ADDR" "PELUSA_DEPLOYER_ADDR" "PELUSA_DEPLOY_BLOCK_NUM"
```

forge script --private-key $PRIVATE_KEY -s "run(address,address,uint256)" --rpc-url https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161 -vvv --broadcast --target-contract PelusaScript ./script/Pelusa.s.sol 0x3AEf964F2AefdaeF23F1Ff65773e20d7C083320D 0xaa758e00eca745cab9232b207874999f55481951 8256185