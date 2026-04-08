/*
 * SPDX-License-Identifier: MIT
 * Website:  https://www.ten.xyz/
 * Discord:  https://discord.com/invite/yQfmKeNzNd
 * Telegram: https://t.me/tenprotocol
 * Twitter:  https://twitter.com/tenprotocol
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
