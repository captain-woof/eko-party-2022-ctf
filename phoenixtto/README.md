# README

## Introduction

This challenge is all about trying to understand what's really happening.

Upon inspection, `reBorn(bytes)` deploys a smart contract with the code you provide, then uses it as an implementation, by attempting to deploy "Phoenixtto". The bytecode embedded, if decompiled, makes it clear that it actually queries the implementation, and copies its code onto itself during its constructor phase.

So, an implementation that sets owner to player will pass the challenge.

## Bytecode decompilation

```
58 -             PC
60 20 -          PUSH1 0x20
81 -             DUP2
58 -             PC
60 1c -          PUSH1 0x1c
33 -             CALLER
5A -             GAS
63 aa f1 0f 42 - PUSH4 aa f1 0f 42
87 -             DUP8
52 -             MSTORE
fa -             STATICCALL (`getImplementation()`)
15 -             ISZERO
81 -             DUP2
51 -             MLOAD
80 -             DUP1
3b -             EXTCODESIZE
80 -             DUP1
93 -             SWAP4
80 -             DUP1
91 -             SWAP2
92 -             SWAP3
3c -             EXTCODECOPY (copies code from implementation contract)
f3 -             RETURN
```


If this is used as deploy call data, this happens (in Phoenixtto contract):
1. Static Call deployer (Laboratory) with selector 0xaaf10f42, i.e, `getImplementation()`
2. It then copies contract code from address returned in #1, and returns it (so this becomes new contract's code)