/**
 *Submitted for verification at Etherscan.io on 2024-03-07
 */

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract _deployFundsFacet is BaseStrategy, UniswapV3Swapper {
    using SafeERC20 for ERC20;

    function _deployFunds(uint256 _amount) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.comet.supply(address(asset), _amount);
    }
    function _freeFunds(uint256 _amount) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.comet.withdraw(
            address(asset),
            Math.min(ds.comet.balanceOf(address(this)), _amount)
        );
    }
    function _harvestAndReport()
        internal
        override
        returns (uint256 _totalAssets)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Only sell if ds.claimRewards is true.
        if (ds.claimRewards) {
            // Claim and sell any rewards to `asset` and accrue.
            rewardsContract.claim(address(ds.comet), address(this), true);

            uint256 balance = ERC20(ds.rewardToken).balanceOf(address(this));
            // The uni swapper will do min checks on _reward.
            _swapFrom(
                ds.rewardToken,
                address(asset),
                balance,
                _getAmountOut(balance)
            );
        }

        _totalAssets = ds.comet.balanceOf(address(this)) + balanceOfAsset();
    }
    function setUniFees(
        uint24 _rewardToBase,
        uint24 _baseToAsset
    ) external onlyManagement {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _setUniFees(ds.rewardToken, base, _rewardToBase);
        _setUniFees(base, address(asset), _baseToAsset);
    }
    function setMinAmountToSell(
        uint256 _minAmountToSell
    ) external onlyManagement {
        minAmountToSell = _minAmountToSell;
    }
    function swapBase() external onlyManagement {
        base = base == address(asset) ? weth : address(asset);
    }
    function setClaimRewards(bool _claimRewards) external onlyManagement {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.claimRewards = _claimRewards;
    }
    function setPercentOut(uint256 _percentOut) external onlyManagement {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.percentOut = _percentOut;
    }
    function availableDepositLimit(
        address /*_owner*/
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        /// We need to be able to both supply on deposits.
        if (ds.comet.isSupplyPaused()) return 0;

        return type(uint256).max;
    }
    function availableWithdrawLimit(
        address /*_owner*/
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.comet.isWithdrawPaused()) {
            return balanceOfAsset();
        }

        return balanceOfAsset() + asset.balanceOf(address(ds.comet));
    }
    function _emergencyWithdraw(uint256 _amount) internal override {
        _freeFunds(_amount);
    }
    function balanceOfAsset() public view returns (uint256) {
        return asset.balanceOf(address(this));
    }
    function _getAmountOut(uint256 _amount) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _percentOut = ds.percentOut;
        // Don't call the oracle if percent out is 0.
        if (_amount == 0 || _percentOut == 0) return 0;

        // Get oracle data.
        int256 answer;
        (, answer, , , ) = ds.rewardOracle.latestRoundData();

        return
            (uint256(answer) * _amount * ds.percentOut) /
            ds.oracleScaler /
            10_000;
    }
}
