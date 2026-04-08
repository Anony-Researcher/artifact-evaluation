// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://publicai.io/
    Twitter:  https://twitter.com/PublicAI_
    Discord:  https://discord.com/invite/sQcS7Sh6ZD
    Telegram: https://t.me/Public_AI

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
