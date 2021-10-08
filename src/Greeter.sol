// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "./Cloning.sol";

library Errors {
    string internal constant InvalidBlockNumber =
        "invalid block number, please wait";
    string internal constant CannotGm = "cannot greet with gm";
}

contract Greeter is ClonesWithArgs {
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
        clonedGreeter = Greeter(ClonesWithArgs.clone2b(address(this), bytes32(data)));
        // uint256 d = clonedGreeter.getData();
        // emit Cloned(clonedGreeter, d);
    }

    function clone3(uint256 data) external returns (Greeter clonedGreeter) {
        // bytes memory b = "0000000000000000000000000000000000000000000000000000000000000000";
        bytes memory b = abi.encode(data);
        emit log_bytes(b);
        emit log_uint(data);
        clonedGreeter = Greeter(ClonesWithArgs.clone3b(address(this), b));
        // uint256 d = clonedGreeter.getData();
        // emit Cloned(clonedGreeter, d);
    }

    function getData() external returns (bytes memory) {
        return read(address(this));
    }

    function getUInt() external returns (uint256) {
        // return 0;
        bytes memory b = read(address(this));
        emit log_named_bytes("BYTES", b);
        return abi.decode(b, (uint256));
        // return _lastAppendedDataAsUint256();
    }

    // fallback() external {}

    function _lastAppendedDataAsUint256() internal pure virtual returns (uint256 data) {
        assembly {
            data := calldataload(sub(calldatasize(), 32))
        }
    }
}
