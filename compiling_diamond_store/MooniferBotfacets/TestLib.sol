/**

Moonifer Bot - THE GATEWAY FOR EVERY TRADER TO FIND THE NEXT MOONER ON ETHEREUM
                                         
https://moonifer.bot/
https://twitter.com/mooniferboteth
https://t.me/mooniferbot

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

string constant name = "MooniferBot";
string constant symbol = "MOON";
uint8 constant decimals = 9;
uint256 constant totalSupply = 10000000 * 10 ** uint256(decimals);

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
