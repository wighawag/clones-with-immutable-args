// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Utils {

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

  function codeAtLen(
    address _addr,
    uint256 _start,
    uint256 _len
  ) internal view returns (bytes memory oCode) {
    
    unchecked {
      assembly {
        // allocate output byte array - this could also be done without assembly
        // by using o_code = new bytes(size)
        oCode := mload(0x40)
        // new "memory end" including padding
        mstore(
          0x40,
          add(oCode, and(add(add(_len, add(_start, 0x20)), 0x1f), not(0x1f)))
        )
        // store length in memory
        mstore(oCode, _len)
        // actually retrieve the code, this needs assembly
        extcodecopy(_addr, add(oCode, 0x20), _start, _len)
      }
    }
  }
}