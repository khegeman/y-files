Solidity Mapping Storage

Define solidity mapping

How does solidity find the slot for a given key? 

keccack256(key . slot)

If we know the storage slot  of the map, we can find the slot the value for a given key by calling the keccak256 function on the concatenation of the key and the slot.  For instance, if the map is stored in slot 0 of a contract.

```solidity
uint256 mapSlot = 0;
uint256 keySlot = uint256(keccak256(abi.encode(key, uint256(mapSlot))));
```

In inline yul assembly, there is a .slot accessor on all storage variables and we can write the code more generally as follows : 

```solidity
        assembly {
            mstore(0x00, key)
            mstore(0x20, map.slot)
            let slot := keccak256(0x00, 0x40)

            value := sload(slot)
        }
```

# Nested Mappings!

Nested mappings work by concatenation as well.  It's just recursive.  

```solidity
    function readMap2(address key1,uint256 key2) public view returns(uint256) {

        uint256 value;
        assembly {
            mstore(0x00, key1)
            mstore(0x20, map2.slot)
            let slot1 := keccak256(0x00, 0x40)

            mstore(0x00, key2)
            mstore(0x20, slot1)
            let slot2 := keccak256(0x00, 0x40)


            value := sload(slot2)
        }

        return value;
    }   
```

Full example contract 

```solidity

```
