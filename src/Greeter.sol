// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "./Cloning.sol";

library Errors {
    string internal constant InvalidBlockNumber =
        "invalid block number, please wait";
    string internal constant CannotGm = "cannot greet with gm";
}

contract Greeter {
    string public greeting;

    event Cloned(Greeter clone, uint256 d);

    function greet(string memory _greeting) public {
        require(
            keccak256(abi.encodePacked(_greeting)) != keccak256("gm"),
            Errors.CannotGm
        );
        greeting = _greeting;
    }

    function clone(uint256 data) external returns (Greeter clonedGreeter) {
        clonedGreeter = Greeter(ClonesWithArgs.clone2(address(this), bytes32(data)));
        uint256 d = clonedGreeter.getData();
        emit Cloned(clonedGreeter, d);
    }

    function getData() external pure returns (uint256) {
        return _lastAppendedDataAsUint256();
    }

    function _lastAppendedDataAsUint256() internal pure virtual returns (uint256 data) {
        assembly {
            data := calldataload(sub(calldatasize(), 32))
        }
    }
}
