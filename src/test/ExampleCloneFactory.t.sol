// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

import {DSTest} from "ds-test/test.sol";

import {Hevm} from "./utils/Hevm.sol";
import {ExampleClone} from "../ExampleClone.sol";
import {ExampleCloneFactory} from "../ExampleCloneFactory.sol";

contract ExampleCloneFactoryTest is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    ExampleCloneFactory internal factory;

    function setUp() public {
        ExampleClone implementation = new ExampleClone();
        factory = new ExampleCloneFactory(implementation);
    }

    /// -----------------------------------------------------------------------
    /// Gas benchmarking
    /// -----------------------------------------------------------------------

    function testGas_clone(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4
    ) public {
        factory.createClone(param1, param2, param3, param4);
    }

    function testGas_clone3(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4,
        bytes32 salt
    ) public {
        factory.createClone3(param1, param2, param3, param4, salt);
    }

    /// -----------------------------------------------------------------------
    /// Correctness tests
    /// -----------------------------------------------------------------------

    function testCorrectness_clone(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4
    ) public {
        ExampleClone clone = factory.createClone(
            param1,
            param2,
            param3,
            param4
        );
        assertEq(clone.param1(), param1);
        assertEq(clone.param2(), param2);
        assertEq(clone.param3(), param3);
        assertEq(clone.param4(), param4);
    }

    function testCorrectness_clone_value(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4
    ) public {
        ExampleClone clone = factory.createClone{value: 1 wei}(
            param1,
            param2,
            param3,
            param4
        );
        assertEq(clone.param1(), param1);
        assertEq(clone.param2(), param2);
        assertEq(clone.param3(), param3);
        assertEq(clone.param4(), param4);
    }

    function testCorrectness_clone2(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4
    ) public {
        ExampleClone clone = factory.createClone2(
            param1,
            param2,
            param3,
            param4
        );
        assertEq(clone.param1(), param1);
        assertEq(clone.param2(), param2);
        assertEq(clone.param3(), param3);
        assertEq(clone.param4(), param4);
    }

    function testCorrectness_clone2_value(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4
    ) public {
        ExampleClone clone = factory.createClone2{value: 1 wei}(
            param1,
            param2,
            param3,
            param4
        );
        assertEq(clone.param1(), param1);
        assertEq(clone.param2(), param2);
        assertEq(clone.param3(), param3);
        assertEq(clone.param4(), param4);
    }

    function testCorrectness_clone3(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4,
        bytes32 salt
    ) public {
        ExampleClone clone = factory.createClone3(
            param1,
            param2,
            param3,
            param4,
            salt
        );
        assertEq(clone.param1(), param1);
        assertEq(clone.param2(), param2);
        assertEq(clone.param3(), param3);
        assertEq(clone.param4(), param4);
        assertEq(address(clone), factory.addressOfClone3(salt));
    }

    function testCorrectness_clone3_value(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4,
        bytes32 salt
    ) public {
        ExampleClone clone = factory.createClone3{value: 1 wei}(
            param1,
            param2,
            param3,
            param4,
            salt
        );
        assertEq(clone.param1(), param1);
        assertEq(clone.param2(), param2);
        assertEq(clone.param3(), param3);
        assertEq(clone.param4(), param4);
        assertEq(address(clone), factory.addressOfClone3(salt));
    }

    function testCorrectness_addressOfClone2(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4
    ) public {
        address predicted = factory.addressOfClone2(
            param1,
            param2,
            param3,
            param4
        );
        ExampleClone clone = factory.createClone2(
            param1,
            param2,
            param3,
            param4
        );
        assertEq(predicted, address(clone));
    }

    /// -----------------------------------------------------------------------
    /// Failure tests
    /// -----------------------------------------------------------------------

    function testFail_clone3_initializeFail(
        address param1,
        uint256 param2,
        uint64 param3,
        uint8 param4,
        bytes32 salt
    ) public {
        // deploying with the same salt twice should trigger the InitializeFail() error
        factory.createClone3(param1, param2, param3, param4, salt);
        factory.createClone3(param1, param2, param3, param4, salt);
    }
}
