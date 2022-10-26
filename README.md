# NFT721 and RNFT721

Smart contracts for gas optimized & scalable **NFT (Non Fungible Token)** and **RNFT (Rentable NFT)**.

## Features

- Support contract UUPS upgradeable
- Solidity 0.8.17
- Blacklist User
- Authority
- Treasury
- ProtocolFee
- ERC4907
- ERC721Enumerable
- ERC721Permit for gasless NFT transfer/NFT lending

## Set up

Node >= 10.x && yarn > 2.x

```
$ node --version
v16.13.0

$ corepack enable

$ yarn --version
3.2.3
```

Install dependencies

```
$ yarn
```

## Test

1. Compile contract

```
$ yarn compile
```

## Testnet deployment

1. BSC Testnet

```
PRIVATE_KEY=<admin-private-key>
TBSC_API_KEY=<admin-bsc-api>
yarn deploy:bscTest
```

## Example contracts

```
Authority:  0xaB9361696Fa45BdE29741dFC8C59a2F825DBE13a
Treasury:  0xc4c34E5AD26DbaAf4449F8D5B69ac46E4D6Fe044
ERC20Test:  0x57dAe0e7e34d0636Ee7048dde8Dc9781DE9B9349
RentableNFC:  0x4C1b9317cDe7eDcfA18EEF5Ddd0EcFB8E287F684
```

## Upgrade factory contracts

1. Clean cache and precompiled folders to avoid conflict errors

```
$ yarn clean
```

2. Put your folder `.oppenzeppelin` into root directory
3. Update your smart contracts
4. Run upgrade via `ProxyAdmin` contract

```
RNFT=<contract-proxy-address>
$ yarn upgrade:bscTest
```

For more information, you can check this link [here](https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies)

## Solidity linter and prettiers

1. Run linter to analyze convention and security for smart contracts

```
$ yarn sol:linter
```

2. Format smart contracts

```
$ yarn sol:prettier
```
