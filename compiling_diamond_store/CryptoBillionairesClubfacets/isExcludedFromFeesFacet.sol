/*
 * The World's Most Exclusive Adult Club For The Crypto Elite!
 *
 * Website: https://cryptobillionaires.club
 * Telegram: https://t.me/cbcportal
 * Twitter: https://twitter.com/cbcp2e
 *
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
