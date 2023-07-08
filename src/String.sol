pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract String is Test {
    string shortString;
    string longString;
    string savedString;

    function setShortString(string calldata) public {
        //the incoming value is ABI encoded string

        //for this function ABI encoding of s is the following

        //0x00 4 byte function selector
        //0x04 0x20 stores the offset offset in the call data for the string.  Note that the offset does not include the 4 bytes for the function selector.
        //0x24 length
        //0x44 string bytes

        //we need to store the value in the contract

        assembly {
            //load offset
            let offset := calldataload(0x04)
            let length := calldataload(add(offset, 0x04))

            let data := calldataload(add(offset, 0x24))

            //only handling short strings right now
            if gt(length, 31) { revert(0, 0) }

            //first 31 bytes are the data.
            // Length is stored in the first 7 bits of the lowest byte.
            // the lowest bit is always 0 for a short string.  This is used in decoding
            sstore(shortString.slot, or(data, shl(1, length)))
        }
    }

    function setLongString(string calldata) public {
        //the incoming value is ABI encoded string

        //for this function ABI encoding of s is the following

        //0x00 4 byte function selector
        //0x04 0x20 stores the offset offset in the call data for the string.  Note that the offset does not include the 4 bytes for the function selector.
        //0x24 length
        //0x44 start of string bytes

        //we need to store the value in the contract

        assembly {
            //load offset
            let offset := calldataload(0x04)
            let length := calldataload(add(offset, 0x04))

            let next := add(offset, 0x24)

            //only handling long strings right now
            if lt(length, 32) { revert(0, 0) }

            // Length and the flag are stored in the slot
            // the lowest bit is the flag and is set to 1 for a long string.
            sstore(longString.slot, add(shl(1, length), 1))

            mstore(0x00, longString.slot)
            let sslot := keccak256(0x00, 0x20)

            //the end condition of the loop is when we've written more bytes than length
            //one word at a time is written to storage.
            for { let s := 0 } gt(length, mul(s, 0x20)) { s := add(s, 1) } {
                sstore(add(sslot, s), calldataload(next))
                next := add(next, 0x20)
            }
        }
    }

    function setString(string calldata) public {
        //the incoming value is ABI encoded string

        //for this function ABI encoding of s is the following

        //0x00 4 byte function selector
        //0x04 0x20 stores the offset offset in the call data for the string.  Note that the offset does not include the 4 bytes for the function selector.
        //0x24 length
        //0x44 start of string bytes

        //we need to store the value in the contract

        assembly {
            //load offset
            let offset := calldataload(0x04)
            let length := calldataload(add(offset, 0x04))

            let readptr := add(offset, 0x24)

            switch gt(length, 31)
            case 0x00 {
                //store the short string
                //lowest byte = LLLLLLL0 - where L bits store the length
                let lowestbyte := shl(1, length)
                let strbytes := calldataload(readptr)
                //strbytes is where S contain bytes of the string.  L is the lowest byte containing encoded length and flag.
                //SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS0
                //0000000000000000000000000000000L
                //bitwise or
                //SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSL

                let data := or(strbytes, lowestbyte)
                sstore(savedString.slot, data)
            }
            case 0x01 {
                // Length and the flag are stored in the slot
                // the lowest bit is the flag and is set to 1 for a long string.
                sstore(savedString.slot, add(shl(1, length), 1))

                //find the slot to store the first word string data
                mstore(0x00, savedString.slot)
                let sslot := keccak256(0x00, 0x20)

                let s := 0
                for {} gt(length, mul(s, 0x20)) {} {
                    sstore(add(sslot, s), calldataload(readptr))
                    s := add(s, 1)
                    readptr := add(readptr, 0x20)
                }
            }
        }
    }

    function readShortString() public view returns (string memory) {
        return shortString;
    }

    function readLongString() public view returns (string memory) {
        return longString;
    }

    function readString() public view returns (string memory) {
        return savedString;
    }

    function readStringYul() public view returns (string memory) {
        //decode soliidty string from storage and return ABI encoded string
        assembly {
            let u := sload(savedString.slot)

            //load the free memory pointer
            let ptr := mload(0x40)

            //convert from solidity encoded string to abi encoded string

            //check the lowest order byte for a 1 .
            let isLongString := and(u, 0x1)

            //offset is the first word in abi encoding
            mstore(ptr, 0x20)

            switch isLongString
            case 0x00 {
                //. stored in the lowest word as 2x length
                let lowestbyte := and(u, 0xFF)
                //shift right by 1 bit to divide by 2.
                let length := shr(0x01, lowestbyte)
                //at the offset, we store the length
                mstore(add(ptr, 0x20), length)
                //store the string bytes immediately following length
                mstore(add(ptr, 0x40), shl(8, shr(8, u)))
                return(ptr, 0x60)
            }
            default {
                //find the slot containing the first word of string data
                mstore(0x00, savedString.slot)
                let slot := keccak256(0x00, 0x20)

                //get the length. stored as 2x length
                let length := shr(0x01, u)
                mstore(add(ptr, 0x20), length)
                //start writing the bytes at the next word after length
                let next := add(ptr, 0x40)
                let s := 0
                //loop until we have encoded the total length
                //the final word is padded with 0s for abi encoding so
                for {} gt(length, mul(s, 0x20)) { s := add(s, 1) } {
                    //load from storage and write to memory
                    mstore(next, sload(add(slot, s)))

                    //move write pointer forward one word
                    next := add(next, 0x20)
                }
                return(ptr, add(0x40, mul(s, 0x20)))
            }
        }
    }
}
