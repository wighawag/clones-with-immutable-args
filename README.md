# ClonesWithImmutableArgs

Enables creating clone contracts with immutable arguments.

The immutable arguments are stored in the code region of the created proxy contract, and whenever the proxy is called, it reads the arguments into memory, and then appends them to the calldata of the delegate call to the implementation contract. The implementation contract can thus read the arguments straight from calldata.

By doing so, the gas cost of creating parametrizable clones is reduced, since there's no need to store the parameters in storage, which you need to do with [EIP-1167](https://eips.ethereum.org/EIPS/eip-1167). The cost of using such clones is also reduced, since storage loads are replaced with calldata reading, which is far cheaper.

In other word, if you know you are not gonna need parametrization and just want exact copies, then you can keep using EIP-1167, otherwise, clones-with-immutables is cheaper.

## Usage

Clone factory contracts should use the [`ClonesWithImmutableArgs`](src/ClonesWithImmutableArgs.sol) library. `ClonesWithImmutableArgs.clone()` is the main function for creating clones.

Contracts intended to be cloned should inherit from [`Clone`](src/Clone.sol) to get access to the helper functions for reading immutable args.

To see an example usage of the library, check out [`ExampleClone`](src/ExampleClone.sol) and [`ExampleCloneFactory`](src/ExampleCloneFactory.sol).

## Installation

To install with [DappTools](https://github.com/dapphub/dapptools):

```
dapp install wighawag/clones-with-immutable-args
```

To install with [Foundry](https://github.com/gakonst/foundry):

```
forge install wighawag/clones-with-immutable-args
```

To install with [Hardhat](https://hardhat.org):

```
npm i -D clones-with-immutable-args
```

## Local development

This project uses [Foundry](https://github.com/gakonst/foundry) as the development framework.

### Dependencies

```
make update
```

### Compilation

```
make build
```

### Testing

```
make test
```
