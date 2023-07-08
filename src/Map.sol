// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Mapping {
    mapping(address => uint256) public map;
   // mapping(address => mapping(uint256 => uint256)) public map2;

    function set(address key, uint256 value) public {
        map[key] = value;
    }

    function set2(address key1, uint256 key2, uint256 value) public {
        map2[key1][key2] = value;
    }

    function readMap(address key) public view returns (uint256) {
        uint256 value;
        assembly {
            mstore(0x00, key)
            mstore(0x20, map.slot)
            let slot := keccak256(0x00, 0x40)

            value := sload(slot)
        }

        return value;
    }
    mapping(address => mapping(uint256 => uint256)) public map2;
    function readMap2(address key1, uint256 key2) public view returns (uint256) {
        uint256 value;
        assembly {
            //find the first slot
            mstore(0x00, key1)
            mstore(0x20, map2.slot)
            let slot1 := keccak256(0x00, 0x40)

            //recursively find the 2nd slot
            mstore(0x00, key2)
            mstore(0x20, slot1)
            let slot2 := keccak256(0x00, 0x40)

            //load the value from the 2nd slot
            value := sload(slot2)
        }

        return value;
    }
}
