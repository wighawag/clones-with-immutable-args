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

      mstore(
        ptr,
        0x3d61000000000000000000000000000000000000000000000000000000000000
      )
      // TODO for now : PUSH2 (0x61), do higher ?, probably not necessary as 16bit size is greater than what contract can be
      mstore(add(ptr, 0x02), shl(240, runSize)) // size of the contract running bytecode  // TODO support bigger
      mstore(
        add(ptr, 0x04),
        0x80600b3d3981f300000000000000000000000000000000000000000000000000
      )

      mstore(
        add(ptr, 0x0b),
        0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000
      )
      mstore(add(ptr, 0x15), shl(0x60, implementation))

      mstore(
        add(ptr, 0x29),
        0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
      )
    }

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

  // TODO
  function cloneWithCallDataProvision(address implementation, bytes memory data)
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

      mstore(
        ptr,
        0x3d61000000000000000000000000000000000000000000000000000000000000
      )
      // TODO for now : PUSH2 (0x61), do higher ?, probably not necessary as 16bit size is greater than what contract can be
      mstore(add(ptr, 0x02), shl(240, runSize)) // size of the contract running bytecode  // TODO support bigger
      mstore(
        add(ptr, 0x04),
        0x80600b3d3981f300000000000000000000000000000000000000000000000000
      )

      mstore(
        add(ptr, 0x0b),
        0x363d3d373d3d3d363d7300000000000000000000000000000000000000000000
      )
      mstore(add(ptr, 0x15), shl(0x60, implementation))

      mstore(
        add(ptr, 0x29),
        0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
      )
    }

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


  // ------------------------------------------------------------

  function read(address _pointer) internal view returns (bytes memory) {
    return codeAt(_pointer, 45, type(uint256).max);
  }

  function codeSize(address _addr) internal view returns (uint256 size) {
    assembly {
      size := extcodesize(_addr)
    }
  }

  function codeAt(
    address _addr,
    uint256 _start,
    uint256 _end
  ) internal view returns (bytes memory oCode) {
    uint256 csize = codeSize(_addr);
    if (csize == 0) return bytes("");

    if (_start > csize) return bytes("");
    // if (_end < _start) revert InvalidCodeAtRange(csize, _start, _end);

    unchecked {
      uint256 reqSize = _end - _start;
      uint256 maxSize = csize - _start;

      uint256 size = maxSize < reqSize ? maxSize : reqSize;

      assembly {
        // allocate output byte array - this could also be done without assembly
        // by using o_code = new bytes(size)
        oCode := mload(0x40)
        // new "memory end" including padding
        mstore(
          0x40,
          add(oCode, and(add(add(size, add(_start, 0x20)), 0x1f), not(0x1f)))
        )
        // store length in memory
        mstore(oCode, size)
        // actually retrieve the code, this needs assembly
        extcodecopy(_addr, add(oCode, 0x20), _start, size)
      }
    }
  }
}
