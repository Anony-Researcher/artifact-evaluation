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
contract getAccountFacet is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    function getAccount(
        address _account
    )
        public
        view
        returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        account = _account;

        index = ds.tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > ds.lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(
                    int256(ds.lastProcessedIndex)
                );
            } else {
                uint256 processesUntilEndOfArray = ds
                    .tokenHoldersMap
                    .keys
                    .length > ds.lastProcessedIndex
                    ? ds.tokenHoldersMap.keys.length.sub(ds.lastProcessedIndex)
                    : 0;

                iterationsUntilProcessed = index.add(
                    int256(processesUntilEndOfArray)
                );
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = ds.lastClaimTimes[account];
    }
    function getAccountAtIndex(
        uint256 index
    ) public view returns (address, int256, int256, uint256, uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (index >= ds.tokenHoldersMap.size()) {
            return (
                0x0000000000000000000000000000000000000000,
                -1,
                -1,
                0,
                0,
                0
            );
        }

        address account = ds.tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }
}
