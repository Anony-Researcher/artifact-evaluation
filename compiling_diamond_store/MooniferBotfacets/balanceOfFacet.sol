/**

Moonifer Bot - THE GATEWAY FOR EVERY TRADER TO FIND THE NEXT MOONER ON ETHEREUM
                                         
https://moonifer.bot/
https://twitter.com/mooniferboteth
https://t.me/mooniferbot

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.balances[account];
    }
}
