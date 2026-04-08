/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.thesoftdao.com
 * X: https://twitter.com/thesoftdao
 * Tele: https://t.me/theSoftDAO
 * Discord: https://discord.com/invite/thesoftdao
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
