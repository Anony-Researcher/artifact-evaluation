/*
 * SPDX-License-Identifier: MIT
 * Website:  https://r-games.tech/
 * Telegram: https://t.me/RGamesOfficialChat
 * Twitter:  https://twitter.com/R_GamesOfficial
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
