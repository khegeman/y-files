// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Map.sol";

contract MapTest is Test {
    Mapping public map;

    function setUp() public {
        map = new Mapping();
    }

    function testSet() public {
        map.set(address(this), 45);
        assertEq(map.readMap(address(this)), 45);
    }

    function testSet2() public {
        map.set2(address(this), 41, 45);
        assertEq(map.readMap2(address(this), 41), 45);
    }
}
