// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "ds-test/test.sol";

contract ClonesWithImmutableArgs is DSTest {
  
  function clone(address implementation, bytes memory data)
    internal
    returns (address instance)
  {
    uint256 extraLength = data.length;
    uint256 creationSize = 0x38 + extraLength;
    uint256 runSize = creationSize - 11;
    uint256 dataPtr;
    uint256 ptr;
    assembly {
      ptr := mload(0x40)
 
      // -------------------------------------------------------------------------------------------------------------
      // CREATION (11 bytes)
      // -------------------------------------------------------------------------------------------------------------

      // 3d          | RETURNDATASIZE        | 0                       | –
      // 61 runtime  | PUSH2 runtime (r)     | r 0                     | –
      mstore(
        ptr,
        0x3d61000000000000000000000000000000000000000000000000000000000000
      )
      mstore(add(ptr, 0x02), shl(240, runSize)) // size of the contract running bytecode (16 bits)

      // creation size = 0b
      // 80          | DUP1                  | r r 0                   | –
      // 60 creation | PUSH1 creation (c)    | c r r 0                 | –
      // 3d          | RETURNDATASIZE        | 0 c r r 0               | –
      // 39          | CODECOPY              | r 0                     | [0-2d]: runtime code
      // 81          | DUP2                  | 0 c  0                  | [0-2d]: runtime code
      // f3          | RETURN                | 0                       | [0-2d]: runtime code
      mstore(
        add(ptr, 0x04),
        0x80600b3d3981f300000000000000000000000000000000000000000000000000
      )

      // -------------------------------------------------------------------------------------------------------------
      // RUNTIME
      // -------------------------------------------------------------------------------------------------------------

      // 36          | CALLDATASIZE          | cds                     | –
      // 3d          | RETURNDATASIZE        | 0 cds                   | –
      // 3d          | RETURNDATASIZE        | 0 0 cds                 | –
      // 37          | CALLDATACOPY          | –                       | [0, cds] = calldata
      // 3d          | RETURNDATASIZE        | 0                       | [0, cds] = calldata
      // 3d          | RETURNDATASIZE        | 0 0                     | [0, cds] = calldata
      // 3d          | RETURNDATASIZE        | 0 0 0                   | [0, cds] = calldata
      // 36          | CALLDATASIZE          | cds 0 0 0               | [0, cds] = calldata
      // 3d          | RETURNDATASIZE        | 0 cds 0 0 0             | [0, cds] = calldata
      // 73 addr     | PUSH20 0x123…         | addr 0 cds 0 0 0        | [0, cds] = calldata
      mstore(
        add(ptr, 0x0b),
        0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000
      )
      mstore(add(ptr, 0x15), shl(0x60, implementation))


      // 5a          | GAS                   | gas addr 0 cds 0 0 0    | [0, cds] = calldata
      // f4          | DELEGATECALL          |success 0                | [0, cds] = calldata
      // 3d          | RETURNDATASIZE        | rds success 0           | [0, cds] = calldata
      // 82          | DUP3                  | 0 rds success 0         | [0, cds] = calldata
      // 80          | DUP1                  | 0 0 rds success 0       | [0, cds] = calldata
      // 3e          | RETURNDATACOPY        | success 0               | [0, rds] = return data (there might be some irrelevant leftovers in memory [rds, cds] when rds < cds)
      // 90          | SWAP1                 | 0 success               | [0, rds] = return data
      // 3d          | RETURNDATASIZE        | rds 0 success           | [0, rds] = return data
      // 91          | SWAP2                 | success 0 rds           | [0, rds] = return data
      // 60 dest     | PUSH1 dest            | dest sucess 0 rds       | [0, rds] = return data
      // 57          | JUMPI                 | 0 rds                   | [0, rds] = return data
      // fd          | REVERT                | –                       | [0, rds] = return data
      // 5b          | JUMPDEST              | 0 rds                   | [0, rds] = return data
      // f3          | RETURN                | –                       | [0, rds] = return data

      mstore(
        add(ptr, 0x29),
        0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
      )
    }


    // -------------------------------------------------------------------------------------------------------------
    // APPENDED DATA (Accessible from extcodecopy)
    // -------------------------------------------------------------------------------------------------------------

    uint256 copyPtr = ptr + 0x38;
    assembly {
      dataPtr := add(data, 32)
    }
    for (; extraLength >= 32; extraLength -= 32) {
      assembly {
        mstore(copyPtr, mload(dataPtr))
      }
      copyPtr += 32;
      dataPtr += 32;
    }
    uint256 mask = ~(256**(32 - extraLength) - 1);
    assembly {
      mstore(copyPtr, and(mload(dataPtr), mask))
    }
    assembly {
      instance := create(0, ptr, creationSize)
    }
    require(instance != address(0), "create failed");
  }

}
