// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "ds-test/test.sol";

contract ClonesWithArgs is DSTest {


    /*
        36	    | CALLDATASIZE	        | cds	                    | –
        3d  	| RETURNDATASIZE	    | 0 cds	                    | –
        3d	    | RETURNDATASIZE	    | 0 0 cds	                | –
        37	    | CALLDATACOPY	        | –                         | [0, cds] = calldata
    */
    // bytes4 copyCallData = 0x363d3d37;

    /*
        3d	    | RETURNDATASIZE	    | 0	                        | [0, cds] = calldata
        3d	    | RETURNDATASIZE	    | 0 0	                    | [0, cds] = calldata
        3d	    | RETURNDATASIZE	    | 0 0 0	                    | [0, cds] = calldata
        36	    | CALLDATASIZE	        | cds 0 0 0	                | [0, cds] = calldata
        3d	    | RETURNDATASIZE	    | 0 cds 0 0 0	            | [0, cds] = calldata
        73 addr	| PUSH20 0x123…	        | addr 0 cds 0 0 0	        | [0, cds] = calldata
        5a	    | GAS	                | gas addr 0 cds 0 0 0	    | [0, cds] = calldata
        f4	    | DELEGATECALL	        |success 0	                | [0, cds] = calldata
    */
    // bytes6 delegateCall = 0x3d3d3d363d73; //<Address>
    // bytes2 actualCall = 0x5af4;


    // CREATION 

    /*
        3d      | RETURNDATASIZE        | 0	                        | –
        60 2d	| PUSH1 2d              | 2d 0	                    | –
        80	    | DUP1	                | 2d 2d 0	                | –
        60 0a	| PUSH1 0a	            | 0a 2d 2d 0	            | –
        3d	    | RETURNDATASIZE	    | 0 0a 2d 2d 0	            | –
        39	    | CODECOPY	            | 2d 0	                    | [0-2d]: runtime code
    */

    /*
        81	    | DUP2                  | 0 2d 0                    | [0-2d]: runtime code
        f3	    | RETURN                | 0	                        | [0-2d]: runtime code
    */


    //363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
    function clone(address implementation) internal returns (address instance) {
         assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }





    // --------------------------------------------------------------------------------------------------
    // NEW
    // --------------------------------------------------------------------------------------------------

     /*
        36	    | CALLDATASIZE	        | cds	                    | –
        3d  	| RETURNDATASIZE	    | 0 cds	                    | –
        3d	    | RETURNDATASIZE	    | 0 0 cds	                | –
        37	    | CALLDATACOPY	        | –                         | [0, cds] = calldata
    */
    // bytes4 copyCallData2 = 0x363d3d37;


    /* TODO loop over 32 bytes chunk
        7F data | PUSH32  0x123...      | data          	        | [0, cds] = calldata
        36      | CALLDATASIZE	        | cds data                  | [0, cds] = data   // TODO use DUP above to get that already in, without calling CALLDATASIZE again
        52      | MSTORE                | _                         | [0, cds + 0x20] = data
    */
    // bytes1 pushImmutable2 = 0x7f; // <data>
    // bytes2 mstoreImmutable2 = 0x3652;

    /*
        3d	    | RETURNDATASIZE	    | 0	                        | [0, cds + 0x20] = data
        3d	    | RETURNDATASIZE	    | 0 0	                    | [0, cds + 0x20] = data
        3d	    | RETURNDATASIZE	    | 0 0 0	                    | [0, cds + 0x20] = data
        36	    | CALLDATASIZE	        | cds 0 0 0	                | [0, cds + 0x20] = data
        7F 0x20 | PUSH25 0x20           | 0x20 cds 0 0 0            | [0, cds + 0x20] = data
        01      | ADD                   | cds+0x20 0 0 0            | [0, cds + 0x20] = data
        3d	    | RETURNDATASIZE	    | 0 cds+0x20 0 0 0	        | [0, cds + 0x20] = data
        73 addr	| PUSH20 0x123…	        | addr 0 cds+0x20 0 0 0	    | [0, cds + 0x20] = data
        5a	    | GAS	                | gas addr 0 cds+0x20 0 0 0	| [0, cds + 0x20] = data
        f4	    | DELEGATECALL	        | success 0	                | [0, cds + 0x20] = data
    */

    // bytes6 delegateCall2 = 0x3d3d3d367f00000000000000000000000000000000000000000000000000013d73; //<Address>
    // bytes2 actualCall2 = 0x5af4;


    // TODO
    // CREATION 

    /*
        3d      | RETURNDATASIZE        | 0	                        | –
        60 2d	| PUSH1 2d              | 2d 0	                    | –
        80	    | DUP1	                | 2d 2d 0	                | –
        60 0a	| PUSH1 0a	            | 0a 2d 2d 0	            | –
        3d	    | RETURNDATASIZE	    | 0 0a 2d 2d 0	            | –
        39	    | CODECOPY	            | 2d 0	                    | [0-2d]: runtime code
    */

    /*
        81	    | DUP2                  | 0 2d 0                    | [0-2d]: runtime code
        f3	    | RETURN                | 0	                        | [0-2d]: runtime code
    */


    function clone2(address implementation, bytes memory data) internal returns (address instance) {

        uint256 mLength = data.length / 32;
        uint256 mSize = mLength * 32;

        uint256 size = 75 + mLength * 32;
        uint256 jumpPos = size - 2;
        uint256 all = size + 10;
        uint256 ptr;
        uint256 movePtr;

        emit log_named_uint("mLength", mLength);
        emit log_named_uint("mSize", mSize);
        emit log_named_uint("size", size);
        emit log_named_uint("jumpPos", jumpPos);
        emit log_named_uint("all", all);
        assembly {
            ptr := mload(0x40)
            movePtr:= ptr

            // CREATION 
            /*
                3d      | RETURNDATASIZE        | 0	                        | –
                60 2d	| PUSH1 2d              | 2d 0	                    | –
                80	    | DUP1	                | 2d 2d 0	                | –
                60 0a	| PUSH1 0a	            | 0a 2d 2d 0	            | –
                3d	    | RETURNDATASIZE	    | 0 0a 2d 2d 0	            | –
                39	    | CODECOPY	            | 2d 0	                    | [0-2d]: runtime code
            */
            /*
                81	    | DUP2                  | 0 2d 0                    | [0-2d]: runtime code
                f3	    | RETURN                | 0	                        | [0-2d]: runtime code
            */

            // mstore(ptr, 0x3d60XX80600a3d3981f3363d3d377f0000000000000000000000000000000000)
            mstore(movePtr, 0x3d60000000000000000000000000000000000000000000000000000000000000)
            mstore(add(movePtr, 0x02), shl(248, size)) // size of the contract running bytecode :  TODO support bigger
            mstore(add(movePtr, 0x03), 0x80600a3d3981f300000000000000000000000000000000000000000000000000)


            /*
                36	    | CALLDATASIZE	        | cds	                    | –
                3d  	| RETURNDATASIZE	    | 0 cds	                    | –
                3d	    | RETURNDATASIZE	    | 0 0 cds	                | –
                37	    | CALLDATACOPY	        | –                         | [0, cds] = calldata
            */
            /* TODO loop over 32 bytes chunk
                7F data | PUSH32  0x123...      | data          	        | [0, cds] = calldata
                36      | CALLDATASIZE	        | cds data                  | [0, cds] = data   // TODO use DUP above to get that already in, without calling CALLDATASIZE again
                52      | MSTORE                | _                         | [0, cds + 0x20] = data
            */
            mstore(add(movePtr, 0x0a), 0x363d3d377f000000000000000000000000000000000000000000000000000000)
        }

       
        // assembly {
        //     mstore(add(movePtr, 0xf), mLength)
        // }
        // for (uint256 i = 0; i < mLength; i++) {
            uint256 i = 0;
            uint256 dataOffset = (i) * 32;
            movePtr += (i * 32) + 15;
            assembly {
                let chunk := mload(add(data, dataOffset))
                // TODO clean chunk if not multiple of 32 bytes
                mstore(movePtr, chunk)
            }
        // }

        assembly {
            mstore(add(movePtr, 0x20), 0x3652000000000000000000000000000000000000000000000000000000000000)

            /*
                3d	    | RETURNDATASIZE	    | 0	                        | [0, cds + 0x20] = data
                3d	    | RETURNDATASIZE	    | 0 0	                    | [0, cds + 0x20] = data
                3d	    | RETURNDATASIZE	    | 0 0 0	                    | [0, cds + 0x20] = data
                36	    | CALLDATASIZE	        | cds 0 0 0	                | [0, cds + 0x20] = data
                78 0x20 | PUSH25 0x20           | 0x20 cds 0 0 0            | [0, cds + 0x20] = data
                01      | ADD                   | cds+0x20 0 0 0            | [0, cds + 0x20] = data
                3d	    | RETURNDATASIZE	    | 0 cds+0x20 0 0 0	        | [0, cds + 0x20] = data
                73 addr	| PUSH20 0x123…	        | addr 0 cds+0x20 0 0 0	    | [0, cds + 0x20] = data
                5a	    | GAS	                | gas addr 0 cds+0x20 0 0 0	| [0, cds + 0x20] = data
                f4	    | DELEGATECALL	        | success 0	                | [0, cds + 0x20] = data
            */
            
            mstore(add(movePtr, 0x31), 0x3d3d3d3678000000000000000000000000000000000000000000000000000000)
            // write data size
            mstore(add(movePtr, 0x36), shl(0x38, mSize)) // 0x38 = 7 * 8bits
            
            mstore(add(movePtr, 0x4f), 0x013d730000000000000000000000000000000000000000000000000000000000)
            mstore(add(movePtr, 0x52), shl(0x60, implementation))

            // mstore(add(ptr, 0x66), 0x5af43d82803e903d9160XX57fd5bf30000000000000000000000000000000000)
            mstore(add(movePtr, 0x66), 0x5af4000000000000000000000000000000000000000000000000000000000000)

            /* Get the result of an external call
                3d	    | RETURNDATASIZE	    | rds success 0	            | [0, cds] = calldata
                82	    | DUP3	                | 0 rds success 0	        | [0, cds] = calldata
                80	    | DUP1	                | 0 0 rds success 0	        | [0, cds] = calldata
                3e	    | RETURNDATACOPY    	| success 0	                | [0, rds] = return data (there might be some irrelevant leftovers in memory [rds, cds] when rds < cds)
            */
            /* Final stage: return or revert
                90	    | SWAP1	                | 0 success	                | [0, rds] = return data
                3d	    | RETURNDATASIZE        | rds 0 success	            | [0, rds] = return data
                91      | SWAP2	                | success 0 rds	            | [0, rds] = return data
                60 dest	| PUSH1 dest            | dest sucess 0 rds	        | [0, rds] = return data
                57	    | JUMPI	                | 0 rds	                    | [0, rds] = return data
            */
            /*
                fd	    | REVERT	            | –	                        | [0, rds] = return data
                5b	    | JUMPDEST	            | 0 rds	                    | [0, rds] = return data
                f3	    | RETURN	            | –	                        | [0, rds] = return data
            */
            mstore(add(movePtr, 0x68), 0x3d82803e903d9160000000000000000000000000000000000000000000000000)
            mstore(add(movePtr, 0x70), shl(248, jumpPos)) // position of return opcodes // TODO support bigger
            mstore(add(movePtr, 0x71), 0x57fd5bf300000000000000000000000000000000000000000000000000000000) 

            instance := create(0, ptr, all)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function clone3(address implementation, bytes memory data) internal returns (address instance) {

        uint256 mLength = data.length / 32;
        uint256 mSize = mLength * 32;

        uint256 size = 75 + mLength * 32;
        uint256 jumpPos = size - 2;
        uint256 all = size + 10;
        uint256 ptr;
        uint256 movePtr;

        emit log_named_uint("mLength", mLength);
        emit log_named_uint("mSize", mSize);
        emit log_named_uint("size", size);
        emit log_named_uint("jumpPos", jumpPos);
        emit log_named_uint("all", all);
        assembly {
            ptr := mload(0x40)
            movePtr:= ptr

            // CREATION 
            /*
                3d      | RETURNDATASIZE        | 0	                        | –
                60 2d	| PUSH1 2d              | 2d 0	                    | –
                80	    | DUP1	                | 2d 2d 0	                | –
                60 0a	| PUSH1 0a	            | 0a 2d 2d 0	            | –
                3d	    | RETURNDATASIZE	    | 0 0a 2d 2d 0	            | –
                39	    | CODECOPY	            | 2d 0	                    | [0-2d]: runtime code
            */
            /*
                81	    | DUP2                  | 0 2d 0                    | [0-2d]: runtime code
                f3	    | RETURN                | 0	                        | [0-2d]: runtime code
            */

            // mstore(ptr, 0x3d60XX80600a3d3981f3363d3d377f0000000000000000000000000000000000)
            mstore(movePtr, 0x3d60000000000000000000000000000000000000000000000000000000000000)
            mstore(add(movePtr, 0x02), shl(248, size)) // size of the contract running bytecode :  TODO support bigger
            mstore(add(movePtr, 0x03), 0x80600a3d3981f300000000000000000000000000000000000000000000000000)


            /*
                36	    | CALLDATASIZE	        | cds	                    | –
                3d  	| RETURNDATASIZE	    | 0 cds	                    | –
                3d	    | RETURNDATASIZE	    | 0 0 cds	                | –
                37	    | CALLDATACOPY	        | –                         | [0, cds] = calldata
            */
            /* TODO loop over 32 bytes chunk
                7F data | PUSH32  0x123...      | data          	        | [0, cds] = calldata
                36      | CALLDATASIZE	        | cds data                  | [0, cds] = data   // TODO use DUP above to get that already in, without calling CALLDATASIZE again
                52      | MSTORE                | _                         | [0, cds + 0x20] = data
            */
            mstore(add(movePtr, 0x0a), 0x363d3d377f000000000000000000000000000000000000000000000000000000)
        }

       
        // assembly {
        //     mstore(add(movePtr, 0xf), mLength)
        // }
        // for (uint256 i = 0; i < mLength; i++) {
            uint256 i = 0;
            uint256 dataOffset = (i) * 32;
            movePtr += (i * 32) + 15;
            assembly {
                let chunk := mload(add(data, dataOffset))
                // TODO clean chunk if not multiple of 32 bytes
                mstore(movePtr, chunk)
            }
        // }

        assembly {
            mstore(add(movePtr, 0x20), 0x3652000000000000000000000000000000000000000000000000000000000000)

            /*
                3d	    | RETURNDATASIZE	    | 0	                        | [0, cds + 0x20] = data
                3d	    | RETURNDATASIZE	    | 0 0	                    | [0, cds + 0x20] = data
                3d	    | RETURNDATASIZE	    | 0 0 0	                    | [0, cds + 0x20] = data
                36	    | CALLDATASIZE	        | cds 0 0 0	                | [0, cds + 0x20] = data
                78 0x20 | PUSH25 0x20           | 0x20 cds 0 0 0            | [0, cds + 0x20] = data
                01      | ADD                   | cds+0x20 0 0 0            | [0, cds + 0x20] = data
                3d	    | RETURNDATASIZE	    | 0 cds+0x20 0 0 0	        | [0, cds + 0x20] = data
                73 addr	| PUSH20 0x123…	        | addr 0 cds+0x20 0 0 0	    | [0, cds + 0x20] = data
                5a	    | GAS	                | gas addr 0 cds+0x20 0 0 0	| [0, cds + 0x20] = data
                f4	    | DELEGATECALL	        | success 0	                | [0, cds + 0x20] = data
            */
            
            mstore(add(movePtr, 0x31), 0x3d3d3d3678000000000000000000000000000000000000000000000000000000)
            // write data size
            mstore(add(movePtr, 0x36), shl(0x38, mSize)) // 0x38 = 7 * 8bits
            
            mstore(add(movePtr, 0x4f), 0x013d730000000000000000000000000000000000000000000000000000000000)
            mstore(add(movePtr, 0x52), shl(0x60, implementation))

            // mstore(add(ptr, 0x66), 0x5af43d82803e903d9160XX57fd5bf30000000000000000000000000000000000)
            mstore(add(movePtr, 0x66), 0x5af4000000000000000000000000000000000000000000000000000000000000)

            /* Get the result of an external call
                3d	    | RETURNDATASIZE	    | rds success 0	            | [0, cds] = calldata
                82	    | DUP3	                | 0 rds success 0	        | [0, cds] = calldata
                80	    | DUP1	                | 0 0 rds success 0	        | [0, cds] = calldata
                3e	    | RETURNDATACOPY    	| success 0	                | [0, rds] = return data (there might be some irrelevant leftovers in memory [rds, cds] when rds < cds)
            */
            /* Final stage: return or revert
                90	    | SWAP1	                | 0 success	                | [0, rds] = return data
                3d	    | RETURNDATASIZE        | rds 0 success	            | [0, rds] = return data
                91      | SWAP2	                | success 0 rds	            | [0, rds] = return data
                60 dest	| PUSH1 dest            | dest sucess 0 rds	        | [0, rds] = return data
                57	    | JUMPI	                | 0 rds	                    | [0, rds] = return data
            */
            /*
                fd	    | REVERT	            | –	                        | [0, rds] = return data
                5b	    | JUMPDEST	            | 0 rds	                    | [0, rds] = return data
                f3	    | RETURN	            | –	                        | [0, rds] = return data
            */
            mstore(add(movePtr, 0x68), 0x3d82803e903d9160000000000000000000000000000000000000000000000000)
            mstore(add(movePtr, 0x70), shl(248, jumpPos)) // position of return opcodes // TODO support bigger
            mstore(add(movePtr, 0x71), 0x57fd5bf300000000000000000000000000000000000000000000000000000000) 

            instance := create(0, ptr, all)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
}
