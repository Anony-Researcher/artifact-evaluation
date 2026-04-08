/**
 *Submitted for verification at Etherscan.io on 2023-11-19
 */

//SPDX-License-Identifier: Unlicensed

/* 

 _______  _______  _______  ___  
|       ||       ||       ||   | 
|    _  ||    ___||    _  ||   | 
|   |_| ||   |___ |   |_| ||   | 
|    ___||    ___||    ___||   | 
|   |    |   |___ |   |    |   | 
|___|    |_______||___|    |___| 

*/

pragma solidity 0.8.21;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Ownable {
    using SafeMath for uint256;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event ClearToken(address tokenAddress, uint256 tokens);
    event set_MaxWallet(uint256 maxWallet);
    event set_MaxTransaction(uint256 maxTXAmount);
    event set_Receivers(
        address marketingReceiver,
        address teamReceiver,
        address autoLPReceiver
    );
    event AutoLiquify(uint256 amountETH, uint256 amountTokens);
    event Reflect(uint256 amountReflected, uint256 newTotalProportion);
    event ClearStuck(uint256 amount);
    function totalSupply() external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return tokenFromReflection(ds._rOwned[account]);
    }
    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[holder][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._allowances[sender][msg.sender] != type(uint256).max) {
            ds._allowances[sender][msg.sender] = ds
            ._allowances[sender][msg.sender].sub(
                    amount,
                    "Insufficient Allowance"
                );
        }

        return _transferFrom(sender, recipient, amount);
    }
    function clearForeignToken(
        address tokenAddress,
        uint256 tokens
    ) external onlyOwner returns (bool) {
        require(
            tokenAddress != address(this),
            "Owner cannot claim native tokens"
        );
        if (tokens == 0) {
            tokens = IERC20(tokenAddress).balanceOf(address(this));
        }
        emit ClearToken(tokenAddress, tokens);
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxWalletSize = ds._totalSupply;
        ds._maxTxAmount = ds._totalSupply;
    }
    function multiSendTokens(
        address[] memory accounts,
        uint256[] memory amounts
    ) external onlyOwner {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint16 i = 0; i < accounts.length; i++) {
            require(balanceOf(msg.sender) >= amounts[i], "Not enough tokens.");
            _basicTransfer(msg.sender, accounts[i], amounts[i]);
        }
    }
    function setSwapThreshold(
        bool _enabled,
        uint256 _amountS,
        uint256 _amountL,
        bool _alternate
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _amountS < (ds._totalSupply / 50),
            "Cannot set swap amount above 2%"
        );
        require(
            _amountS > (ds._totalSupply / 100000),
            "Cannot set swap amount below 0.001%"
        );
        require(
            _amountL < (ds._totalSupply / 50),
            "Cannot set swap amount above 2%"
        );
        require(
            _amountL > (ds._totalSupply / 100000),
            "Cannot set swap amount below 0.001%"
        );
        ds.alternateSwaps = _alternate;
        ds.claimingFees = _enabled;
        ds.smallSwapThreshold = _amountS;
        ds.largeSwapThreshold = _amountL;
        ds.swapThreshold = ds.smallSwapThreshold;

        emit set_SellAmounts(
            ds.alternateSwaps,
            ds.claimingFees,
            ds.smallSwapThreshold,
            ds.largeSwapThreshold
        );
    }
    function enableTrading() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen);
        ds.tradingOpen = true;
    }
    function disableTrading() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.tradingOpen);
        ds.tradingOpen = false;
    }
    function setFees(
        uint256 _liquidityFeeBuy,
        uint256 _reflectionFeeBuy,
        uint256 _marketingFeeBuy,
        uint256 _TeamFeeBuy,
        uint256 _feeDenominator,
        uint256 _liquidityFeeSell,
        uint256 _reflectionFeeSell,
        uint256 _marketingFeeSell,
        uint256 _TeamFeeSell
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.liquidityFeeBuy = _liquidityFeeBuy;
        ds.reflectionFeeBuy = _reflectionFeeBuy;
        ds.marketingFeeBuy = _marketingFeeBuy;
        ds.TeamFeeBuy = _TeamFeeBuy;
        ds.totalFeeBuy = ds
            .liquidityFeeBuy
            .add(ds.reflectionFeeBuy)
            .add(ds.marketingFeeBuy)
            .add(ds.TeamFeeBuy);

        ds.liquidityFeeSell = _liquidityFeeSell;
        ds.reflectionFeeSell = _reflectionFeeSell;
        ds.marketingFeeSell = _marketingFeeSell;
        ds.TeamFeeSell = _TeamFeeSell;
        ds.totalFeeSell = ds
            .liquidityFeeSell
            .add(ds.reflectionFeeSell)
            .add(ds.marketingFeeSell)
            .add(ds.TeamFeeSell);

        ds.feeDenominator = _feeDenominator;

        require(
            ds.totalFeeBuy <= ds.feeDenominator / 1,
            "Cannot set buy fees above 20%"
        );
        require(
            ds.totalFeeSell <= ds.feeDenominator / 1,
            "Cannot set sell fees above 20%"
        );
    }
    function updateMaxWallet(uint256 maxWalletHolding) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(maxWalletHolding >= 1);
        ds._maxWalletSize = (ds._totalSupply * maxWalletHolding) / 1000;
        emit set_MaxWallet(ds._maxWalletSize);
    }
    function updateMaxTransaction(
        uint256 maxTransactionSize
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(maxTransactionSize >= 1, "Cannot set max TX below .1%");
        ds._maxTxAmount = (ds._totalSupply * maxTransactionSize) / 1000;
        emit set_MaxTransaction(ds._maxTxAmount);
    }
    function addTaxExemption(
        address[] calldata addresses,
        bool status
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i; i < addresses.length; ++i) {
            ds.isFeeExempt[addresses[i]] = status;
        }
    }
    function addTXLimitExemption(
        address[] calldata addresses,
        bool status
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i; i < addresses.length; ++i) {
            ds.isTxLimitExempt[addresses[i]] = status;
        }
    }
    function addCooldownExempt(address holder, bool exempt) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isCooldownExempt[holder] = exempt;
    }
    function setPresaleAddress(address holder, bool exempt) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[holder] = exempt;
        ds.isTxLimitExempt[holder] = exempt;
    }
    function setTaxReceivers(
        address _marketingReceiver,
        address _autoLPReceiver,
        address _TeamReceiver
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingReceiver = _marketingReceiver;
        ds.teamReceiver = _TeamReceiver;
        ds.autoLPReceiver = _autoLPReceiver;

        emit set_Receivers(
            ds.marketingReceiver,
            ds.teamReceiver,
            ds.autoLPReceiver
        );
    }
    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 proportionAmount = tokensToProportion(amount);
        ds._rOwned[sender] = ds._rOwned[sender].sub(
            proportionAmount,
            "Insufficient Balance"
        );
        ds._rOwned[recipient] = ds._rOwned[recipient].add(proportionAmount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (
            recipient != ds.pair &&
            recipient != DEAD &&
            recipient != ds.marketingReceiver &&
            !ds.isTxLimitExempt[recipient]
        ) {
            require(
                balanceOf(recipient) + amount <= ds._maxWalletSize,
                "Max Wallet Exceeded"
            );

            if (
                sender == ds.pair &&
                ds.buyCooldownEnabled &&
                !ds.isCooldownExempt[recipient]
            ) {
                require(
                    ds.CooldownTimer[recipient] < block.timestamp,
                    "Please wait for between buys"
                );
                ds.CooldownTimer[recipient] =
                    block.timestamp +
                    ds.CooldownTimerInterval;
            }
        }

        if (!ds.isTxLimitExempt[sender]) {
            require(amount <= ds._maxTxAmount, "Transaction Amount Exceeded");
        }

        if (
            recipient != ds.pair &&
            recipient != DEAD &&
            !ds.isTxLimitExempt[recipient]
        ) {
            require(ds.tradingOpen, "Trading not open yet");
        }

        if (shouldSwapBack()) {
            swapBack();
        }

        uint256 proportionAmount = tokensToProportion(amount);

        ds._rOwned[sender] = ds._rOwned[sender].sub(
            proportionAmount,
            "Insufficient Balance"
        );

        uint256 proportionReceived = shouldTakeFee(sender) &&
            shouldTakeFee(recipient)
            ? takeFeeInProportions(
                sender == ds.pair ? true : false,
                sender,
                recipient,
                proportionAmount
            )
            : proportionAmount;
        ds._rOwned[recipient] = ds._rOwned[recipient].add(proportionReceived);

        emit Transfer(
            sender,
            recipient,
            tokenFromReflection(proportionReceived)
        );
        return true;
    }
    function shouldSwapBack() internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            msg.sender != ds.pair &&
            !ds.inSwap &&
            ds.claimingFees &&
            balanceOf(address(this)) >= ds.swapThreshold;
    }
    function swapBack() internal swapping {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 dynamicLiquidityFee = isOverLiquified(
            ds.targetLiquidity,
            ds.targetLiquidityDenominator
        )
            ? 0
            : ds.liquidityFeeSell;
        uint256 _totalFee = ds.totalFeeSell.sub(ds.reflectionFeeSell);
        uint256 amountToLiquify = ds
            .swapThreshold
            .mul(dynamicLiquidityFee)
            .div(_totalFee)
            .div(2);
        uint256 amountToSwap = ds.swapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.WETH;

        uint256 balanceBefore = address(this).balance;

        ds.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance.sub(balanceBefore);
        uint256 totalETHFee = _totalFee.sub(dynamicLiquidityFee.div(2));
        uint256 amountETHLiquidity = amountETH
            .mul(ds.liquidityFeeSell)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHMarketing = amountETH.mul(ds.marketingFeeSell).div(
            totalETHFee
        );
        uint256 amountETHTeam = amountETH.mul(ds.TeamFeeSell).div(totalETHFee);

        (bool tmpSuccess, ) = payable(ds.marketingReceiver).call{
            value: amountETHMarketing
        }("");
        (tmpSuccess, ) = payable(ds.teamReceiver).call{value: amountETHTeam}(
            ""
        );

        if (amountToLiquify > 0) {
            ds.router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                ds.autoLPReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }

        ds.swapThreshold = !ds.alternateSwaps
            ? ds.swapThreshold
            : ds.swapThreshold == ds.smallSwapThreshold
                ? ds.largeSwapThreshold
                : ds.smallSwapThreshold;
    }
    function isOverLiquified(
        uint256 target,
        uint256 accuracy
    ) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
    function getLiquidityBacking(
        uint256 accuracy
    ) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            accuracy.mul(balanceOf(ds.pair).mul(2)).div(getCirculatingSupply());
    }
    function getCirculatingSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(ZERO));
    }
    function tokensToProportion(uint256 tokens) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return tokens.mul(ds._totalProportion).div(ds._totalSupply);
    }
    function shouldTakeFee(address sender) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return !ds.isFeeExempt[sender];
    }
    function takeFeeInProportions(
        bool buying,
        address sender,
        address receiver,
        uint256 proportionAmount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 proportionFeeAmount = buying == true
            ? proportionAmount.mul(getTotalFeeBuy(receiver == ds.pair)).div(
                ds.feeDenominator
            )
            : proportionAmount.mul(getTotalFeeSell(receiver == ds.pair)).div(
                ds.feeDenominator
            );

        uint256 proportionReflected = buying == true
            ? proportionFeeAmount.mul(ds.reflectionFeeBuy).div(ds.totalFeeBuy)
            : proportionFeeAmount.mul(ds.reflectionFeeSell).div(
                ds.totalFeeSell
            );

        ds._totalProportion = ds._totalProportion.sub(proportionReflected);

        uint256 _proportionToContract = proportionFeeAmount.sub(
            proportionReflected
        );
        ds._rOwned[address(this)] = ds._rOwned[address(this)].add(
            _proportionToContract
        );

        emit Transfer(
            sender,
            address(this),
            tokenFromReflection(_proportionToContract)
        );
        emit Reflect(proportionReflected, ds._totalProportion);
        return proportionAmount.sub(proportionFeeAmount);
    }
    function getTotalFeeBuy(bool) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.totalFeeBuy;
    }
    function getTotalFeeSell(bool) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.totalFeeSell;
    }
    function tokenFromReflection(
        uint256 proportion
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return proportion.mul(ds._totalSupply).div(ds._totalProportion);
    }
    function clearStuckETH(uint256 amountPercentage) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 amountETH = address(this).balance;
        payable(ds.teamReceiver).transfer((amountETH * amountPercentage) / 100);

        emit ClearStuck(amountPercentage);
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }
}
