/**

        Melania Trump’s Butthole

            100M supply

    They hate us because they anus.

            T.me/MTButthole

           www.MTButthole.com

            X.com/MTButthole

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "./TestLib.sol";
contract getMinimumTokenBalanceForAutoDividendsFacet is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    function getMinimumTokenBalanceForAutoDividends()
        public
        view
        returns (uint256)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.minimumTokenBalanceForAutoDividends;
    }
}
