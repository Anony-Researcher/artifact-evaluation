/**
 *Submitted for verification at Etherscan.io on 2022-11-07
 */

//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20 {
    modifier lockTaxSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inTaxSwap = true;
        _;
        ds._inTaxSwap = false;
    }

    event TaxRateChanged(uint8 newBuyTax, uint8 newSellTax);
    event TaxWalletChanged(address newTaxWallet);
    event TokensAirdropped(uint256 totalWallets, uint256 totalTokens);
    event TokensBurned(address indexed burnedByWallet, uint256 tokenAmount);
    event TokensBurned(address indexed burnedByWallet, uint256 tokenAmount);
    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
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
        require(_checkTradingOpen(), "Trading not open");
        return _transferFrom(msg.sender, recipient, amount);
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_checkTradingOpen(), "Trading not open");
        if (ds._allowances[sender][msg.sender] != type(uint256).max) {
            ds._allowances[sender][msg.sender] =
                ds._allowances[sender][msg.sender] -
                amount;
        }
        return _transferFrom(sender, recipient, amount);
    }
    function initLP() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading already open");

        _distributeInitialBalances();

        uint256 _contractETHBalance = address(this).balance;
        require(_contractETHBalance > 0, "no eth in contract");
        uint256 _contractTokenBalance = balanceOf(address(this));
        require(_contractTokenBalance > 0, "no tokens");
        address _uniLpAddr = IUniswapV2Factory(ds._uniswapV2Router.factory())
            .createPair(address(this), ds._uniswapV2Router.WETH());
        ds.LPaddress = _uniLpAddr;
        ds._isLiqPool[_uniLpAddr] = true;

        _approveRouter(_contractTokenBalance);
        _addLiquidity(_contractTokenBalance, _contractETHBalance, false);

        // _openTrading(); //trading will be open manually through enableTrading() function
    }
    function enableTrading() external onlyOwner {
        _openTrading();
    }
    function enableAntiBot(bool isEnabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.antiBotEnabled = isEnabled;
    }
    function excludeFromAntiBot(
        address wallet,
        bool isExcluded
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!isExcluded) {
            require(
                wallet != address(this) && wallet != owner,
                "This address must be excluded"
            );
        }
        ds.excludedFromAntiBot[wallet] = isExcluded;
    }
    function excludeFromFees(
        address wallet,
        bool isExcluded
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (isExcluded) {
            require(
                wallet != address(this) && wallet != owner,
                "Cannot enforce fees for this address"
            );
        }
        ds.excludedFromFees[wallet] = isExcluded;
    }
    function adjustTaxRate(
        uint8 newBuyTax,
        uint8 newSellTax
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newBuyTax <= _maxTaxRate && newSellTax <= _maxTaxRate,
            "Tax too high"
        );
        //set new tax rate percentage - cannot be higher than the default rate 5%
        ds.taxRateBuy = newBuyTax;
        ds.taxRateSell = newSellTax;
        emit TaxRateChanged(newBuyTax, newSellTax);
    }
    function setTaxWallet(address newTaxWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.taxWallet = payable(newTaxWallet);
        ds.excludedFromFees[newTaxWallet] = true;
        emit TaxWalletChanged(newTaxWallet);
    }
    function taxSwapSettings(
        uint32 minValue,
        uint32 minDivider,
        uint32 maxValue,
        uint32 maxDivider
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.taxSwapMin = (_totalSupply * minValue) / minDivider;
        ds.taxSwapMax = (_totalSupply * maxValue) / maxDivider;
        require(ds.taxSwapMax >= ds.taxSwapMin, "MinMax error");
        require(
            ds.taxSwapMax > _totalSupply / 10000,
            "Upper threshold too low"
        );
        require(
            ds.taxSwapMax < (_totalSupply * 2) / 100,
            "Upper threshold too high"
        );
    }
    function taxTokensSwap() external onlyOwner {
        uint256 taxTokenBalance = balanceOf(address(this));
        require(taxTokenBalance > 0, "No tokens");
        _swapTaxTokensForEth(taxTokenBalance);
    }
    function taxEthSend() external onlyOwner {
        uint256 _contractEthBalance = address(this).balance;
        require(_contractEthBalance > 0, "No ETH in contract to distribute");
        _distributeTaxEth(_contractEthBalance);
    }
    function airdrop(
        address[] calldata addresses,
        uint256[] calldata tokenAmounts
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(addresses.length <= 250, "Wallet count over 250 (gas risk)");
        require(
            addresses.length == tokenAmounts.length,
            "Address and token amount list mismach"
        );

        uint256 airdropTotal = 0;
        for (uint i = 0; i < addresses.length; i++) {
            airdropTotal += (tokenAmounts[i] * 10 ** _decimals);
        }
        require(
            ds._balances[msg.sender] >= airdropTotal,
            "Token balance lower than airdrop total"
        );

        for (uint i = 0; i < addresses.length; i++) {
            ds._balances[msg.sender] -= (tokenAmounts[i] * 10 ** _decimals);
            ds._balances[addresses[i]] += (tokenAmounts[i] * 10 ** _decimals);
            emit Transfer(
                msg.sender,
                addresses[i],
                (tokenAmounts[i] * 10 ** _decimals)
            );
        }

        emit TokensAirdropped(addresses.length, airdropTotal);
    }
    function _distributeTaxEth(uint256 _amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.taxWallet.transfer(_amount);
    }
    function _swapTaxAndDistributeEth() private lockTaxSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _taxTokensAvailable = balanceOf(address(this));
        if (_taxTokensAvailable >= ds.taxSwapMin && ds.tradingOpen) {
            if (_taxTokensAvailable >= ds.taxSwapMax) {
                _taxTokensAvailable = ds.taxSwapMax;
            }
            if (_taxTokensAvailable > 10 ** _decimals) {
                _swapTaxTokensForEth(_taxTokensAvailable);
                uint256 _contractETHBalance = address(this).balance;
                if (_contractETHBalance > 0) {
                    _distributeTaxEth(_contractETHBalance);
                }
            }
        }
    }
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            sender != address(0) || recipient != address(0),
            "Zero wallet cannot do transfers."
        );
        if (ds.tradingOpen) {
            if (ds.antiBotEnabled) {
                checkAntiBot(sender, recipient);
            }
            if (!ds._inTaxSwap && ds._isLiqPool[recipient]) {
                _swapTaxAndDistributeEth();
            }
        }

        uint256 _taxAmount = _calculateTax(sender, recipient, amount);
        uint256 _transferAmount = amount - _taxAmount;
        ds._balances[sender] = ds._balances[sender] - amount;
        if (_taxAmount > 0) {
            ds._balances[address(this)] =
                ds._balances[address(this)] +
                _taxAmount;
        }
        ds._balances[recipient] = ds._balances[recipient] + _transferAmount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function checkAntiBot(address sender, address recipient) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._isLiqPool[sender] && !ds.excludedFromAntiBot[recipient]) {
            //buy transactions
            require(
                ds._lastSwapBlock[recipient] < block.number,
                "AntiBot triggered"
            );
            ds._lastSwapBlock[recipient] = block.number;
        } else if (
            ds._isLiqPool[recipient] && !ds.excludedFromAntiBot[sender]
        ) {
            //sell transactions
            require(
                ds._lastSwapBlock[sender] < block.number,
                "AntiBot triggered"
            );
            ds._lastSwapBlock[sender] = block.number;
        }
    }
    function _calculateTax(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 taxAmount;
        if (
            !ds.tradingOpen ||
            ds.excludedFromFees[sender] ||
            ds.excludedFromFees[recipient]
        ) {
            taxAmount = 0;
        } else if (ds._isLiqPool[sender]) {
            taxAmount = (amount * ds.taxRateBuy) / 100;
        } else if (ds._isLiqPool[recipient]) {
            taxAmount = (amount * ds.taxRateSell) / 100;
        } else {
            taxAmount = 0;
        }
        return taxAmount;
    }
    function _swapTaxTokensForEth(uint256 _tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approveRouter(_tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds._uniswapV2Router.WETH();
        ds._uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            _tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _approveRouter(uint256 _tokenAmount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds._allowances[address(this)][_uniswapV2RouterAddress] <
            _tokenAmount
        ) {
            ds._allowances[address(this)][_uniswapV2RouterAddress] = type(
                uint256
            ).max;
            emit Approval(
                address(this),
                _uniswapV2RouterAddress,
                type(uint256).max
            );
        }
    }
    function _openTrading() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading already open");
        ds.taxRateBuy = 3;
        ds.taxRateSell = 3;
        ds.tradingOpen = true;
    }
    function _distributeInitialBalances() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //holder airdrops 27.965%, 1556 wallets
        uint256 airdropTokensAmount = 279646010 * 10 ** _decimals;
        ds._balances[owner] = airdropTokensAmount;
        emit Transfer(address(0), owner, airdropTokensAmount);

        // Treasury 25%: 0x1D0A105F0cED39b207AE444957cc70483c04C767
        uint256 treasuryAmount = 250000000 * 10 ** _decimals;
        ds._balances[
            address(0x4E8b4f91088A6d4C38E1D52c751035F3a34b6c9c)
        ] = treasuryAmount;
        emit Transfer(
            address(0),
            address(0x4E8b4f91088A6d4C38E1D52c751035F3a34b6c9c),
            treasuryAmount
        );

        // Dev Fund 19.462% : 0xac5c6FDd4F32977eec56C48978bAe86CE08968e0
        uint256 devFundAmount = 194620743 * 10 ** _decimals;
        ds._balances[
            address(0xB0042e56223fDFBcE6426D6C9650431642Df4440)
        ] = devFundAmount;
        emit Transfer(
            address(0),
            address(0xB0042e56223fDFBcE6426D6C9650431642Df4440),
            devFundAmount
        );

        // Rewards pool 15%: 0x94baCbCceE5c16520Ab8545c35e89eCE7017a34D
        uint256 rewardsPoolAmount = 150000000 * 10 ** _decimals;
        ds._balances[
            address(0xB4711E55d82D61d88A3f8fd092D2944eEF6b9651)
        ] = rewardsPoolAmount;
        emit Transfer(
            address(0),
            address(0xB4711E55d82D61d88A3f8fd092D2944eEF6b9651),
            rewardsPoolAmount
        );

        // Marketing 44076978.428271124 : 0xCbE59E5967B80Ad18764d49c9184E6249aFe2D28
        uint256 marketingAmount = 44076978 * 10 ** _decimals;
        ds._balances[
            address(0xbc865c58f26c86B9aA240a1F34d5b9e62Ad2bcDC)
        ] = marketingAmount;
        emit Transfer(
            address(0),
            address(0xbc865c58f26c86B9aA240a1F34d5b9e62Ad2bcDC),
            marketingAmount
        );

        //liquidity pool is 2.507%
        uint256 liquidityPoolAmount = 25_066_478 * 10 ** _decimals;
        ds._balances[address(this)] = liquidityPoolAmount;
        emit Transfer(address(0), address(this), liquidityPoolAmount);

        // Burn amount (diff between total supply and the above, ~ 5.659%
        uint256 burnAmount = _totalSupply -
            (airdropTokensAmount +
                treasuryAmount +
                devFundAmount +
                rewardsPoolAmount +
                marketingAmount +
                liquidityPoolAmount);
        ds._balances[address(0)] = burnAmount;
        emit Transfer(address(0), address(0), burnAmount);
        emit TokensBurned(address(0), burnAmount);
    }
    function _addLiquidity(
        uint256 _tokenAmount,
        uint256 _ethAmountWei,
        bool autoburn
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address lpTokenRecipient = address(0);
        if (!autoburn) {
            lpTokenRecipient = owner;
        }
        ds._uniswapV2Router.addLiquidityETH{value: _ethAmountWei}(
            address(this),
            _tokenAmount,
            0,
            0,
            lpTokenRecipient,
            block.timestamp
        );
    }
    function _checkTradingOpen() private view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool checkResult = false;
        if (ds.tradingOpen) {
            checkResult = true;
        } else if (tx.origin == owner) {
            checkResult = true;
        }
        return checkResult;
    }
    function burnTokens(uint256 amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //burns tokens from the msg.sender's wallet
        uint256 _tokensAvailable = balanceOf(msg.sender);
        require(amount <= _tokensAvailable, "Token balance too low");
        ds._balances[msg.sender] -= amount;
        ds._balances[address(0)] += amount;
        emit Transfer(msg.sender, address(0), amount);
        emit TokensBurned(msg.sender, amount);
    }
}
