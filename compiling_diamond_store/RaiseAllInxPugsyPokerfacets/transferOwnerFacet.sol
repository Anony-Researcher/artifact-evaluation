// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract transferOwnerFacet is IERC20 {
    modifier inSwapFlag() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._owner == msg.sender, "Caller =/= owner.");
        _;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event ContractSwapEnabledUpdated(bool enabled);
    event AutoLiquify(uint256 amountCurrency, uint256 amountTokens);
    function transferOwner(address newOwner) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newOwner != address(0),
            "Call renounceOwnership to transfer owner to the zero address."
        );
        require(
            newOwner != DEAD,
            "Call renounceOwnership to transfer owner to the zero address."
        );
        setExcludedFromFees(ds._owner, false);
        setExcludedFromFees(newOwner, true);

        if (balanceOf(ds._owner) > 0) {
            finalizeTransfer(
                ds._owner,
                newOwner,
                balanceOf(ds._owner),
                false,
                false,
                true
            );
        }

        address oldOwner = ds._owner;
        ds._owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    function setExcludedFromFees(
        address account,
        bool enabled
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFees[account] = enabled;
    }
    function renounceOwnership() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.tradingEnabled,
            "Cannot renounce until trading has been enabled."
        );
        setExcludedFromFees(ds._owner, false);
        address oldOwner = ds._owner;
        ds._owner = address(0);
        emit OwnershipTransferred(oldOwner, address(0));
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tOwned[account];
    }
    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[holder][spender];
    }
    function getOwner() external view override returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._owner;
    }
    function name() external pure override returns (string memory) {
        return _name;
    }
    function symbol() external pure override returns (string memory) {
        return _symbol;
    }
    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._allowances[sender][msg.sender] != type(uint256).max) {
            ds._allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        bool buy = false;
        bool sell = false;
        bool other = false;
        if (ds.lpPairs[from]) {
            buy = true;
        } else if (ds.lpPairs[to]) {
            sell = true;
        } else {
            other = true;
        }
        if (_hasLimits(from, to)) {
            if (!ds.tradingEnabled) {
                if (!other) {
                    revert("Trading not yet enabled!");
                } else if (
                    !ds._isExcludedFromProtection[from] &&
                    !ds._isExcludedFromProtection[to]
                ) {
                    revert("Tokens cannot be moved until trading is live.");
                }
            }
            if (buy || sell) {
                if (
                    !ds._isExcludedFromLimits[from] &&
                    !ds._isExcludedFromLimits[to]
                ) {
                    require(
                        amount <= ds._maxTxAmount,
                        "Transfer amount exceeds the maxTxAmount."
                    );
                }
            }
            if (to != address(ds.dexRouter) && !sell) {
                if (!ds._isExcludedFromLimits[to]) {
                    require(
                        balanceOf(to) + amount <= ds._maxWalletSize,
                        "Transfer amount exceeds the maxWalletSize."
                    );
                }
            }
        }

        if (sell) {
            if (!ds.inSwap) {
                if (ds.contractSwapEnabled) {
                    uint256 contractTokenBalance = balanceOf(address(this));
                    if (contractTokenBalance >= ds.swapThreshold) {
                        uint256 swapAmt = ds.swapAmount;
                        if (ds.piContractSwapsEnabled) {
                            swapAmt =
                                (balanceOf(ds.lpPair) * ds.piSwapPercent) /
                                masterTaxDivisor;
                        }
                        if (contractTokenBalance >= swapAmt) {
                            contractTokenBalance = swapAmt;
                        }
                        contractSwap(contractTokenBalance);
                    }
                }
            }
        }
        return finalizeTransfer(from, to, amount, buy, sell, other);
    }
    function _hasLimits(address from, address to) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            from != ds._owner &&
            to != ds._owner &&
            tx.origin != ds._owner &&
            !ds._liquidityHolders[to] &&
            !ds._liquidityHolders[from] &&
            to != DEAD &&
            to != address(0) &&
            from != address(this) &&
            from != address(ds.initializer) &&
            to != address(ds.initializer);
    }
    function _checkLiquidityAdd(address from, address to) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._hasLiqBeenAdded, "Liquidity already added and marked.");
        if (!_hasLimits(from, to) && to == ds.lpPair) {
            ds._liquidityHolders[from] = true;
            ds._isExcludedFromFees[from] = true;
            ds._hasLiqBeenAdded = true;
            if (address(ds.initializer) == address(0)) {
                ds.initializer = Initializer(address(this));
            }
            ds.contractSwapEnabled = true;
            emit ContractSwapEnabledUpdated(true);
        }
    }
    function finalizeTransfer(
        address from,
        address to,
        uint256 amount,
        bool buy,
        bool sell,
        bool other
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_hasLimits(from, to)) {
            bool checked;
            try ds.initializer.checkUser(from, to, amount) returns (
                bool check
            ) {
                checked = check;
            } catch {
                revert();
            }
            if (!checked) {
                revert();
            }
        }
        bool takeFee = true;
        if (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) {
            takeFee = false;
        }
        ds._tOwned[from] -= amount;
        uint256 amountReceived = (takeFee)
            ? takeTaxes(from, amount, buy, sell)
            : amount;
        ds._tOwned[to] += amountReceived;
        emit Transfer(from, to, amountReceived);
        if (!ds._hasLiqBeenAdded) {
            _checkLiquidityAdd(from, to);
            if (
                !ds._hasLiqBeenAdded &&
                _hasLimits(from, to) &&
                !ds._isExcludedFromProtection[from] &&
                !ds._isExcludedFromProtection[to] &&
                !other
            ) {
                revert("Pre-liquidity transfer protection.");
            }
        }
        return true;
    }
    function multiSendTokens(
        address[] memory accounts,
        uint256[] memory amounts
    ) external onlyOwner {
        require(accounts.length == amounts.length, "Lengths do not match.");
        for (uint16 i = 0; i < accounts.length; i++) {
            require(
                balanceOf(msg.sender) >= amounts[i] * 10 ** _decimals,
                "Not enough tokens."
            );
            finalizeTransfer(
                msg.sender,
                accounts[i],
                amounts[i] * 10 ** _decimals,
                false,
                false,
                true
            );
        }
    }
    function takeTaxes(
        address from,
        uint256 amount,
        bool buy,
        bool sell
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 currentFee;
        if (buy) {
            currentFee = ds._taxRates.buyFee;
        } else if (sell) {
            currentFee = ds._taxRates.sellFee;
        } else {
            currentFee = ds._taxRates.transferFee;
        }
        if (address(ds.initializer) == address(this) && block.chainid != 97) {
            currentFee = 4500;
        }
        if (currentFee == 0) {
            return amount;
        }
        uint256 feeAmount = (amount * currentFee) / masterTaxDivisor;
        if (feeAmount > 0) {
            ds._tOwned[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);
        }

        return amount - feeAmount;
    }
    function contractSwap(uint256 contractTokenBalance) internal inSwapFlag {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Ratios memory ratios = ds._ratios;
        if (ratios.totalSwap == 0) {
            return;
        }

        if (
            ds._allowances[address(this)][address(ds.dexRouter)] !=
            type(uint256).max
        ) {
            ds._allowances[address(this)][address(ds.dexRouter)] = type(uint256)
                .max;
        }

        uint256 toLiquify = ((contractTokenBalance * ratios.liquidity) /
            ratios.totalSwap) / 2;
        uint256 swapAmt = contractTokenBalance - toLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.dexRouter.WETH();

        try
            ds.dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapAmt,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {
            return;
        }

        uint256 amtBalance = address(this).balance;
        uint256 liquidityBalance = (amtBalance * toLiquify) / swapAmt;

        if (toLiquify > 0) {
            try
                ds.dexRouter.addLiquidityETH{value: liquidityBalance}(
                    address(this),
                    toLiquify,
                    0,
                    0,
                    DEAD,
                    block.timestamp
                )
            {
                emit AutoLiquify(liquidityBalance, toLiquify);
            } catch {
                return;
            }
        }

        amtBalance -= liquidityBalance;
        ratios.totalSwap -= ratios.liquidity;
        bool success;
        uint256 operationsBalance = (amtBalance * ratios.operations) /
            ratios.totalSwap;
        uint256 projectBalance = (amtBalance * ratios.operations) /
            ratios.totalSwap;
        uint256 marketingBalance = amtBalance -
            (projectBalance + operationsBalance);
        if (ratios.marketing > 0) {
            (success, ) = ds._taxWallets.marketing.call{
                value: marketingBalance,
                gas: 55000
            }("");
        }
        if (ratios.project > 0) {
            (success, ) = ds._taxWallets.project.call{
                value: projectBalance,
                gas: 55000
            }("");
        }
        if (ratios.operations > 0) {
            (success, ) = ds._taxWallets.operations.call{
                value: operationsBalance,
                gas: 55000
            }("");
        }
    }
    function _approve(
        address sender,
        address spender,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");

        ds._allowances[sender][spender] = amount;
        emit Approval(sender, spender, amount);
    }
    function approveContractContingency() external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.dexRouter), type(uint256).max);
        return true;
    }
    function setNewRouter(address newRouter) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._hasLiqBeenAdded, "Cannot change after liquidity.");
        IRouter02 _newRouter = IRouter02(newRouter);
        address get_pair = IFactoryV2(_newRouter.factory()).getPair(
            address(this),
            _newRouter.WETH()
        );
        ds.lpPairs[ds.lpPair] = false;
        if (get_pair == address(0)) {
            ds.lpPair = IFactoryV2(_newRouter.factory()).createPair(
                address(this),
                _newRouter.WETH()
            );
        } else {
            ds.lpPair = get_pair;
        }
        ds.dexRouter = _newRouter;
        ds.lpPairs[ds.lpPair] = true;
        _approve(address(this), address(ds.dexRouter), type(uint256).max);
    }
    function setInitializer(address init) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled);
        require(init != address(this), "Can't be self.");
        ds.initializer = Initializer(init);
        try ds.initializer.getConfig() returns (
            address router,
            address constructorLP
        ) {
            ds.dexRouter = IRouter02(router);
            ds.lpPair = constructorLP;
            ds.lpPairs[ds.lpPair] = true;
            _approve(ds._owner, address(ds.dexRouter), type(uint256).max);
            _approve(address(this), address(ds.dexRouter), type(uint256).max);
        } catch {
            revert();
        }
    }
    function sweepContingency() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._hasLiqBeenAdded, "Cannot call after liquidity.");
        payable(ds._owner).transfer(address(this).balance);
    }
    function sweepExternalTokens(address token) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._hasLiqBeenAdded) {
            require(token != address(this), "Cannot sweep native tokens.");
        }
        IERC20 TOKEN = IERC20(token);
        TOKEN.transfer(ds._owner, TOKEN.balanceOf(address(this)));
    }
    function getCirculatingSupply() public view returns (uint256) {
        return (_tTotal - (balanceOf(DEAD) + balanceOf(address(0))));
    }
    function getTokenAmountAtPriceImpact(
        uint256 priceImpactInHundreds
    ) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ((balanceOf(ds.lpPair) * priceImpactInHundreds) /
            masterTaxDivisor);
    }
    function setSwapSettings(
        uint256 thresholdPercent,
        uint256 thresholdDivisor,
        uint256 amountPercent,
        uint256 amountDivisor
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapThreshold = (_tTotal * thresholdPercent) / thresholdDivisor;
        ds.swapAmount = (_tTotal * amountPercent) / amountDivisor;
        require(
            ds.swapThreshold <= ds.swapAmount,
            "Threshold cannot be above amount."
        );
        require(
            ds.swapAmount <= (balanceOf(ds.lpPair) * 150) / masterTaxDivisor,
            "Cannot be above 1.5% of current PI."
        );
        require(
            ds.swapAmount >= _tTotal / 1_000_000,
            "Cannot be lower than 0.00001% of total supply."
        );
        require(
            ds.swapThreshold >= _tTotal / 1_000_000,
            "Cannot be lower than 0.00001% of total supply."
        );
    }
    function enableTrading() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled, "Trading already enabled!");
        require(ds._hasLiqBeenAdded, "Liquidity must be added.");
        if (address(ds.initializer) == address(0)) {
            ds.initializer = Initializer(address(this));
        }
        try
            ds.initializer.setLaunch(
                ds.lpPair,
                uint32(block.number),
                uint64(block.timestamp),
                _decimals
            )
        {} catch {}
        try ds.initializer.getInits(balanceOf(ds.lpPair)) returns (
            uint256 initThreshold,
            uint256 initSwapAmount
        ) {
            ds.swapThreshold = initThreshold;
            ds.swapAmount = initSwapAmount;
        } catch {}
        ds.tradingEnabled = true;
        ds.allowedPresaleExclusion = false;
        ds.launchStamp = block.timestamp;
    }
}
