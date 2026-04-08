/*
RESHAPING FINANCIAL DYNAMICS WITH DEXACARD

WEBSITE        | https://dexacard.com
GITDOC         | https://docs.dexacard.com/
BOT            | https://t.me/DexaCardBot
TELEGRAM       | https://t.me/DexaCard_portal
TWITTER        | https://twitter.com/DexaCard
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10 >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
