// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Events.sol";

contract EventTest is Test {
    EventsContract public ev;

    function setUp() public {
        ev = new EventsContract();
    }

    function testEmitUri() public {
        ev.EmitURI("hello world", 343);
    }

  
}
