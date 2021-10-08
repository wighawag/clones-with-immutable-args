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
        uint256 csize = Utils.codeSize(address(this)); //renove duplicate call of codeSize
        return Utils.codeAtLen(address(this), 45, csize - 45);
    }

    function getDataWithCallDataProvision() external view returns (bytes memory) {
        uint256 csize = Utils.codeSize(address(this)); //renove duplicate call of codeSize
        return Utils.codeAtLen(address(this), 56, csize - 2 - 56);
    }
    

    function getAppendedCallData() external pure returns (bytes memory data) {
        uint256 length;
        assembly {
            length := shr(240, calldataload(sub(calldatasize(), 2)))
        } 
        return msg.data[msg.data.length - (length+2):msg.data.length-2];
    }
} 
