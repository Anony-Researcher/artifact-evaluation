// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract ViewSellRateFacet {
    using SafeMath for uint256;
    using Address for address payable;

    function ViewSellRate()
        public
        view
        returns (
            uint256 devSellRate,
            uint256 totalSellRate,
            uint256 maxSellAmount
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        devSellRate = ds._devTaxSellRate;
        totalSellRate = ds.AmountSellRate;
        maxSellAmount = ds._maxSellAmount;
    }
}
