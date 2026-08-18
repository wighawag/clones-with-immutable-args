// SPDX-License-Identifier: BSD
pragma solidity ^0.8.4;

import {DSTest} from "ds-test/test.sol";

import {Hevm} from "./utils/Hevm.sol";
import {ArrayClone} from "./utils/ArrayClone.sol";
import {ClonesWithImmutableArgs} from "../ClonesWithImmutableArgs.sol";

/// @notice The library functions are internal, so they are inlined into their
///         caller. Reverts must be raised across an external call boundary for
///         expectRevert to observe them.
contract CloneHarness {
    function clone2(
        address implementation,
        bytes memory data
    ) external returns (address) {
        return ClonesWithImmutableArgs.clone2(implementation, data);
    }
}

/// @notice Characterisation tests for immutable arg packing and reading.
/// @dev These pin behaviour that must not change when the creation bytecode
///      assembly or the arg readers are optimised. They are written against an
///      independent re-derivation of the expected bytecode, not against a
///      golden blob, so a mistake in either implementation is caught.
contract CloneArgsTest is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    address internal implementation;
    CloneHarness internal harness;

    function setUp() public {
        implementation = address(new ArrayClone());
        harness = new CloneHarness();
    }

    /// -----------------------------------------------------------------------
    /// Creation bytecode layout
    /// -----------------------------------------------------------------------

    /// @dev Rebuilds the expected creation bytecode from the documented layout,
    ///      independently of how the library assembles it in memory.
    function expectedCreationBytecode(
        address impl,
        bytes memory data
    ) internal pure returns (bytes memory) {
        uint256 extraLength = data.length + 2;
        uint256 creationSize = 0x41 + extraLength;
        uint256 runSize = creationSize - 10;

        return
            abi.encodePacked(
                // creation (10 bytes)
                hex"61",
                uint16(runSize),
                hex"3d81600a3d39f3",
                // runtime (55 bytes + extraLength)
                hex"3d3d3d3d363d3d37",
                hex"61",
                uint16(extraLength),
                hex"6037363936",
                hex"61",
                uint16(extraLength),
                hex"013d73",
                impl,
                hex"5af43d3d93803e603557fd5bf3",
                // appended data + its length suffix
                data,
                uint16(data.length)
            );
    }

    /// @dev The final partial word of `data` is written through a mask, so the
    ///      lengths either side of a 32 byte boundary are the interesting ones.
    function test_creationBytecode_matchesLayoutAcrossWordBoundaries() public {
        uint256[9] memory lengths = [
            uint256(0),
            1,
            31,
            32,
            33,
            63,
            64,
            65,
            96
        ];

        for (uint256 i = 0; i < lengths.length; i++) {
            bytes memory data = _fill(lengths[i]);
            assertEq0(
                ClonesWithImmutableArgs.getCreationBytecode(
                    implementation,
                    data
                ),
                expectedCreationBytecode(implementation, data),
                "creation bytecode mismatch"
            );
        }
    }

    function test_creationBytecode_matchesLayout(bytes memory data) public {
        if (data.length > 1024) return;
        assertEq0(
            ClonesWithImmutableArgs.getCreationBytecode(implementation, data),
            expectedCreationBytecode(implementation, data)
        );
    }

    /// @dev The masked write must not let stale bytes past the end of `data`
    ///      leak into the deployed code.
    function test_creationBytecode_doesNotLeakBeyondData() public {
        // a long dirty buffer is allocated first, so the memory that a partial
        // word write could over-read is non-zero
        bytes memory dirty = _fill(256);
        assertEq(uint256(uint8(dirty[255])), 255 % 256);

        for (uint256 len = 0; len <= 64; len++) {
            bytes memory data = _fill(len);
            bytes memory code = ClonesWithImmutableArgs.getCreationBytecode(
                implementation,
                data
            );
            assertEq(code.length, 0x41 + len + 2, "creation size");
            for (uint256 i = 0; i < len; i++) {
                assertEq(
                    uint256(uint8(code[0x41 + i])),
                    uint256(uint8(data[i])),
                    "appended data mismatch"
                );
            }
        }
    }

    /// -----------------------------------------------------------------------
    /// Arg reading
    /// -----------------------------------------------------------------------

    function test_getArgUint256Array_readsArrayAndNeighbours(
        address head,
        uint64 tail,
        uint8 rawLen
    ) public {
        uint64 arrLen = uint64(rawLen % 8);
        uint256[] memory expected = new uint256[](arrLen);
        bytes memory packed = abi.encodePacked(head);
        for (uint64 i = 0; i < arrLen; i++) {
            expected[i] = uint256(keccak256(abi.encode(head, i)));
            packed = abi.encodePacked(packed, expected[i]);
        }
        packed = abi.encodePacked(packed, tail);

        ArrayClone clone = ArrayClone(
            ClonesWithImmutableArgs.clone(implementation, packed)
        );

        // the args on either side must still line up, which catches an offset
        // mistake in the array read
        assertEq(clone.head(), head, "head");
        assertEq(uint256(clone.tail(arrLen)), uint256(tail), "tail");

        uint256[] memory got = clone.arr(arrLen);
        assertEq(got.length, uint256(arrLen), "array length");
        for (uint64 i = 0; i < arrLen; i++) {
            assertEq(got[i], expected[i], "array element");
        }
    }

    function test_getArgUint256Array_emptyArray() public {
        bytes memory packed = abi.encodePacked(address(this), uint64(7));
        ArrayClone clone = ArrayClone(
            ClonesWithImmutableArgs.clone(implementation, packed)
        );

        assertEq(clone.arr(0).length, 0);
        assertEq(clone.head(), address(this));
        assertEq(uint256(clone.tail(0)), 7);
    }

    /// @dev Reading more elements than were packed does not revert: it runs off
    ///      the end of the args and reads the 2 byte length suffix the proxy
    ///      appends, then zero padding past the end of calldata. Pinned because
    ///      it is easy to change accidentally when swapping calldataload for
    ///      calldatacopy, and because callers may rely on it not reverting.
    function test_getArgUint256Array_readingPastEndReadsSuffixThenZeroPads()
        public
    {
        bytes memory packed = abi.encodePacked(address(this), uint256(42));
        assertEq(packed.length, 52);
        ArrayClone clone = ArrayClone(
            ClonesWithImmutableArgs.clone(implementation, packed)
        );

        uint256[] memory got = clone.arr(3);
        assertEq(got.length, 3);
        // the packed element
        assertEq(got[0], 42);
        // the length suffix (uint16(52)), left aligned, then past end of calldata
        assertEq(got[1], uint256(52) << 240);
        // entirely past the end of calldata
        assertEq(got[2], 0);
    }

    /// @dev End to end version of the bytecode boundary test: a deployed clone
    ///      must read back every arg for arg blobs either side of a word.
    function test_argsRoundTripAcrossWordBoundaries() public {
        for (uint64 arrLen = 0; arrLen < 4; arrLen++) {
            bytes memory packed = abi.encodePacked(address(uint160(arrLen + 1)));
            for (uint64 i = 0; i < arrLen; i++) {
                packed = abi.encodePacked(packed, uint256(i + 100));
            }
            packed = abi.encodePacked(packed, uint64(arrLen + 900));

            ArrayClone clone = ArrayClone(
                ClonesWithImmutableArgs.clone(implementation, packed)
            );

            assertEq(clone.head(), address(uint160(arrLen + 1)));
            assertEq(uint256(clone.tail(arrLen)), uint256(arrLen + 900));
            uint256[] memory got = clone.arr(arrLen);
            for (uint64 i = 0; i < arrLen; i++) {
                assertEq(got[i], uint256(i + 100));
            }
        }
    }

    /// -----------------------------------------------------------------------
    /// Failure mode
    /// -----------------------------------------------------------------------

    /// @dev clone2 hardcodes the CREATE2 salt to 0, so redeploying the same
    ///      implementation and data from the same deployer reverts. Pins the
    ///      exact selector, since the revert is raised from assembly.
    function test_RevertWhen_clone2DataIsReused() public {
        bytes memory packed = abi.encodePacked(address(this), uint64(1));
        harness.clone2(implementation, packed);

        hevm.expectRevert(ClonesWithImmutableArgs.CreateFail.selector);
        harness.clone2(implementation, packed);
    }

    /// -----------------------------------------------------------------------
    /// Helpers
    /// -----------------------------------------------------------------------

    function _fill(uint256 len) internal pure returns (bytes memory out) {
        out = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            out[i] = bytes1(uint8(i % 256));
        }
    }
}
