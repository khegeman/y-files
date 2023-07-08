// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CustomErrorContract {

    error CustomError0();
    error CustomError1(address);
    error CustomError2(address, string);

    function Error0() public pure {
        //keccak256 of CustomError0()
        //c1fc1c519dae12b1728ba3cc02b378d270f35d2c2a63831eb4501556c2ffbe38

        assembly {
            //first 4 bytes of keccak256
            mstore(0x00,0xc1fc1c5100000000000000000000000000000000000000000000000000000000)
            revert(0x00,0x04)
        }
    }

    function Error1(address param1) public pure {
        //keccak256 CustomError1(address)
        //3878c8bbbc2c54b07ccb9113a6ea6db14d5f03f2de336ec2e42be734deaa5b27
        assembly {
            //first 4 bytes of keccak256
            mstore(0x00,0x3878c8bb00000000000000000000000000000000000000000000000000000000)
            mstore(0x04, calldataload(0x04))
            revert(0x00,0x24)
        }
    }

    //this is a more complex example using a string
    function Error2(address,string calldata) public pure  {
        //keccak256 CustomError2(address, string)        
        //f371c61f571efb92b582d7f0fe3ac291bbb0f773c105952d0902a1bd8c09ae64
        uint256 len;
        assembly {
            //free memory ptr from solidity
            let ptr := mload(0x40)            
            //first 4 bytes of keccak256
            mstore(ptr,0xf371c61f00000000000000000000000000000000000000000000000000000000)
            mstore(add(ptr,0x04), calldataload(0x04))
            //offset of the string
            mstore(add(ptr,0x24), 0x40)
            //copy the abi encoded string from call data into memory
            //location of the string param in calldata stores the abi offset of the string data
            let abioffset := calldataload(0x24)
            //add 4 to account for the 4 byte function signature
            let stroffset:=add(0x04,abioffset)
            //length of the string is stored at the offset
            len := calldataload(stroffset)
            //store the length for abi encoding
            mstore(add(ptr,0x44), len)
            //copy the string bytes to memory
            calldatacopy(add(ptr,0x64), add(stroffset,0x20), len )
            
            //find len of string rounded up to 32 bytes. 
            let strbytes := mul(add(div(len, 0x20),1),0x20)
            //return the 64 byte header + len of the string rounded up to 32 bytes
            revert(ptr,add(0x64,strbytes))
        }
        
    }    
}
