// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ClonesWithImmutableArgs.sol";


contract Template is ClonesWithImmutableArgs {

    event Cloned(Template clone, bytes data);

    function clone(bytes calldata data) external returns (Template clonedGreeter) {
        clonedGreeter = Template(ClonesWithImmutableArgs.clone(address(this), data));
        emit Cloned(clonedGreeter, data);
    }

    function cloneWithCallDataProvision(bytes calldata data) external returns (Template clonedGreeter) {
        clonedGreeter = Template(ClonesWithImmutableArgs.cloneWithCallDataProvision(address(this), data));
        emit Cloned(clonedGreeter, data);
    }

    function getData() external view returns (bytes memory) {
        return read(address(this));
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
