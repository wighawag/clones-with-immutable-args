// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ClonesWithImmutableArgs.sol";
import "./ClonesWithCallData.sol";
import "./Utils.sol";


contract Template is ClonesWithImmutableArgs, ClonesWithCallData {

    event Cloned(Template clone, bytes data);

    function clone1(bytes calldata data) external returns (Template clonedGreeter) {
        clonedGreeter = Template(ClonesWithImmutableArgs.clone(address(this), data));
        emit Cloned(clonedGreeter, data);
    }

    function clone2(bytes calldata data) external returns (Template clonedGreeter) {
        clonedGreeter = Template(ClonesWithCallData.cloneWithCallDataProvision(address(this), data));
        emit log_address(address(clonedGreeter));
        emit Cloned(clonedGreeter, data);
    }

    function hello() external pure returns (bytes memory) {
        return "hello";
    }

    function getData() external view returns (bytes memory) {
        return Utils.codeAt(address(this), 45, type(uint256).max);
    }

    function getDataWithCallDataProvision() external view returns (bytes memory) {
        return Utils.codeAt(address(this), 56, type(uint256).max);
    }

    function getAppendedCallData() external returns (bytes memory data) {

        emit log_named_bytes("msg.data", msg.data);

        uint256 length;
        assembly {
            length := shr(240, calldataload(sub(calldatasize(), 2)))
        }
        emit log_named_bytes32("length", bytes32(length));

        // uint16 length;
        // assembly {
        //     length := shr(240, calldataload(sub(calldatasize(), 2)))
        // }
        emit log_named_uint("length", length);
        length += 2;
        emit log_named_uint("length", length);
        
        return msg.data[msg.data.length - length:msg.data.length-2];
    }
} 

// 0x0010000000000000000000000000000000000000000000000000000000000000
// 0xf45e108e6473616c646a206173646b61736a646b6c736168666b206a68646a6b68736173616a68646a736168646a6b73616864206a6b73616a646873616a646b73616a64682073616a6468616b73206b6a617368646b6a61682073646a736168646a736168646a6b73616820646a6b6873616a64206873616a646873616a64687361206a6468736a6164686a73612064686a736168646a207368646a73616820646a6b736168646a736168206473616a646873616a64686b6a617368646a73612064686a73616864206a7368646a73616820646a73616864206a736168646a736168646a73616864206a736168646a736120686473616a6864206a736168646a736168646a207364686a617368646a20736168646a616b732068646a736168646a73612068646a736168646a736168646a736168646a687361206a646873616a64686b6a617368646b6a206173686a646b6873616a646861736a64686a61207373616420617368646a736168646a7361686a646873616a646873616a646873616b68646a736168646a6b736168646a6b687361200190