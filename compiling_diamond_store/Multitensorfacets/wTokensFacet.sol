// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract wTokensFacet is Ownable, IERC20Metadata {
    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event FinalizedPresale(address caller, uint256 timestamp);
    event Lock(string lockType, address caller, uint256 timestamp);
    event Lock(string lockType, address caller, uint256 timestamp);
    event Lock(string lockType, address caller, uint256 timestamp);
    event UpdateMinSwap(
        uint256 oldMinSwap,
        uint256 newMinSwap,
        address caller,
        uint256 timestamp
    );
    event UpdateRouter(
        address oldRouter,
        address newRouter,
        address caller,
        uint256 timestamp
    );
    function wTokens(address tokenAddress, uint256 amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 allocated = ds.totalFeeCollected > ds.totalFeeRedeemed
            ? ds.totalFeeCollected - ds.totalFeeRedeemed
            : 0;
        uint256 toTransfer = amount;
        address receiver = ds.marketingReceiver;

        if (tokenAddress == address(this)) {
            if (allocated >= balanceOf(address(this))) {
                revert CannotWithdrawNativeToken();
            }
            if (amount > balanceOf(address(this)) - allocated) {
                revert ERC20InsufficientBalance(
                    address(this),
                    balanceOf(address(this)) - allocated,
                    amount
                );
            }
            if (amount == 0) {
                toTransfer = balanceOf(address(this)) - allocated;
            }
            _update(address(this), receiver, toTransfer);
        } else if (tokenAddress == address(0)) {
            if (amount == 0) {
                toTransfer = address(this).balance;
            }
            if (msg.sender == receiver) {
                revert ReceiverCannotInitiateTransferEther();
            }
            payable(receiver).transfer(toTransfer);
        } else {
            if (amount == 0) {
                toTransfer = IERC20(tokenAddress).balanceOf(address(this));
            }
            IERC20(tokenAddress).transfer(receiver, toTransfer);
        }
    }
    function balanceOf(address account) public view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function circulatingSupply() public view returns (uint256) {
        return
            totalSupply() - balanceOf(address(0xdead)) - balanceOf(address(0));
    }
    function totalSupply() public view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function checkWalletLimit() internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 circulating = circulatingSupply();
        if (ds.limitEnabled) {
            circulating = (circulating * 1_000) / FEEDENOMINATOR;
        }
        return circulating;
    }
    function _transfer(address from, address to, uint256 value) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        if (!ds.tradeEnabled) {
            if (!ds.isExemptFee[from] && !ds.isExemptFee[to]) {
                revert TradeNotYetEnabled();
            }
        }

        if (block.timestamp <= ds.tradeStartBlock + 2 && ds.isPairLP[from]) {
            revert AntiSniperActive();
        }

        if (ds.inSwap || ds.isExemptFee[from] || ds.isExemptFee[to]) {
            return _update(from, to, value);
        }
        if (
            from != ds.pair &&
            ds.isSwapEnabled &&
            ds.totalFeeCollected - ds.totalFeeRedeemed >= ds.minSwap &&
            balanceOf(address(this)) >= ds.minSwap
        ) {
            autoRedeem(ds.minSwap);
        }

        uint256 newValue = value;

        if (ds.isFeeActive && !ds.isExemptFee[from] && !ds.isExemptFee[to]) {
            newValue = _beforeTokenTransfer(from, to, value);
        }
        if (
            ds.limitEnabled &&
            !ds.isExemptLimit[to] &&
            balanceOf(to) + newValue > checkWalletLimit()
        ) {
            revert MaxWalletLimitExceed(
                balanceOf(to) + newValue,
                checkWalletLimit()
            );
        }

        _update(from, to, newValue);
    }
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address provider = msg.sender;
        _transfer(provider, to, value);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
    function _spendAllowance(
        address provider,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(provider, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(provider, spender, currentAllowance - value, false);
            }
        }
    }
    function allowance(
        address provider,
        address spender
    ) public view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[provider][spender];
    }
    function increaseAllowance(
        address spender,
        uint256 value
    ) external virtual returns (bool) {
        address provider = msg.sender;
        uint256 currentAllowance = allowance(provider, spender);
        _approve(provider, spender, currentAllowance + value, true);
        return true;
    }
    function _approve(
        address provider,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (provider == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        ds._allowances[provider][spender] = value;
        if (emitEvent) {
            emit Approval(provider, spender, value);
        }
    }
    function autoRedeem(uint256 amountToRedeem) internal swapping {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 totalToRedeem = ds.totalFeeCollected - ds.totalFeeRedeemed;

        if (amountToRedeem > totalToRedeem) {
            return;
        }
        uint256 marketingToRedeem = ds.collectedFee.marketing -
            ds.redeemedFee.marketing;

        uint256 marketingFeeDistribution = (amountToRedeem *
            marketingToRedeem) / totalToRedeem;

        ds.redeemedFee.marketing += marketingFeeDistribution;
        ds.totalFeeRedeemed += amountToRedeem;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.router.WETH();

        _approve(address(this), address(ds.router), amountToRedeem);

        emit AutoRedeem(
            marketingFeeDistribution,
            amountToRedeem,
            msg.sender,
            block.timestamp
        );

        ds.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            marketingFeeDistribution,
            0,
            path,
            ds.marketingReceiver,
            block.timestamp
        );
    }
    function manualRedeem(uint256 amountToRedeem) external swapping onlyOwner {
        if (amountToRedeem > (circulatingSupply() * 500) / FEEDENOMINATOR) {
            revert CannotRedeemMoreThanAllowedTreshold(
                amountToRedeem,
                (circulatingSupply() * 500) / FEEDENOMINATOR
            );
        }

        autoRedeem(amountToRedeem);
    }
    function enableTrade() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.tradeEnabled) {
            revert TradeAlreadyEnabled(
                ds.tradeEnabled,
                ds.tradeStartTime,
                ds.tradeStartBlock
            );
        }
        if (ds.tradeStartTime != 0 || ds.tradeStartBlock != 0) {
            revert AlreadyFinalized();
        }
        if (ds.isFeeActive) {
            revert AlreadyCurrentState("ds.isFeeActive", ds.isFeeActive);
        }
        if (ds.isSwapEnabled) {
            revert AlreadyCurrentState("ds.isSwapEnabled", ds.isSwapEnabled);
        }
        ds.tradeEnabled = true;
        ds.limitEnabled = true;
        ds.isFeeActive = true;
        ds.isSwapEnabled = true;
        ds.tradeStartTime = block.timestamp;
        ds.tradeStartBlock = block.timestamp;

        emit FinalizedPresale(msg.sender, block.timestamp);
    }
    function lockLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isLimitLocked) {
            revert LimitLocked();
        }
        ds.isLimitLocked = true;
        emit Lock("ds.isLimitLocked", msg.sender, block.timestamp);
    }
    function lockFees() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isFeeLocked) {
            revert FeeLocked();
        }
        ds.isFeeLocked = true;
        emit Lock("ds.isFeeLocked", msg.sender, block.timestamp);
    }
    function lockReceivers() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isReceiverLocked) {
            revert ReceiverLocked();
        }
        ds.isReceiverLocked = true;
        emit Lock("ds.isReceiverLocked", msg.sender, block.timestamp);
    }
    function removeLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isLimitLocked) {
            revert LimitLocked();
        }
        if (!ds.limitEnabled) {
            revert LimitAlreadyRemoved();
        }
        ds.limitEnabled = false;
        emit UpdateState(
            "ds.limitEnabled",
            true,
            false,
            msg.sender,
            block.timestamp
        );
    }
    function updateMinSwap(uint256 newMinSwap) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (newMinSwap > (circulatingSupply() * 10) / FEEDENOMINATOR) {
            revert InvalidValue(newMinSwap);
        }
        if (ds.minSwap == newMinSwap) {
            revert CannotUseCurrentValue(newMinSwap);
        }
        uint256 oldMinSwap = ds.minSwap;
        ds.minSwap = newMinSwap;
        emit UpdateMinSwap(oldMinSwap, newMinSwap, msg.sender, block.timestamp);
    }
    function updateFeeActive(bool newStatus) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isFeeLocked) {
            revert FeeLocked();
        }
        if (ds.isFeeActive == newStatus) {
            revert CannotUseCurrentState(newStatus);
        }
        bool oldStatus = ds.isFeeActive;
        ds.isFeeActive = newStatus;
        emit UpdateState(
            "ds.isFeeActive",
            oldStatus,
            newStatus,
            msg.sender,
            block.timestamp
        );
    }
    function updateSwapEnabled(bool newStatus) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isSwapEnabled == newStatus) {
            revert CannotUseCurrentState(newStatus);
        }
        bool oldStatus = ds.isSwapEnabled;
        ds.isSwapEnabled = newStatus;
        emit UpdateState(
            "ds.isSwapEnabled",
            oldStatus,
            newStatus,
            msg.sender,
            block.timestamp
        );
    }
    function updateBuyFee(uint256 newMarketingFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isFeeLocked) {
            revert FeeLocked();
        }
        if (newMarketingFee > 20_000) {
            revert InvalidTotalFee(newMarketingFee, 20_000);
        }
        if (newMarketingFee == ds.buyFee.marketing) {
            revert CannotUseAllCurrentValue();
        }
        uint256 oldMarketingFee = ds.buyFee.marketing;
        ds.buyFee.marketing = newMarketingFee;
        emit UpdateFee(
            "ds.buyFee - Marketing",
            oldMarketingFee,
            newMarketingFee,
            msg.sender,
            block.timestamp
        );
    }
    function updateSellFee(uint256 newMarketingFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isFeeLocked) {
            revert FeeLocked();
        }
        if (newMarketingFee > 20_000) {
            revert InvalidTotalFee(newMarketingFee, 20_000);
        }
        if (newMarketingFee == ds.sellFee.marketing) {
            revert CannotUseAllCurrentValue();
        }
        uint256 oldMarketingFee = ds.sellFee.marketing;
        ds.sellFee.marketing = newMarketingFee;
        emit UpdateFee(
            "ds.sellFee - Marketing",
            oldMarketingFee,
            newMarketingFee,
            msg.sender,
            block.timestamp
        );
    }
    function updateTransferFee(uint256 newMarketingFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isFeeLocked) {
            revert FeeLocked();
        }
        if (newMarketingFee > 20_000) {
            revert InvalidTotalFee(newMarketingFee, 20_000);
        }
        if (newMarketingFee == ds.transferFee.marketing) {
            revert CannotUseAllCurrentValue();
        }
        uint256 oldMarketingFee = ds.transferFee.marketing;
        ds.transferFee.marketing = newMarketingFee;
        emit UpdateFee(
            "ds.transferFee - Marketing",
            oldMarketingFee,
            newMarketingFee,
            msg.sender,
            block.timestamp
        );
    }
    function updateMarketingReceiver(
        address newMarketingReceiver
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isReceiverLocked) {
            revert ReceiverLocked();
        }
        if (newMarketingReceiver == address(0)) {
            revert InvalidAddress(address(0));
        }
        if (ds.marketingReceiver == newMarketingReceiver) {
            revert CannotUseCurrentAddress(newMarketingReceiver);
        }
        if (newMarketingReceiver.code.length > 0) {
            revert OnlyWalletAddressAllowed();
        }
        address oldMarketingReceiver = ds.marketingReceiver;
        ds.marketingReceiver = newMarketingReceiver;
        emit UpdateReceiver(
            "ds.marketingReceiver",
            oldMarketingReceiver,
            newMarketingReceiver,
            msg.sender,
            block.timestamp
        );
    }
    function setPairLP(address lpPair, bool newStatus) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isPairLP[lpPair] == newStatus) {
            revert CannotUseCurrentState(newStatus);
        }
        if (
            IPair(lpPair).token0() != address(this) &&
            IPair(lpPair).token1() != address(this)
        ) {
            revert InvalidAddress(lpPair);
        }
        bool oldStatus = ds.isPairLP[lpPair];
        ds.isPairLP[lpPair] = newStatus;
        emit SetAddressState(
            "ds.isPairLP",
            lpPair,
            oldStatus,
            newStatus,
            msg.sender,
            block.timestamp
        );
    }
    function updateRouter(address newRouter) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (newRouter == address(ds.router)) {
            revert CannotUseCurrentAddress(newRouter);
        }

        address oldRouter = address(ds.router);
        ds.router = IRouter(newRouter);

        emit UpdateRouter(oldRouter, newRouter, msg.sender, block.timestamp);

        if (
            address(
                IFactory(ds.router.factory()).getPair(
                    address(this),
                    ds.router.WETH()
                )
            ) == address(0)
        ) {
            ds.pair = IFactory(ds.router.factory()).createPair(
                address(this),
                ds.router.WETH()
            );
            if (!ds.isPairLP[ds.pair]) {
                ds.isPairLP[ds.pair] = true;
            }
        }
    }
    function updateExemptFee(address user, bool newStatus) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isExemptFee[user] == newStatus) {
            revert CannotUseCurrentState(newStatus);
        }
        bool oldStatus = ds.isExemptFee[user];
        ds.isExemptFee[user] = newStatus;
        emit SetAddressState(
            "ds.isExemptFee",
            user,
            oldStatus,
            newStatus,
            msg.sender,
            block.timestamp
        );
    }
    function updateExemptLimit(
        address user,
        bool newStatus
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isExemptLimit[user] == newStatus) {
            revert CannotUseCurrentState(newStatus);
        }
        bool oldStatus = ds.isExemptLimit[user];
        ds.isExemptLimit[user] = newStatus;
        emit SetAddressState(
            "ds.isExemptLimit",
            user,
            oldStatus,
            newStatus,
            msg.sender,
            block.timestamp
        );
    }
    function triggerZeusBuyback(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (amount > 5 ether) {
            revert InvalidValue(5 ether);
        }
        ds.totalTriggerZeusBuyback += amount;
        ds.lastTriggerZeusTimestamp = block.timestamp;
        buyTokens(amount, address(0xdead));
    }
    function transferOwnership(address newOwner) public override onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (newOwner == owner()) {
            revert CannotUseCurrentAddress(newOwner);
        }
        if (newOwner == address(0xdead)) {
            revert InvalidAddress(newOwner);
        }
        ds.projectOwner = newOwner;
        super.transferOwnership(newOwner);
    }
    function name() public view virtual returns (string memory) {
        return NAME;
    }
    function symbol() public view virtual returns (string memory) {
        return SYMBOL;
    }
    function decimals() public view virtual returns (uint8) {
        return DECIMALS;
    }
    function buyTokens(uint256 amount, address to) internal swapping {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (msg.sender == address(0xdead)) {
            revert InvalidAddress(address(0xdead));
        }
        address[] memory path = new address[](2);
        path[0] = ds.router.WETH();
        path[1] = address(this);

        ds.router.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(0, path, to, block.timestamp);
    }
    function approve(
        address spender,
        uint256 value
    ) public virtual returns (bool) {
        address provider = msg.sender;
        _approve(provider, spender, value);
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 value
    ) external virtual returns (bool) {
        address provider = msg.sender;
        uint256 currentAllowance = allowance(provider, spender);
        if (currentAllowance < value) {
            revert ERC20InsufficientAllowance(spender, currentAllowance, value);
        }
        unchecked {
            _approve(provider, spender, currentAllowance - value, true);
        }
        return true;
    }
    function _update(address from, address to, uint256 value) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (from == address(0)) {
            ds._totalSupply += value;
        } else {
            uint256 fromBalance = ds._balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                ds._balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                ds._totalSupply -= value;
            }
        } else {
            unchecked {
                ds._balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }
    function tallyFee(
        TestLib.Fee memory feeType,
        address from,
        uint256 amount,
        uint256 fee
    ) internal swapping {
        uint256 collectMarketing = (amount * feeType.marketing) / fee;
        tallyCollection(collectMarketing, amount);

        _update(from, address(this), amount);
    }
    function takeFee(
        TestLib.Fee memory feeType,
        address from,
        uint256 amount
    ) internal swapping returns (uint256) {
        uint256 feeTotal = feeType.marketing;
        uint256 feeAmount = (amount * feeTotal) / FEEDENOMINATOR;
        uint256 newAmount = amount - feeAmount;
        if (feeAmount > 0) {
            tallyFee(feeType, from, feeAmount, feeTotal);
        }
        return newAmount;
    }
    function takeBuyFee(
        address from,
        uint256 amount
    ) internal swapping returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return takeFee(ds.buyFee, from, amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual swapping returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isPairLP[from] && (ds.buyFee.marketing > 0)) {
            return takeBuyFee(from, amount);
        }
        if (ds.isPairLP[to] && (ds.sellFee.marketing > 0)) {
            return takeSellFee(from, amount);
        }
        if (
            !ds.isPairLP[from] &&
            !ds.isPairLP[to] &&
            (ds.transferFee.marketing > 0)
        ) {
            return takeTransferFee(from, amount);
        }
        return amount;
    }
    function takeSellFee(
        address from,
        uint256 amount
    ) internal swapping returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return takeFee(ds.sellFee, from, amount);
    }
    function takeTransferFee(
        address from,
        uint256 amount
    ) internal swapping returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return takeFee(ds.transferFee, from, amount);
    }
    function tallyCollection(
        uint256 collectMarketing,
        uint256 amount
    ) internal swapping {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.collectedFee.marketing += collectMarketing;
        ds.totalFeeCollected += amount;
    }
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }
}
