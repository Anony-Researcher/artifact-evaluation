// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract isExcludedFromRewardFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwapAndLiquify = true;
        _;
        ds._inSwapAndLiquify = false;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcluded[account];
    }
}
