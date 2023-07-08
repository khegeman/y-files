// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract EventsContract {

    //ERC1155 event
    event URI(string value, uint256 indexed id);

    //example of how to emit an event
    function EmitURI(string memory , uint256 ) public  {

        assembly {
            let signatureHash := 0x6bb7ff708619ba0610cba295a58592e0451dee2622938c8755667688daf3529b

            let ptr := mload(0x40)
            let soffset:=calldataload(0x04)
            let length := calldataload(add(0x04,soffset))
            let id := calldataload(0x24)
            //abi offset
            mstore(ptr, 0x20)
            //abi length
            mstore(add(ptr,0x20), length)
            //string data
            //calldatacopy the string to memory            
            calldatacopy(add(ptr,0x40), add(soffset,0x24),length )
            //round up to next multiple of 32 bytes for abi encoding
            let slen := mul(add(div(length,0x20),1),0x20)
            log2(ptr, add(0x40,slen), signatureHash, id)             
        }
    }

}
