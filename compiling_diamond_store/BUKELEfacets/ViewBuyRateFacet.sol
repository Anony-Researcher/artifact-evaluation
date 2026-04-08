// SPDX-License-Identifier: MIT

// $BUKELE
// Nayib Bukele, visionary leader, adopts Bitcoin, reforms prisons, and ensures safety.

// Website: bukele.xyz
// Telegram: t.me/bukele_eth
// x: x.com/ethbukele

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract ViewBuyRateFacet {
    using SafeMath for uint256;
    using Address for address payable;

    function ViewBuyRate()
        public
        view
        returns (
            uint256 devBuyRate,
            uint256 totalBuyRate,
            uint256 maxWallet,
            uint256 maxBuyAmount
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        devBuyRate = ds._devTaxRate;
        totalBuyRate = ds.AmountBuyRate;
        maxWallet = ds._maxWallet;
        maxBuyAmount = ds._maxBuyAmount;
    }
}
