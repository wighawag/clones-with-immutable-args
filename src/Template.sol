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

    function getAppendedCallData() external pure returns (bytes memory data) {
        uint256 length;
        assembly {
            length := calldataload(sub(calldatasize(), 32))
        }
        length += 32;
        assembly {
            data := calldataload(sub(calldatasize(), length))
        }
    }
}
