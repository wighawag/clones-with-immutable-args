// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

import {ExampleClone} from "./ExampleClone.sol";
import {ClonesWithImmutableArgs} from "./ClonesWithImmutableArgs.sol";

contract ExampleCloneFactory {
    using ClonesWithImmutableArgs for address;

    ExampleClone public implementation;

    constructor(ExampleClone implementation_) {
        implementation = implementation_;
    }

    function createClone(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4
    ) external payable returns (ExampleClone clone) {
        bytes memory data = abi.encodePacked(param1, param2, param3, param4);
        clone = ExampleClone(address(implementation).clone(data, msg.value));
    }

    function createClone2(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4
    ) external payable returns (ExampleClone clone) {
        bytes memory data = abi.encodePacked(param1, param2, param3, param4);
        clone = ExampleClone(address(implementation).clone2(data, msg.value));
    }

    function addressOfClone2(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4
    ) external view returns (address clone) {
        bytes memory data = abi.encodePacked(param1, param2, param3, param4);
        clone = address(implementation).addressOfClone2(data);
    }

    function createClone3(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4,
        bytes32 salt
    ) external payable returns (ExampleClone clone) {
        bytes memory data = abi.encodePacked(param1, param2, param3, param4);
        clone = ExampleClone(
            address(implementation).clone3(data, salt, msg.value)
        );
    }

    function addressOfClone3(bytes32 salt) external view returns (address) {
        return ClonesWithImmutableArgs.addressOfClone3(salt);
    }
}
