// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

import {DSTest} from "ds-test/test.sol";

import {ClonesWithImmutableArgs} from "../ClonesWithImmutableArgs.sol";
import {ExampleClone} from "../ExampleClone.sol";

contract ClonesWithImmutableArgsTest is DSTest {
    /// -----------------------------------------------------------------------
    /// Correctness tests
    /// -----------------------------------------------------------------------
    function testCorrectness_addressOfClone3CleanAddress(bytes32 salt) public {
        uint256 remainderMask = ~(uint256(type(uint160).max));
        address predicted = ClonesWithImmutableArgs.addressOfClone3(salt);

        uint256 remainder;
        assembly ("memory-safe") {
            remainder := and(predicted, remainderMask)
        }
        assertEq(remainder, 0);
    }

    function testCorrectness_clone3CleanAddress(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4,
        bytes32 salt
    ) public {
        address implementation = address(new ExampleClone());
        uint256 remainderMask = ~(uint256(type(uint160).max));
        bytes memory data = abi.encodePacked(param1, param2, param3, param4);
        address clone = ClonesWithImmutableArgs.clone3(
            implementation,
            data,
            salt,
            0
        );

        uint256 remainder;
        assembly ("memory-safe") {
            remainder := and(clone, remainderMask)
        }
        assertEq(remainder, 0);
    }
}
