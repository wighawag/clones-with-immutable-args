// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "ds-test/test.sol";

import "../../Template.sol";
import "./Hevm.sol";

contract User {
    Template internal template;

    constructor(address _template) {
        template = Template(_template);
    }

    function clone(bytes memory data) public {
        template.clone(data);
    }
}

contract TemplateTest is DSTest {
    Hevm internal constant hevm = Hevm(HEVM_ADDRESS);

    // contracts
    Template internal template;

    // users
    User internal alice;
    User internal bob;

    function setUp() public virtual {
        template = new Template();
        alice = new User(address(template));
        bob = new User(address(template));
    }
}
