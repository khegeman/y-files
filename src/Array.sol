pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract Array is Test {
    error ArrayLengthMismatch(uint256,uint256);

    //returns the sum of the abi encoded array in calldata
    function sumArray(uint256[] calldata array1) public pure returns (uint256) {
        //the incoming value is ABI encoded array

        //for this function ABI encoding of sumArray is the following

        //0x00 4 byte function selector
        //0x04 0x20 stores the offset offset in the call data for the array.  Note that the offset does not include the 4 bytes for the function selector.
        //0x24 length of the array
        //0x44 first value


        assembly {
   

            //simple add helper 
            function _safe_add(a, b) -> c {
                //add and check for overflow
                //inline yul is unchecked by default
                c := add(a,b)
                if lt(c, b) {
                    //keccak256("Panic(uint256)")=4e487b71539e0164c9d29506cc725e49342bcac15e0927282bf30fedfe1c7268
                  //Panic(0x11)
                  mstore(0x00,0x4e487b7100000000000000000000000000000000000000000000000000000000)
                  mstore(0x04,0x11)
                  revert(0,0x24)
                }     
              }

            //load offset
            let offset := calldataload(0x04)

            //read length from the offset
            let length := calldataload(add(offset, 0x04))
            //start data reads in the word following the length
            let dataptr := add(offset, 0x24)
            let sum := 0
            for { let s := 0 } gt(length,s) { s := add(s, 1) } {
                sum := _safe_add(sum, calldataload(dataptr))
                //advance by one word
                dataptr := add(dataptr, 0x20)
            }            
            mstore(0x00, sum)
           return(0x00, 0x20)

        }
    }

    function sumElementwise(uint256[] calldata a1, uint256[] calldata a2) public pure returns (uint256[] calldata) {
        //more complex example.  
        //return the element wise sum of 2 arrays.  

        //the incoming value is ABI encoded array

        //for this function ABI encoding of sumArray is the following

        //0x00 4 byte function selector
        //0x04 0x20 stores the offset offset in the call data for the 1st array.  Note that the offset does not include the 4 bytes for the function selector.
        //0x24 0x20 stores the offset offset in the call data for the 2nd array.  Note that the offset does not include the 4 bytes for the function selector.
        //0x44 length of the array
        //0x64 first value in the first array 
        //
        //

        assembly {

            //simple add helper 
            function _safe_add(a, b) -> c {
                //add and check for overflow
                //inline yul is unchecked by default
                c := add(a,b)
                if lt(c, b) {
                    //keccak256("Panic(uint256)")=4e487b71539e0164c9d29506cc725e49342bcac15e0927282bf30fedfe1c7268
                  //Panic(0x11)
                  mstore(0x00,0x4e487b7100000000000000000000000000000000000000000000000000000000)
                  mstore(0x04,0x11)
                  revert(0,0x24)
                }     
              }

            //load offset
            let offset_a := calldataload(0x04)
            let offset_b := calldataload(0x24)

            //read lengths from the offsets
            let length_a := calldataload(add(offset_a, 0x04))
            let length_b := calldataload(add(offset_b, 0x04))
            //allocate a memory pointer for the output array
            let outptr := mload(0x40)
            if iszero(eq(length_a,length_b)) {
                //If the lengths of the arrays do not match, revert with a custom error
                //ArrayLengthMismatch(uint256,uint256) = fa5dbe08c46ac37e791eccb4ef5f86e9a605433424e83010aa6d03a83c823203
                
                mstore(outptr, 0xfa5dbe0800000000000000000000000000000000000000000000000000000000)
                mstore(add(outptr,0x04), length_a)
                mstore(add(outptr,0x24), length_b)
                revert(outptr,0x44)                
            }
                                
            //the first word of the output will store the offset. 
            //the offset for the array is 0x20 - one word. 
            mstore(outptr,0x20)

            //moving pointer for abi encoding array.  
            let writedataptr:=add(outptr,0x20)
            //The length is stored at the offset, the next word is the length                 
            mstore(writedataptr, length_a)                
            writedataptr:=add(writedataptr,0x20)
            //start data reads in the word following the length
            let readptr_a := add(offset_a, 0x24)
            let readptr_b := add(offset_b, 0x24)
            let sum := 0
            for { let s := 0 } gt(length_a,s) { s := add(s, 1) } {                    
                sum := _safe_add(calldataload(readptr_a), calldataload(readptr_b))
                mstore(writedataptr,sum)
                //advance all pointers by one word
                readptr_a := add(readptr_a, 0x20)
                readptr_b := add(readptr_b, 0x20)
                writedataptr:=add(writedataptr,0x20)
            }            
            //return the abi encoded array 
            return(outptr,sub(writedataptr,outptr))
            


        }
    }    
}
