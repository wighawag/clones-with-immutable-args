// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library ClonesWithArgs {


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


    function clone2(address implementation, bytes32 data) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            
            // mstore(ptr, 0x3d60XX80600a3d3981f3363d3d377f0000000000000000000000000000000000)
            mstore(ptr, 0x3d60000000000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x02), 0x6e000000000000000000000000000000000000000000000000000000000000) // size of the contract running bytecode : 110 // TODO support bigger
            mstore(add(ptr, 0x03), 0x80600a3d3981f3363d3d377f00000000000000000000000000000000000000)
           
            // write data
            mstore(add(ptr, 0x0f), data)
            mstore(add(ptr, 0x2f), 0x36523d3d3d367f00000000000000000000000000000000000000000000000000)
            // write data size
            mstore(add(ptr, 0x3d), shl(0x0e, 32))
           
            mstore(add(ptr, 0x4f), 0x013d730000000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x55), shl(0x60, implementation))

            // mstore(add(ptr, 0x69), 0x5af43d82803e903d9160XX57fd5bf30000000000000000000000000000000000)
            mstore(add(ptr, 0x69), 0x5af43d82803e903d916000000000000000000000000000000000000000000000)
            mstore(add(ptr, 0x73), 0x6c00000000000000000000000000000000000000000000000000000000000000) // position of return opcodes // TODO support bigger
            mstore(add(ptr, 0x74), 0x57fd5bf300000000000000000000000000000000000000000000000000000000) 

            instance := create(0, ptr, 0x78)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
}
