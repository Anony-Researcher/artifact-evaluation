// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract setUniFeesFacet is BaseStrategy, AuctionSwapper, UniswapV3Swapper {
    using SafeERC20 for ERC20;

    function setUniFees(
        address _token0,
        address _token1,
        uint24 _fee
    ) external onlyManagement {
        _setUniFees(_token0, _token1, _fee);
    }
    function _deployFunds(uint256 _amount) internal override {
        lendingPool.supply(address(asset), _amount, address(this), 0);
    }
    function _freeFunds(uint256 _amount) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        lendingPool.withdraw(
            address(asset),
            Math.min(ds.aToken.balanceOf(address(this)), _amount),
            address(this)
        );
    }
    function _harvestAndReport()
        internal
        override
        returns (uint256 _totalAssets)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.claimRewards) {
            // Claim and sell any rewards to `asset`.
            _claimAndSellRewards();
        }

        _totalAssets = ds.aToken.balanceOf(address(this)) + balanceOfAsset();
    }
    function manualRedeemAave() external onlyKeepers {
        _redeemAave();
    }
    function availableDepositLimit(
        address /*_owner*/
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Get the data configuration bitmap.
        uint256 _data = lendingPool
            .getReserveData(address(asset))
            .configuration
            .data;

        // Cannot deposit when paused or frozen.
        if (_isPaused(_data) || _isFrozen(_data)) return 0;

        uint256 supplyCap = _getSupplyCap(_data);

        // If we have no supply cap.
        if (supplyCap == 0) return type(uint256).max;

        // Supply plus any already idle funds.
        uint256 supply = ds.aToken.totalSupply() +
            asset.balanceOf(address(this));

        // If we already hit the cap.
        if (supplyCap <= supply) return 0;

        // Return the remaining room.
        unchecked {
            return supplyCap - supply;
        }
    }
    function availableWithdrawLimit(
        address /*_owner*/
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 liquidity = asset.balanceOf(address(ds.aToken));

        // Cannot withdraw from the pool when paused.
        if (
            _isPaused(
                lendingPool.getReserveData(address(asset)).configuration.data
            )
        ) liquidity = 0;

        return balanceOfAsset() + liquidity;
    }
    function setMinAmountToSellMapping(
        address _token,
        uint256 _amount
    ) external onlyManagement {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minAmountToSellMapping[_token] = _amount;
    }
    function setClaimRewards(bool _bool) external onlyManagement {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.claimRewards = _bool;
    }
    function setAuction(address _auction) external onlyEmergencyAuthorized {
        if (_auction != address(0)) {
            require(Auction(_auction).want() == address(asset), "wrong want");
        }
        auction = _auction;
    }
    function _auctionKicked(
        address _token
    ) internal virtual override returns (uint256 _kicked) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_token != address(asset), "asset");
        _kicked = super._auctionKicked(_token);
        require(_kicked >= ds.minAmountToSellMapping[_token], "too little");
    }
    function setUseAuction(bool _useAuction) external onlyManagement {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.useAuction = _useAuction;
    }
    function _emergencyWithdraw(uint256 _amount) internal override {
        _freeFunds(_amount);
    }
    function _isPaused(uint256 _data) internal view returns (bool) {
        // Create a mask with only the 60th bit set
        uint256 mask = 1 << 60; // Bitwise left shift by 59 positions

        // Perform bitwise AND operation to check if the 60th bit is 0.
        return (_data & mask) != 0;
    }
    function balanceOfAsset() public view returns (uint256) {
        return asset.balanceOf(address(this));
    }
    function _isFrozen(uint256 _data) internal view returns (bool) {
        // Create a mask with only the 57th bit set
        uint256 mask = 1 << 57; // Bitwise left shift by 56 positions

        // Perform bitwise AND operation to check if the 57th bit 0.
        return (_data & mask) != 0;
    }
    function _getSupplyCap(uint256 _data) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Get out the supply cap for the asset.
        uint256 cap = (_data & ~SUPPLY_CAP_MASK) >>
            SUPPLY_CAP_START_BIT_POSITION;
        // Adjust to the correct ds.decimals.
        return cap * (10 ** ds.decimals);
    }
    function getSupplyCap() public view returns (uint256) {
        _getSupplyCap(
            lendingPool.getReserveData(address(asset)).configuration.data
        );
    }
    function _redeemAave() internal {
        if (!checkCooldown()) {
            return;
        }

        uint256 stkAaveBalance = ERC20(address(stkAave)).balanceOf(
            address(this)
        );

        if (stkAaveBalance > 0) {
            stkAave.redeem(address(this), stkAaveBalance);
        }
    }
    function _claimAndSellRewards() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Claim any pending stkAave.
        _redeemAave();

        //claim all rewards
        address[] memory assets = new address[](1);
        assets[0] = address(ds.aToken);
        (address[] memory rewardsList, ) = ds
            .rewardsController
            .claimAllRewardsToSelf(assets);

        // Start cooldown on any new stkAave.
        _harvestStkAave();

        // If using the Auction contract we are done.
        if (ds.useAuction) return;

        // Else swap as much as possible back to asset through uni.
        address token;
        for (uint256 i = 0; i < rewardsList.length; ++i) {
            token = rewardsList[i];

            if (token == address(asset)) {
                continue;
            } else if (token == address(stkAave)) {
                // We swap Aave => asset
                token = AAVE;
            }

            uint256 balance = ERC20(token).balanceOf(address(this));

            if (balance > ds.minAmountToSellMapping[token]) {
                _swapFrom(token, address(asset), balance, 0);
            }
        }
    }
    function _harvestStkAave() internal {
        // request start of cooldown period
        if (ERC20(address(stkAave)).balanceOf(address(this)) > 0) {
            stkAave.cooldown();
        }
    }
    function checkCooldown() public view returns (bool) {
        uint256 cooldownStartTimestamp = IStakedAave(stkAave).stakersCooldowns(
            address(this)
        );

        if (cooldownStartTimestamp == 0) return false;

        uint256 COOLDOWN_SECONDS = IStakedAave(stkAave).COOLDOWN_SECONDS();
        uint256 UNSTAKE_WINDOW = IStakedAave(stkAave).UNSTAKE_WINDOW();
        if (block.timestamp >= cooldownStartTimestamp + COOLDOWN_SECONDS) {
            return
                block.timestamp - (cooldownStartTimestamp + COOLDOWN_SECONDS) <=
                UNSTAKE_WINDOW;
        } else {
            return false;
        }
    }
}
