// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./utils/TemplateTest.sol";

contract TemplateTestSuite is TemplateTest {


    function testClone() public {
        string memory message = "dsaldj asdkasjdklsahfk jhdjkhsasajhdjsahdjksahd jksajdhsajdksajdh sajdhaks kjashdkjah sdjsahdjsahdjksah djkhsajd hsajdhsajdhsa jdhsjadhjsa dhjsahdj shdjsah djksahdjsah dsajdhsajdhkjashdjsa dhjsahd jshdjsah djsahd jsahdjsahdjsahd jsahdjsa hdsajhd jsahdjsahdj sdhjashdj sahdjaks hdjsahdjsa hdjsahdjsahdjsahdjhsa jdhsajdhkjashdkj ashjdkhsajdhasjdhja ssad ashdjsahdjsahjdhsajdhsajdhsakhdjsahdjksahdjkhsa ";
        Template clone = template.clone1(bytes(message));
        bytes memory b = clone.getData();
        emit log_named_bytes("BYTES", b);
        assertEq0(bytes(message), b);
    }

    function testCloneHello() public {
        string memory message = "dsaldj asdkasjdklsahfk jhdjkhsasajhdjsahdjksahd jksajdhsajdksajdh sajdhaks kjashdkjah sdjsahdjsahdjksah djkhsajd hsajdhsajdhsa jdhsjadhjsa dhjsahdj shdjsah djksahdjsah dsajdhsajdhkjashdjsa dhjsahd jshdjsah djsahd jsahdjsahdjsahd jsahdjsa hdsajhd jsahdjsahdj sdhjashdj sahdjaks hdjsahdjsa hdjsahdjsahdjsahdjhsa jdhsajdhkjashdkj ashjdkhsajdhasjdhja ssad ashdjsahdjsahjdhsajdhsajdhsakhdjsahdjksahdjkhsa ";
        Template clone = template.clone1(bytes(message));
        bytes memory b = clone.hello();
        emit log_named_bytes("BYTES", b);
        assertEq0(bytes("hello"), b);
    }

    function testCloneWithCallDataProvision() public {
        string memory message = "dsaldj asdkasjdklsahfk jhdjkhsasajhdjsahdjksahd jksajdhsajdksajdh sajdhaks kjashdkjah sdjsahdjsahdjksah djkhsajd hsajdhsajdhsa jdhsjadhjsa dhjsahdj shdjsah djksahdjsah dsajdhsajdhkjashdjsa dhjsahd jshdjsah djsahd jsahdjsahdjsahd jsahdjsa hdsajhd jsahdjsahdj sdhjashdj sahdjaks hdjsahdjsa hdjsahdjsahdjsahdjhsa jdhsajdhkjashdkj ashjdkhsajdhasjdhja ssad ashdjsahdjsahjdhsajdhsajdhsakhdjsahdjksahdjkhsa ";
        Template clone = template.clone2(bytes(message));

        // bytes memory b = clone.getAppendedCallData();
        // emit log_named_bytes("BYTES", b);
        // assertEq0(bytes(message), b);

        bytes memory b = clone.hello();
        emit log_named_bytes("BYTES", b);
        assertEq0(bytes("hello"), b);

        // bytes memory b = clone.getDataWithCallDataProvision();
        // emit log_named_bytes("BYTES", b);
        // assertEq0(bytes(message), b);

        // bytes memory b = clone.getDataWithCallDataProvision();
        // emit log_named_bytes("BYTES", b);
        // assertEq0(bytes(message), b);
    }
}
