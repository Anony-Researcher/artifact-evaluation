/** 
Website: http://synthtpu.cloud
Telegram: https://t.me/SynthTPU
Twitter: https://twitter.com/SynthTPU
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Ownable {
    using Address for address;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }
    modifier onlyTeam() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.teamMembers[_msgSender()] || msg.sender == owner(),
            "Caller is not a team member"
        );
        _;
    }

    event FeesSet(
        uint256 totalBuyFees,
        uint256 totalSellFees,
        uint256 denominator
    );
    function totalSupply() external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
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
    function setTeamMember(address _team, bool _enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.teamMembers[_team] = _enabled;
    }
    function airdrop(
        address[] calldata addresses,
        uint256[] calldata amounts
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(addresses.length > 0 && amounts.length == addresses.length);
        address from = msg.sender;

        for (uint i = 0; i < addresses.length; i++) {
            if (
                !ds.liquidityPools[addresses[i]] &&
                !ds.isLiquidityCreator[addresses[i]]
            ) {
                _basicTransfer(
                    from,
                    addresses[i],
                    amounts[i] * (10 ** _decimals)
                );
            }
        }
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
            ds._allowances[sender][msg.sender] =
                ds._allowances[sender][msg.sender] -
                amount;
        }

        return _transferFrom(sender, recipient, amount);
    }
    function addLiquidityPool(address lp, bool isPool) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(lp != ds.pair, "Can't alter current liquidity ds.pair");
        ds.liquidityPools[lp] = isPool;
    }
    function setSwapBackRateLimit(uint256 rate) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapBackRateLimit = rate;
    }
    function setTxLimit(
        uint256 buyNumerator,
        uint256 sellNumerator,
        uint256 divisor
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            buyNumerator > 0 &&
                sellNumerator > 0 &&
                divisor > 0 &&
                divisor <= 10000
        );
        ds._maxBuyTxAmount = (ds._totalSupply * buyNumerator) / divisor;
        ds._maxSellTxAmount = (ds._totalSupply * sellNumerator) / divisor;
    }
    function setMaxWallet(
        uint256 numerator,
        uint256 divisor
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(numerator > 0 && divisor > 0 && divisor <= 10000);
        ds._maxWalletSize = (ds._totalSupply * numerator) / divisor;
    }
    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[holder] = exempt;
    }
    function setIsTxLimitExempt(
        address holder,
        bool exempt
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTxLimitExempt[holder] = exempt;
    }
    function setFees(
        uint256 _liquidityBuyFee,
        uint256 _liquiditySellFee,
        uint256 _marketingBuyFee,
        uint256 _marketingSellFee,
        uint256 _feeDenominator
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ((_liquidityBuyFee + _liquiditySellFee) / 2) * 2 ==
                (_liquidityBuyFee + _liquiditySellFee),
            "Liquidity fee must be an even number for rounding compatibility."
        );
        ds.liquidityBuyFee = _liquidityBuyFee;
        ds.liquiditySellFee = _liquiditySellFee;
        ds.marketingBuyFee = _marketingBuyFee;
        ds.marketingSellFee = _marketingSellFee;
        ds.totalBuyFee = _liquidityBuyFee + _marketingBuyFee;
        ds.totalSellFee = _liquiditySellFee + _marketingSellFee;
        ds.feeDenominator = _feeDenominator;
        emit FeesSet(ds.totalBuyFee, ds.totalSellFee, ds.feeDenominator);
    }
    function toggleTransferTax() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferTax = !ds.transferTax;
    }
    function setFeeReceivers(
        address _liquidityFeeReceiver,
        address _marketingFeeReceiver
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.liquidityFeeReceiver = payable(_liquidityFeeReceiver);
        ds.marketingFeeReceiver = payable(_marketingFeeReceiver);
    }
    function setSwapBackSettings(
        bool _enabled,
        uint256 _denominator,
        uint256 _swapAtMinimum
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_denominator > 0);
        ds.swapEnabled = _enabled;
        ds.swapThreshold = ds._totalSupply / _denominator;
        ds.swapAtMinimum = _swapAtMinimum * (10 ** _decimals);
    }
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: transfer from 0x0");
        require(recipient != address(0), "ERC20: transfer to 0x0");
        require(amount > 0, "Amount must be > zero");
        require(ds._balances[sender] >= amount, "Insufficient balance");
        if (!launched() && ds.liquidityPools[recipient]) {
            require(ds.isLiquidityCreator[sender], "Liquidity not added yet.");
            launch();
        }
        if (!ds.isTradingEnabled) {
            require(
                ds.isLiquidityCreator[sender] ||
                    ds.isLiquidityCreator[recipient],
                "Trading is not launched yet."
            );
        }

        checkTxLimit(sender, recipient, amount);

        if (!ds.liquidityPools[recipient] && recipient != ds.DEAD) {
            if (!ds.isTxLimitExempt[recipient]) {
                checkWalletLimit(recipient, amount);
            }
        }

        if (ds.inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        ds._balances[sender] = ds._balances[sender] - amount;

        uint256 amountReceived = amount;

        if (shouldTakeFee(sender, recipient)) {
            amountReceived = takeFee(recipient, amount);
            if (shouldSwapBack(recipient) && amount > 0) swapBack(amount);
        }

        ds._balances[recipient] = ds._balances[recipient] + amountReceived;

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    function launched() internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.launchBlock != 0;
    }
    function launch() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.launchBlock = block.number;
        ds.launchTimestamp = block.timestamp;
    }
    function checkTxLimit(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.isTxLimitExempt[sender] || ds.isTxLimitExempt[recipient]) return;

        require(
            amount <=
                (
                    ds.liquidityPools[sender]
                        ? ds._maxBuyTxAmount
                        : ds._maxSellTxAmount
                ),
            "Amount exceeds the tx limit."
        );

        require(ds.blacklist[sender] == 0, "Wallet blacklisted!");
    }
    function checkWalletLimit(address recipient, uint256 amount) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 walletLimit = ds._maxWalletSize;
        require(
            ds._balances[recipient] + amount <= walletLimit,
            "Amount exceeds the max wallet size."
        );
    }
    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._balances[sender] = ds._balances[sender] - amount;
        ds._balances[recipient] = ds._balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function shouldTakeFee(
        address sender,
        address recipient
    ) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            !ds.transferTax &&
            !ds.liquidityPools[recipient] &&
            !ds.liquidityPools[sender]
        ) return false;
        return !ds.isFeeExempt[sender] && !ds.isFeeExempt[recipient];
    }
    function takeFee(
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool selling = ds.liquidityPools[recipient];
        uint256 feeAmount = (amount * getTotalFee(selling)) / ds.feeDenominator;

        ds._balances[address(this)] += feeAmount;

        return amount - feeAmount;
    }
    function getTotalFee(bool selling) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (selling) return ds.totalSellFee;
        return ds.totalBuyFee;
    }
    function shouldSwapBack(address recipient) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            !ds.liquidityPools[msg.sender] &&
            !ds.inSwap &&
            ds.swapEnabled &&
            ds.swapBackCounter[block.number] < ds.swapBackRateLimit &&
            ds.liquidityPools[recipient] &&
            ds._balances[address(this)] >= ds.swapAtMinimum &&
            ds.totalBuyFee + ds.totalSellFee > 0;
    }
    function swapBack(uint256 amount) internal swapping {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 totalFee = ds.totalBuyFee + ds.totalSellFee;
        uint256 amountToSwap = amount < ds.swapThreshold
            ? amount
            : ds.swapThreshold;
        if (ds._balances[address(this)] < amountToSwap)
            amountToSwap = ds._balances[address(this)];

        uint256 totalLiquidityFee = ds.liquidityBuyFee + ds.liquiditySellFee;
        uint256 amountToLiquify = ((amountToSwap * totalLiquidityFee) / 2) /
            totalFee;
        amountToSwap -= amountToLiquify;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.router.WETH();

        uint256 balanceBefore = address(this).balance;

        ds.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance - balanceBefore;
        uint256 totalETHFee = totalFee - (totalLiquidityFee / 2);

        uint256 amountETHLiquidity = ((amountETH * totalLiquidityFee) / 2) /
            totalETHFee;
        uint256 amountETHMarketing = amountETH - amountETHLiquidity;

        if (amountETHMarketing > 0) {
            (bool sentMarketing, ) = ds.marketingFeeReceiver.call{
                value: amountETHMarketing
            }("");
            if (!sentMarketing) {
                //Failed to transfer to marketing wallet
            }
        }

        if (amountToLiquify > 0) {
            ds.router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                ds.liquidityFeeReceiver,
                block.timestamp
            );
        }
        ds.swapBackCounter[block.number] = ds.swapBackCounter[block.number] + 1;
        emit FundsDistributed(
            amountETHMarketing,
            amountETHLiquidity,
            amountToLiquify
        );
    }
    function approveMaxAmount(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }
    function getCirculatingSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply - (balanceOf(ds.DEAD) + balanceOf(ds.ZERO));
    }
}
