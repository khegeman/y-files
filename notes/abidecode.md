Abi Array Decoding In YUL



This article is a quick example of how to decode an ABI encoded array in YUL.  It assumes that you are already familiar with both yul and the concept of ABI encoding.  



# Implement the following interface

```solidity
function sumArray(uint256[] calldata array1) public pure returns (uint256)
```





The entire call data for this function will be encoded

For example , if sumArray is called with the 3 element array `[4,33,42]` Then the abi encoding would be as follows



```
0x1e2aea0600000000000000000000000000000000000000000000000000000000000
000200000000000000000000000000000000000000000000000000000000000000003
000000000000000000000000000000000000000000000000000000000000000400000
000000000000000000000000000000000000000000000000000000000210000000000
00000000000000000000000000000000000000000000000000002a
```



| Location | Value      | Description                                   |
| -------- | ---------- | --------------------------------------------- |
| 0x00     | 0x1e2aea06 | 4 byte function selector                      |
| 0x04     | 0x20       | offset in bytes to the data area of the array |
| 0x24     | 0x03       | Length of the array                           |
| 0x44     | 0x04       | First element of the array                    |
| 0x64     | 0x21       | Second element of the array                   |
| 0x84     | 0x2A       | Third element of the array                    |

Now that we have the scheme layed out.  We can design an algorithm to read  array1.  We first load the "head part" of array containing the offset of the data area. 

`let offset := calldataload(0x04)`

then we use offset to compute the location containing the length of the array

`let length := calldataload(add(offset, 0x04))`

The first data element is stored immediately following the length

`let dataptr := add(offset, 0x24)`

Now we just need to run a loop that loads each element of the array and keeps the running sum.

```solidity
            let sum := 0
            for { let s := 0 } gt(length,s) { s := add(s, 1) } {
                sum := add(sum, calldataload(dataptr))
                //advance by one word
                dataptr := add(dataptr, 0x20)
            }    
```





Note that in the above implementation, the sum can overflow as yul math is always unchecked..   In the full implementation below, a `_safe_add` helper function is used that checks for overflow and reverts with a panic. 



For inline assembly, we can also access 2 attributes on array1 to make the decoding simpler. these are `array1.length` which contains the number of elements in the array and `array1.offset` which contains the offset to the first element of the array.





```solidity
    function sumArray(uint256[] calldata) public pure returns (uint256) {

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

            //read length from the offset
            let length := array1.length
            //start data reads in the word following the length
            let dataptr := array1.offset
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
```





`1e2aea06`

`0000000000000000000000000000000000000000000000000000000000000020`

`0000000000000000000000000000000000000000000000000000000000000003`

`0000000000000000000000000000000000000000000000000000000000000004`

`0000000000000000000000000000000000000000000000000000000000000021`

`000000000000000000000000000000000000000000000000000000000000002a`
