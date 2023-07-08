// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/CustomError.sol";

contract CustomErrorTest is Test {
    CustomErrorContract public ce;

    function setUp() public {
        ce = new CustomErrorContract();
    }

    function testFailError0() public {
        ce.Error0();
    }

    function testFailError1() public {
        emit log_address(msg.sender);
        ce.Error1(msg.sender);
    }

    function testFailError2() public {
        ce.Error2(msg.sender, "Hello world");
    }    
    function testFailError2fuzz(string memory s) public {
        ce.Error2(msg.sender, s);
    }        
}
