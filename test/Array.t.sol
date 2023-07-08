// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Array.sol";

contract ArrayTest is Test {
    Array public a;

    function setUp() public {
        a = new Array();
    }

    function testSum1() public {

        uint256[] memory values = new uint256[](4);
        values[0] = 1;
        values[1] = 3;
        values[2] = 4;
        values[3] = 2;

        uint256 sum = a.sumArray(values);
        assertEq(sum, 10);
    }

    function testFailOverflow() public {
        uint256[] memory values = new uint256[](4);
        values[0] = type(uint256).max - 4;
        values[1] = 3;
        values[2] = 4;
        values[3] = 2;

        uint256 sum = a.sumArray(values);
        assertEq(sum, 10);        
    }
    function testSum2() public {

        uint256[] memory valuesa = new uint256[](4);
        valuesa[0] = 1;
        valuesa[1] = 3;
        valuesa[2] = 4;
        valuesa[3] = 2;

        uint256[] memory valuesb = new uint256[](4);
        valuesb[0] = 11;
        valuesb[1] = 13;
        valuesb[2] = 14;
        valuesb[3] = 12;

        uint256[] memory sum = a.sumElementwise(valuesa,valuesb);
        for (uint i = 0; i < sum.length; i++) {
            assertEq(sum[i], valuesa[i] + valuesb[i] );
        }
        
    }
    
    function testFailSum2() public {

        uint256[] memory valuesa = new uint256[](4);
        valuesa[0] = 1;
        valuesa[1] = 3;
        valuesa[2] = 4;
        valuesa[3] = 2;

        uint256[] memory valuesb = new uint256[](5);
        valuesb[0] = 11;
        valuesb[1] = 13;
        valuesb[2] = 14;
        valuesb[3] = 12;
        valuesb[4] = 12;

        uint256[] memory sum = a.sumElementwise(valuesa,valuesb);
        
    }
    

}
