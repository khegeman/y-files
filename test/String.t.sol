// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/String.sol";

contract StringTest is Test {
    String public s;

    function setUp() public {
        s = new String();
    }

    function testShortString() public {
        s.setShortString("Hello World");
        assertEq(s.readShortString(), "Hello World");
    }

    function testLongString() public {
        string memory long = "0123456789012345678901234567890123456789";
        s.setLongString(long);
        assertEq(s.readLongString(), long);
    }

    function testString(string calldata value) public {
        s.setString(value);
        assertEq(s.readStringYul(), value);
        assertEq(s.readString(), s.readStringYul());
    }
}
