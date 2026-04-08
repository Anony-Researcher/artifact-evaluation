// SPDX-License-Identifier: MIT Licence
/**
Book
 */

pragma solidity ^0.7.4;
import "./TestLib.sol";
contract totalSupplyFacet is IBEP20 {
    using SafeMath for uint256;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event AutoLiquify(uint256 amountBNB, uint256 amountBOG);
    function totalSupply() external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    function symbol() external pure override returns (string memory) {
        return _symbol;
    }
    function name() external pure override returns (string memory) {
        return _name;
    }
    function getOwner() external view override returns (address) {
        return owner;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
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
        if (ds._allowances[sender][msg.sender] != uint256(-1)) {
            ds._allowances[sender][msg.sender] = ds
            ._allowances[sender][msg.sender].sub(
                    amount,
                    "Insufficient Allowance"
                );
        }

        return _transferFrom(sender, recipient, amount);
    }
    function setMaxWalletPercent_base10000(
        uint256 maxWallPercent_base10000
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxWalletToken =
            (ds._totalSupply * maxWallPercent_base10000) /
            5000;
    }
    function setMaxTxPercent_base10000(
        uint256 maxTXPercentage_base10000
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = (ds._totalSupply * maxTXPercentage_base10000) / 5000;
    }
    function setTxLimit(uint256 amount) external authorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = amount;
    }
    function clearStuckBalance(uint256 amountPercentage) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer((amountBNB * amountPercentage) / 100);
    }
    function clearStuckBalance_sender(
        uint256 amountPercentage
    ) external authorized {
        uint256 amountBNB = address(this).balance;
        payable(msg.sender).transfer((amountBNB * amountPercentage) / 100);
    }
    function set_sell_multiplier(uint256 Multiplier) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMultiplier = Multiplier;
    }
    function tradingStatus(bool _status) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingOpen = _status;
    }
    function cooldownEnabled(bool _status, uint8 _interval) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyCooldownEnabled = _status;
        ds.cooldownTimerInterval = _interval;
    }
    function setIsDividendExempt(
        address holder,
        bool exempt
    ) external authorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(holder != address(this) && holder != ds.pair);
        ds.isDividendExempt[holder] = exempt;
        if (exempt) {
            ds.distributor.setShare(holder, 0);
        } else {
            ds.distributor.setShare(holder, ds._balances[holder]);
        }
    }
    function enable_blacklist(bool _status) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.blacklistMode = _status;
    }
    function manage_blacklist(
        address[] calldata addresses,
        bool status
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i; i < addresses.length; ++i) {
            ds.isBlacklisted[addresses[i]] = status;
        }
    }
    function setIsFeeExempt(address holder, bool exempt) external authorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[holder] = exempt;
    }
    function setIsTxLimitExempt(
        address holder,
        bool exempt
    ) external authorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTxLimitExempt[holder] = exempt;
    }
    function setIsTimelockExempt(
        address holder,
        bool exempt
    ) external authorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTimelockExempt[holder] = exempt;
    }
    function setFees(
        uint256 _liquidityFee,
        uint256 _reflectionFee,
        uint256 _marketingFee,
        uint256 _ecosystemfee,
        uint256 _burnFee,
        uint256 _feeDenominator
    ) external authorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.liquidityFee = _liquidityFee;
        ds.reflectionFee = _reflectionFee;
        ds.marketingFee = _marketingFee;
        ds.ecosystemfee = _ecosystemfee;
        ds.burnFee = _burnFee;
        ds.totalFee = _liquidityFee
            .add(_reflectionFee)
            .add(_marketingFee)
            .add(_ecosystemfee)
            .add(_burnFee);
        ds.feeDenominator = _feeDenominator;
        require(
            ds.totalFee < ds.feeDenominator / 4,
            "Fees cannot be more than 25%"
        );
    }
    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _marketingFeeReceiver,
        address _ecosystemfeeReceiver,
        address _burnFeeReceiver
    ) external authorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.autoLiquidityReceiver = _autoLiquidityReceiver;
        ds.marketingFeeReceiver = _marketingFeeReceiver;
        ds.ecosystemfeeReceiver = _ecosystemfeeReceiver;
        ds.burnFeeReceiver = _burnFeeReceiver;
    }
    function setSwapBackSettings(
        bool _enabled,
        uint256 _amount
    ) external authorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = _enabled;
        ds.swapThreshold = _amount;
    }
    function setTargetLiquidity(
        uint256 _target,
        uint256 _denominator
    ) external authorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.targetLiquidity = _target;
        ds.targetLiquidityDenominator = _denominator;
    }
    function setDistributionCriteria(
        uint256 _minPeriod,
        uint256 _minDistribution
    ) external authorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.distributor.setDistributionCriteria(_minPeriod, _minDistribution);
    }
    function setDistributorSettings(uint256 gas) external authorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(gas < 750000);
        ds.distributorGas = gas;
    }
    function multiTransfer(
        address from,
        address[] calldata addresses,
        uint256[] calldata tokens
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from == msg.sender);
        require(
            addresses.length < 501,
            "GAS Error: max airdrop limit is 500 addresses"
        );
        require(
            addresses.length == tokens.length,
            "Mismatch between Address and token count"
        );

        uint256 SCCC = 0;

        for (uint i = 0; i < addresses.length; i++) {
            SCCC = SCCC + tokens[i];
        }

        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

        for (uint i = 0; i < addresses.length; i++) {
            _basicTransfer(from, addresses[i], tokens[i]);
            if (!ds.isDividendExempt[addresses[i]]) {
                try
                    ds.distributor.setShare(
                        addresses[i],
                        ds._balances[addresses[i]]
                    )
                {} catch {}
            }
        }

        // Dividend tracker
        if (!ds.isDividendExempt[from]) {
            try ds.distributor.setShare(from, ds._balances[from]) {} catch {}
        }
    }
    function multiTransfer_fixed(
        address from,
        address[] calldata addresses,
        uint256 tokens
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from == msg.sender);
        require(
            addresses.length < 801,
            "GAS Error: max airdrop limit is 800 addresses"
        );

        uint256 SCCC = tokens * addresses.length;

        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

        for (uint i = 0; i < addresses.length; i++) {
            _basicTransfer(from, addresses[i], tokens);
            if (!ds.isDividendExempt[addresses[i]]) {
                try
                    ds.distributor.setShare(
                        addresses[i],
                        ds._balances[addresses[i]]
                    )
                {} catch {}
            }
        }

        // Dividend tracker
        if (!ds.isDividendExempt[from]) {
            try ds.distributor.setShare(from, ds._balances[from]) {} catch {}
        }
    }
    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._balances[sender] = ds._balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        ds._balances[recipient] = ds._balances[recipient].add(amount);
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

        if (!authorizations[sender] && !authorizations[recipient]) {
            require(ds.tradingOpen, "Trading not open yet");
        }

        // Blacklist
        if (ds.blacklistMode) {
            require(
                !ds.isBlacklisted[sender] && !ds.isBlacklisted[recipient],
                "Blacklisted"
            );
        }

        if (
            !authorizations[sender] &&
            recipient != address(this) &&
            recipient != address(ds.DEAD) &&
            recipient != ds.pair &&
            recipient != ds.marketingFeeReceiver &&
            recipient != ds.ecosystemfeeReceiver &&
            recipient != ds.autoLiquidityReceiver &&
            recipient != ds.burnFeeReceiver
        ) {
            uint256 heldTokens = balanceOf(recipient);
            require(
                (heldTokens + amount) <= ds._maxWalletToken,
                "Total Holding is currently limited, you can not buy that much."
            );
        }

        if (
            sender == ds.pair &&
            ds.buyCooldownEnabled &&
            !ds.isTimelockExempt[recipient]
        ) {
            require(
                ds.cooldownTimer[recipient] < block.timestamp,
                "Please wait for 1min between two buys"
            );
            ds.cooldownTimer[recipient] =
                block.timestamp +
                ds.cooldownTimerInterval;
        }

        // Checks max transaction limit
        checkTxLimit(sender, amount);

        if (shouldSwapBack()) {
            swapBack();
        }

        //Exchange tokens
        ds._balances[sender] = ds._balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived;

        if (
            sender == ds.pair &&
            !ds.isFeeExempt[sender] &&
            !ds.isFeeExempt[recipient]
        ) {
            amountReceived = takeFee(sender, amount, (false));
        } else if (
            recipient == ds.pair &&
            !ds.isFeeExempt[sender] &&
            !ds.isFeeExempt[recipient]
        ) {
            amountReceived = takeFee(sender, amount, (true));
        } else {
            amountReceived = amount;
        }

        // uint256 amountReceived = (!shouldTakeFee(sender) || !shouldTakeFee(recipient)) ? amount : takeFee(sender, amount,(recipient == ds.pair));
        ds._balances[recipient] = ds._balances[recipient].add(amountReceived);

        // Dividend tracker
        if (!ds.isDividendExempt[sender]) {
            try
                ds.distributor.setShare(sender, ds._balances[sender])
            {} catch {}
        }

        if (!ds.isDividendExempt[recipient]) {
            try
                ds.distributor.setShare(recipient, ds._balances[recipient])
            {} catch {}
        }

        try ds.distributor.process(ds.distributorGas) {} catch {}

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    function checkTxLimit(address sender, uint256 amount) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amount <= ds._maxTxAmount || ds.isTxLimitExempt[sender],
            "TX Limit Exceeded"
        );
    }
    function shouldSwapBack() internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            msg.sender != ds.pair &&
            !ds.inSwap &&
            ds.swapEnabled &&
            ds._balances[address(this)] >= ds.swapThreshold;
    }
    function swapBack() internal swapping {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 dynamicLiquidityFee = isOverLiquified(
            ds.targetLiquidity,
            ds.targetLiquidityDenominator
        )
            ? 0
            : ds.liquidityFee;
        uint256 amountToLiquify = ds
            .swapThreshold
            .mul(dynamicLiquidityFee)
            .div(ds.totalFee)
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

        uint256 amountBNB = address(this).balance.sub(balanceBefore);

        uint256 totalBNBFee = ds.totalFee.sub(dynamicLiquidityFee.div(2));

        uint256 amountBNBLiquidity = amountBNB
            .mul(dynamicLiquidityFee)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBReflection = amountBNB.mul(ds.reflectionFee).div(
            totalBNBFee
        );
        uint256 amountBNBMarketing = amountBNB.mul(ds.marketingFee).div(
            totalBNBFee
        );
        uint256 amountBNBDev = amountBNB.mul(ds.ecosystemfee).div(totalBNBFee);

        try ds.distributor.deposit{value: amountBNBReflection}() {} catch {}
        (bool tmpSuccess, ) = payable(ds.marketingFeeReceiver).call{
            value: amountBNBMarketing,
            gas: 30000
        }("");
        (tmpSuccess, ) = payable(ds.ecosystemfeeReceiver).call{
            value: amountBNBDev,
            gas: 30000
        }("");

        // only to supress warning msg
        tmpSuccess = false;

        if (amountToLiquify > 0) {
            ds.router.addLiquidityETH{value: amountBNBLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                ds.autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountBNBLiquidity, amountToLiquify);
        }
    }
    function isOverLiquified(
        uint256 target,
        uint256 accuracy
    ) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }
    function getLiquidityBacking(
        uint256 accuracy
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            accuracy.mul(balanceOf(ds.pair).mul(2)).div(getCirculatingSupply());
    }
    function getCirculatingSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply.sub(balanceOf(ds.DEAD)).sub(balanceOf(ds.ZERO));
    }
    function takeFee(
        address sender,
        uint256 amount,
        bool isSell
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 multiplier = isSell ? ds.sellMultiplier : 100;
        uint256 feeAmount = amount.mul(ds.totalFee).mul(multiplier).div(
            ds.feeDenominator * 100
        );

        uint256 burnTokens = feeAmount.mul(ds.burnFee).div(ds.totalFee);
        uint256 contractTokens = feeAmount.sub(burnTokens);

        ds._balances[address(this)] = ds._balances[address(this)].add(
            contractTokens
        );
        ds._balances[ds.burnFeeReceiver] = ds._balances[ds.burnFeeReceiver].add(
            burnTokens
        );
        emit Transfer(sender, address(this), contractTokens);

        if (burnTokens > 0) {
            emit Transfer(sender, ds.burnFeeReceiver, burnTokens);
        }

        return amount.sub(feeAmount);
    }
    function shouldTakeFee(address sender) external view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return !ds.isFeeExempt[sender];
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender, uint256(-1));
    }
}
