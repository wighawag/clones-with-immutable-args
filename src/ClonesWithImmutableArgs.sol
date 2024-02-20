// SPDX-License-Identifier: BSD

pragma solidity ^0.8.4;

/// @title ClonesWithImmutableArgs
/// @author wighawag, zefram.eth, nick.eth
/// @notice Enables creating clone contracts with immutable args
library ClonesWithImmutableArgs {
    /// @dev The CREATE3 proxy bytecode.
    uint256 private constant _CREATE3_PROXY_BYTECODE =
        0x67363d3d37363d34f03d5260086018f3;

    /// @dev Hash of the `_CREATE3_PROXY_BYTECODE`.
    /// Equivalent to `keccak256(abi.encodePacked(hex"67363d3d37363d34f03d5260086018f3"))`.
    bytes32 private constant _CREATE3_PROXY_BYTECODE_HASH =
        0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f;

    error CreateFail();
    error InitializeFail();

    enum CloneType {
        CREATE,
        CREATE2,
        PREDICT_CREATE2
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return instance The address of the created clone
    function clone(
        address implementation,
        bytes memory data
    ) internal returns (address payable instance) {
        return clone(implementation, data, 0);
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @param value The amount of wei to transfer to the created clone
    /// @return instance The address of the created clone
    function clone(
        address implementation,
        bytes memory data,
        uint256 value
    ) internal returns (address payable instance) {
        bytes memory creationcode = getCreationBytecode(implementation, data);
        // solhint-disable-next-line no-inline-assembly
        assembly {
            instance := create(
                value,
                add(creationcode, 0x20),
                mload(creationcode)
            )
        }
        if (instance == address(0)) {
            revert CreateFail();
        }
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args,
    ///         using CREATE2
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return instance The address of the created clone
    function clone2(
        address implementation,
        bytes memory data
    ) internal returns (address payable instance) {
        return clone2(implementation, data, 0);
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args,
    ///         using CREATE2
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @param value The amount of wei to transfer to the created clone
    /// @return instance The address of the created clone
    function clone2(
        address implementation,
        bytes memory data,
        uint256 value
    ) internal returns (address payable instance) {
        bytes memory creationcode = getCreationBytecode(implementation, data);
        // solhint-disable-next-line no-inline-assembly
        assembly {
            instance := create2(
                value,
                add(creationcode, 0x20),
                mload(creationcode),
                0
            )
        }
        if (instance == address(0)) {
            revert CreateFail();
        }
    }

    /// @notice Computes the address of a clone created using CREATE2
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return instance The address of the clone
    function addressOfClone2(
        address implementation,
        bytes memory data
    ) internal view returns (address payable instance) {
        bytes memory creationcode = getCreationBytecode(implementation, data);
        bytes32 bytecodeHash = keccak256(creationcode);
        instance = payable(
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                bytes32(0),
                                bytecodeHash
                            )
                        )
                    )
                )
            )
        );
    }

    /// @notice Computes bytecode for a clone
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return ret Creation bytecode for the clone contract
    function getCreationBytecode(
        address implementation,
        bytes memory data
    ) internal pure returns (bytes memory ret) {
        // unrealistic for memory ptr or data length to exceed 256 bits
        unchecked {
            uint256 extraLength = data.length + 2; // +2 bytes for telling how much data there is appended to the call
            uint256 creationSize = 0x41 + extraLength;
            uint256 runSize = creationSize - 10;
            uint256 dataPtr;
            uint256 ptr;

            // solhint-disable-next-line no-inline-assembly
            assembly {
                ret := mload(0x40)
                mstore(ret, creationSize)
                mstore(0x40, add(ret, creationSize))
                ptr := add(ret, 0x20)

                // -------------------------------------------------------------------------------------------------------------
                // CREATION (10 bytes)
                // -------------------------------------------------------------------------------------------------------------

                // 61 runtime  | PUSH2 runtime (r)     | r                             | –
                mstore(
                    ptr,
                    0x6100000000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x01), shl(240, runSize)) // size of the contract running bytecode (16 bits)

                // creation size = 0a
                // 3d          | RETURNDATASIZE        | 0 r                           | –
                // 81          | DUP2                  | r 0 r                         | –
                // 60 creation | PUSH1 creation (c)    | c r 0 r                       | –
                // 3d          | RETURNDATASIZE        | 0 c r 0 r                     | –
                // 39          | CODECOPY              | 0 r                           | [0-runSize): runtime code
                // f3          | RETURN                |                               | [0-runSize): runtime code

                // -------------------------------------------------------------------------------------------------------------
                // RUNTIME (55 bytes + extraLength)
                // -------------------------------------------------------------------------------------------------------------

                // 3d          | RETURNDATASIZE        | 0                             | –
                // 3d          | RETURNDATASIZE        | 0 0                           | –
                // 3d          | RETURNDATASIZE        | 0 0 0                         | –
                // 3d          | RETURNDATASIZE        | 0 0 0 0                       | –
                // 36          | CALLDATASIZE          | cds 0 0 0 0                   | –
                // 3d          | RETURNDATASIZE        | 0 cds 0 0 0 0                 | –
                // 3d          | RETURNDATASIZE        | 0 0 cds 0 0 0 0               | –
                // 37          | CALLDATACOPY          | 0 0 0 0                       | [0, cds) = calldata
                // 61          | PUSH2 extra           | extra 0 0 0 0                 | [0, cds) = calldata
                mstore(
                    add(ptr, 0x03),
                    0x3d81600a3d39f33d3d3d3d363d3d376100000000000000000000000000000000
                )
                mstore(add(ptr, 0x13), shl(240, extraLength))

                // 60 0x37     | PUSH1 0x37            | 0x37 extra 0 0 0 0            | [0, cds) = calldata // 0x37 (55) is runtime size - data
                // 36          | CALLDATASIZE          | cds 0x37 extra 0 0 0 0        | [0, cds) = calldata
                // 39          | CODECOPY              | 0 0 0 0                       | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 36          | CALLDATASIZE          | cds 0 0 0 0                   | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 61 extra    | PUSH2 extra           | extra cds 0 0 0 0             | [0, cds) = calldata, [cds, cds+extra) = extraData
                mstore(
                    add(ptr, 0x15),
                    0x6037363936610000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x1b), shl(240, extraLength))

                // 01          | ADD                   | cds+extra 0 0 0 0             | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 3d          | RETURNDATASIZE        | 0 cds+extra 0 0 0 0           | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 73 addr     | PUSH20 0x123…         | addr 0 cds+extra 0 0 0 0      | [0, cds) = calldata, [cds, cds+extra) = extraData
                mstore(
                    add(ptr, 0x1d),
                    0x013d730000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x20), shl(0x60, implementation))

                // 5a          | GAS                   | gas addr 0 cds+extra 0 0 0 0  | [0, cds) = calldata, [cds, cds+extra) = extraData
                // f4          | DELEGATECALL          | success 0 0                   | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 3d          | RETURNDATASIZE        | rds success 0 0               | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 3d          | RETURNDATASIZE        | rds rds success 0 0           | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 93          | SWAP4                 | 0 rds success 0 rds           | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 80          | DUP1                  | 0 0 rds success 0 rds         | [0, cds) = calldata, [cds, cds+extra) = extraData
                // 3e          | RETURNDATACOPY        | success 0 rds                 | [0, rds) = return data (there might be some irrelevant leftovers in memory [rds, cds+0x37) when rds < cds+0x37)
                // 60 0x35     | PUSH1 0x35            | 0x35 sucess 0 rds             | [0, rds) = return data
                // 57          | JUMPI                 | 0 rds                         | [0, rds) = return data
                // fd          | REVERT                | –                             | [0, rds) = return data
                // 5b          | JUMPDEST              | 0 rds                         | [0, rds) = return data
                // f3          | RETURN                | –                             | [0, rds) = return data
                mstore(
                    add(ptr, 0x34),
                    0x5af43d3d93803e603557fd5bf300000000000000000000000000000000000000
                )
            }

            // -------------------------------------------------------------------------------------------------------------
            // APPENDED DATA (Accessible from extcodecopy)
            // (but also send as appended data to the delegatecall)
            // -------------------------------------------------------------------------------------------------------------

            extraLength -= 2;
            uint256 counter = extraLength;
            uint256 copyPtr = ptr + 0x41;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                dataPtr := add(data, 32)
            }
            for (; counter >= 32; counter -= 32) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    mstore(copyPtr, mload(dataPtr))
                }

                copyPtr += 32;
                dataPtr += 32;
            }
            uint256 mask = ~(256 ** (32 - counter) - 1);
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, and(mload(dataPtr), mask))
            }
            copyPtr += counter;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, shl(240, extraLength))
            }
        }
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args. Uses CREATE3
    /// to implement deterministic deployment.
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @param salt The salt used by the CREATE3 deployment
    /// @return deployed The address of the created clone
    function clone3(
        address implementation,
        bytes memory data,
        bytes32 salt
    ) internal returns (address deployed) {
        return clone3(implementation, data, salt, 0);
    }

    /// @notice Creates a clone proxy of the implementation contract, with immutable args. Uses CREATE3
    /// to implement deterministic deployment.
    /// @dev data cannot exceed 65535 bytes, since 2 bytes are used to store the data length
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @param salt The salt used by the CREATE3 deployment
    /// @param value The amount of wei to transfer to the created clone
    /// @return deployed The address of the created clone
    function clone3(
        address implementation,
        bytes memory data,
        bytes32 salt,
        uint256 value
    ) internal returns (address deployed) {
        // unrealistic for memory ptr or data length to exceed 256 bits
        unchecked {
            uint256 extraLength = data.length + 2; // +2 bytes for telling how much data there is appended to the call
            uint256 creationSize = 0x43 + extraLength;
            uint256 ptr;
            // solhint-disable-next-line no-inline-assembly
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
                mstore(add(ptr, 0x02), shl(240, sub(creationSize, 11))) // size of the contract running bytecode (16 bits)

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
                // 61          | PUSH2 extra           | extra                   | [0, cds] = calldata
                mstore(
                    add(ptr, 0x0b),
                    0x363d3d3761000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x10), shl(240, extraLength))

                // 60 0x38     | PUSH1 0x38            | 0x38 extra              | [0, cds] = calldata // 0x38 (56) is runtime size - data
                // 36          | CALLDATASIZE          | cds 0x38 extra          | [0, cds] = calldata
                // 39          | CODECOPY              | _                       | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0                       | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0 0                     | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0 0 0                   | [0, cds] = calldata
                // 36          | CALLDATASIZE          | cds 0 0 0               | [0, cds] = calldata
                // 61 extra    | PUSH2 extra           | extra cds 0 0 0         | [0, cds] = calldata
                mstore(
                    add(ptr, 0x12),
                    0x603836393d3d3d36610000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x1b), shl(240, extraLength))

                // 01          | ADD                   | cds+extra 0 0 0         | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | 0 cds 0 0 0             | [0, cds] = calldata
                // 73 addr     | PUSH20 0x123…         | addr 0 cds 0 0 0        | [0, cds] = calldata
                mstore(
                    add(ptr, 0x1d),
                    0x013d730000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x20), shl(0x60, implementation))

                // 5a          | GAS                   | gas addr 0 cds 0 0 0    | [0, cds] = calldata
                // f4          | DELEGATECALL          | success 0               | [0, cds] = calldata
                // 3d          | RETURNDATASIZE        | rds success 0           | [0, cds] = calldata
                // 82          | DUP3                  | 0 rds success 0         | [0, cds] = calldata
                // 80          | DUP1                  | 0 0 rds success 0       | [0, cds] = calldata
                // 3e          | RETURNDATACOPY        | success 0               | [0, rds] = return data (there might be some irrelevant leftovers in memory [rds, cds] when rds < cds)
                // 90          | SWAP1                 | 0 success               | [0, rds] = return data
                // 3d          | RETURNDATASIZE        | rds 0 success           | [0, rds] = return data
                // 91          | SWAP2                 | success 0 rds           | [0, rds] = return data
                // 60 0x36     | PUSH1 0x36            | 0x36 sucess 0 rds       | [0, rds] = return data
                // 57          | JUMPI                 | 0 rds                   | [0, rds] = return data
                // fd          | REVERT                | –                       | [0, rds] = return data
                // 5b          | JUMPDEST              | 0 rds                   | [0, rds] = return data
                // f3          | RETURN                | –                       | [0, rds] = return data

                mstore(
                    add(ptr, 0x34),
                    0x5af43d82803e903d91603657fd5bf30000000000000000000000000000000000
                )
            }

            // -------------------------------------------------------------------------------------------------------------
            // APPENDED DATA (Accessible from extcodecopy)
            // (but also send as appended data to the delegatecall)
            // -------------------------------------------------------------------------------------------------------------

            extraLength -= 2;
            uint256 counter = extraLength;
            uint256 copyPtr = ptr + 0x43;
            uint256 dataPtr;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                dataPtr := add(data, 32)
            }
            for (; counter >= 32; counter -= 32) {
                // solhint-disable-next-line no-inline-assembly
                assembly {
                    mstore(copyPtr, mload(dataPtr))
                }

                copyPtr += 32;
                dataPtr += 32;
            }
            uint256 mask = ~(256 ** (32 - counter) - 1);
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, and(mload(dataPtr), mask))
            }
            copyPtr += counter;
            // solhint-disable-next-line no-inline-assembly
            assembly {
                mstore(copyPtr, shl(240, extraLength))
            }

            /// @solidity memory-safe-assembly
            // solhint-disable-next-line no-inline-assembly
            assembly {
                // Store the `_PROXY_BYTECODE` into scratch space.
                mstore(0x00, _CREATE3_PROXY_BYTECODE)
                // Deploy a new contract with our pre-made bytecode via CREATE2.
                let proxy := create2(0, 0x10, 0x10, salt)

                // If the result of `create2` is the zero address, revert.
                if iszero(proxy) {
                    // Store the function selector of `CreateFail()`.
                    mstore(0x00, 0xebfef188)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }

                // Store the proxy's address.
                mstore(0x14, proxy)
                // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
                // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
                mstore(0x00, 0xd694)
                // Nonce of the proxy contract (1).
                mstore8(0x34, 0x01)

                deployed := and(
                    keccak256(0x1e, 0x17),
                    0xffffffffffffffffffffffffffffffffffffffff
                )

                // If the `call` fails or the code size of `deployed` is zero, revert.
                // The second argument of the or() call is evaluated first, which is important
                // here because extcodesize(deployed) is only non-zero after the call() to the proxy
                // is made and the contract is successfully deployed.
                if or(
                    iszero(extcodesize(deployed)),
                    iszero(
                        call(
                            gas(), // Gas remaining.
                            proxy, // Proxy's address.
                            value, // Ether value.
                            ptr, // Pointer to the creation code
                            creationSize, // Size of the creation code
                            0x00, // Offset of output.
                            0x00 // Length of output.
                        )
                    )
                ) {
                    // Store the function selector of `InitializeFail()`.
                    mstore(0x00, 0x8f86d2f1)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @notice Returns the CREATE3 deterministic address of the contract deployed via cloneDeterministic().
    /// @dev Forked from https://github.com/Vectorized/solady/blob/main/src/utils/CREATE3.sol
    /// @param salt The salt used by the CREATE3 deployment
    function addressOfClone3(
        bytes32 salt
    ) internal view returns (address deployed) {
        /// @solidity memory-safe-assembly
        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Cache the free memory pointer.
            let m := mload(0x40)
            // Store `address(this)`.
            mstore(0x00, address())
            // Store the prefix.
            mstore8(0x0b, 0xff)
            // Store the salt.
            mstore(0x20, salt)
            // Store the bytecode hash.
            mstore(0x40, _CREATE3_PROXY_BYTECODE_HASH)

            // Store the proxy's address.
            mstore(0x14, keccak256(0x0b, 0x55))
            // Restore the free memory pointer.
            mstore(0x40, m)
            // 0xd6 = 0xc0 (short RLP prefix) + 0x16 (length of: 0x94 ++ proxy ++ 0x01).
            // 0x94 = 0x80 + 0x14 (0x14 = the length of an address, 20 bytes, in hex).
            mstore(0x00, 0xd694)
            // Nonce of the proxy contract (1).
            mstore8(0x34, 0x01)

            deployed := and(
                keccak256(0x1e, 0x17),
                0xffffffffffffffffffffffffffffffffffffffff
            )
        }
    }
}
