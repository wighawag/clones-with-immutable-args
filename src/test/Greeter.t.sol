// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./utils/GreeterTest.sol";
import {Errors} from "../Greeter.sol";

contract Greet is GreeterTest {
    // function testCannotGm() public {
    //     try alice.greet("gm") {
    //         fail();
    //     } catch Error(string memory error) {
    //         assertEq(error, Errors.CannotGm);
    //     }
    // }

    // function testCanSetGreeting() public {
    //     alice.greet("hi");
    //     assertEq(greeter.greeting(), "hi");
    // }

    // function testWorksForAllGreetings(string memory greeting) public {
    //     alice.greet(greeting);
    //     assertEq(greeter.greeting(), greeting);
    // }

    // function _convert(uint256 location)
    //     internal
    //     pure
    //     returns (int128 x, int128 y)
    // {
    //     x = int128(int256(location & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
    //     y = int128(int256(location >> 128));
    // }

    // function _convertXYToXY(int128 ix, int128 iy)
    //     internal
    //     pure
    //     returns (
    //         int128 x,
    //         int128 y,
    //         uint256 location
    //     )
    // {
    //     location = uint256(int256(ix)) + uint256(int256(iy) << 128);
    //     x = int128(int256(location & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF));
    //     y = int128(int256(location >> 128));
    // }

    // function _convertLocationToLocation(uint256 location)
    //     internal
    //     pure
    //     returns (
    //         int128 x,
    //         int128 y,
    //         uint256 newLocation
    //     )
    // {
    //     (int128 ix, int128 iy) = _convert(location);
    //     // return _convertXYToXY(ix, iy);
    // }

    // function testConversion(string memory greeting) public {
    //     // alice.greet(greeting);
    //     // assertEq(greeter.greeting(), greeting);

    //     (int128 x, int128 y) = _convert(location);

    //     uint256 location = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    //     (,, uint256 newLocation) = _convertLocationToLocation(
    //         location
    //     );
    //     // assertEq(location, newLocation);
    // }

    function testClone2() public {
        Greeter clone = greeter.clone(789);
        uint256 num = clone.getUInt();
        assertEq(num, 789);
    }

    function testClone3() public {
        emit log("hello");
        Greeter clone = greeter.clone3(64654545454);
        uint256 num = clone.getUInt();
        assertEq(num, 64654545454);
    }
}

contract Gm is GreeterTest {
    // function testOwnerCanGmOnGoodBlocks() public {
    //     hevm.roll(10);
    //     alice.gm();
    //     assertEq(greeter.greeting(), "gm");
    // }
    // function testOwnerCannotGmOnBadBlocks() public {
    //     hevm.roll(11);
    //     try alice.gm() {
    //         fail();
    //     } catch Error(string memory error) {
    //         assertEq(error, Errors.InvalidBlockNumber);
    //     }
    // }
    // function testNonOwnerCannotGm() public {
    //     try bob.gm() {
    //         fail();
    //     } catch Error(string memory error) {
    //         assertEq(error, "Ownable: caller is not the owner");
    //     }
    // }
}
