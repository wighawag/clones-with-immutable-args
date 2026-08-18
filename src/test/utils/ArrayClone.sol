// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

import {Clone} from "../../Clone.sol";

/// @notice Test-only clone with a uint256[] immutable arg surrounded by other
///         args, so that offset mistakes on either side are observable.
contract ArrayClone is Clone {
    /// @return the address packed before the array
    function head() public pure returns (address) {
        return _getArgAddress(0);
    }

    /// @param arrLen the number of elements packed at offset 20
    function arr(uint64 arrLen) public pure returns (uint256[] memory) {
        return _getArgUint256Array(20, arrLen);
    }

    /// @return the uint64 packed immediately after the array
    function tail(uint64 arrLen) public pure returns (uint64) {
        return _getArgUint64(20 + 32 * uint256(arrLen));
    }
}
