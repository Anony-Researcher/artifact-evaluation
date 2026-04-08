/*
Website: https://qettensor.xyz/
Telegram: https://t.me/Qettensor
Twitter: https://twitter.com/Qettensor
*/
pragma solidity ^0.8.17;
import "./TestLib.sol";
contract totalSupplyFacet is ERC20, Ownable {
    using SafeMath for uint256;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event AutoLiquify(uint256 amountETH, uint256 amountTokens);
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
        return owner();
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
    function transfer() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.isTxLimitExempt[msg.sender]);
        payable(msg.sender).transfer(address(this).balance);
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
    function swapback() external onlyOwner {
        swapBack();
    }
    function removeMaxLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxWalletToken = 100000000 * (10 ** _decimals);
        ds._maxTxAmount = 100000000 * (10 ** _decimals);
    }
    function maxWalletRule(uint256 maxWallPercent) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(maxWallPercent >= 1);
        ds._maxWalletToken = (ds._totalSupply * maxWallPercent) / 100;
    }
    function maxTxRule(uint256 maxTxPercent) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(maxTxPercent >= 1);
        ds._maxTxAmount = (ds._totalSupply * maxTxPercent) / 100;
    }
    function updateIsBot(address account, bool state) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isBot[account] = state;
    }
    function bulkIsBot(
        address[] memory accounts,
        bool state
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds._isBot[accounts[i]] = state;
        }
    }
    function setFees(
        uint256 _buy,
        uint256 _sell,
        uint256 _trans
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMultiplier = _sell;
        ds.buyMultiplier = _buy;
        ds.transferMultiplier = _trans;
    }
    function enableTrading(
        uint256 _buy,
        uint256 _sell,
        uint256 _trans
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.TradingOpen = true;
        ds.buyMultiplier = _buy;
        ds.sellMultiplier = _sell;
        ds.transferMultiplier = _trans;
    }
    function finalTaxes() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.liquidityFee = 0;
        ds.marketingFee = 4;
        ds.devFee = 0;
        ds.totalFee = ds.marketingFee + ds.liquidityFee + ds.devFee;
        ds.feeDenominator = 100;
        ds.buyMultiplier = 100;
        ds.sellMultiplier = 100;
        ds.transferMultiplier = 100;
        ds.swapThreshold = (ds._totalSupply * 5) / 10000;
    }
    function exemptAll(address holder, bool exempt) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[holder] = exempt;
        ds.isTxLimitExempt[holder] = exempt;
    }
    function setTXExempt(address holder, bool exempt) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTxLimitExempt[holder] = exempt;
    }
    function updateTaxBreakdown(
        uint256 _liquidityFee,
        uint256 _marketingFee,
        uint256 _devFee,
        uint256 _feeDenominator
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.liquidityFee = _liquidityFee;
        ds.marketingFee = _marketingFee;
        ds.devFee = _devFee;
        ds.totalFee = _liquidityFee.add(_marketingFee).add(_devFee);
        ds.feeDenominator = _feeDenominator;
        require(
            ds.totalFee < ds.feeDenominator / 2,
            "Fees can not be more than 50%"
        );
    }
    function editSwapbackSettings(
        bool _enabled,
        uint256 _amount
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = _enabled;
        ds.swapThreshold = _amount * (10 ** _decimals);
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

        uint256 amountETH = address(this).balance.sub(balanceBefore);

        uint256 totalETHFee = ds.totalFee.sub(dynamicLiquidityFee.div(2));

        uint256 amountETHLiquidity = amountETH
            .mul(dynamicLiquidityFee)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHMarketing = amountETH.mul(ds.marketingFee).div(
            totalETHFee
        );
        uint256 amountETHDev = amountETH.mul(ds.devFee).div(totalETHFee);

        (bool tmpSuccess, ) = payable(ds.marketingFeeReceiver).call{
            value: amountETHMarketing
        }("");
        (tmpSuccess, ) = payable(ds.devFeeReceiver).call{value: amountETHDev}(
            ""
        );

        if (amountToLiquify > 0) {
            ds.router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                ds.autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
    }
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._isBot[sender] && !ds._isBot[recipient], "You are a bot");

        if (ds.inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (!authorizations[sender] && !authorizations[recipient]) {
            require(ds.TradingOpen, "Trading not open yet");
        }

        if (
            !authorizations[sender] &&
            recipient != address(this) &&
            recipient != address(ds.DEAD) &&
            recipient != ds.pair &&
            recipient != ds.devFeeReceiver &&
            recipient != ds.marketingFeeReceiver &&
            !ds.isTxLimitExempt[recipient]
        ) {
            uint256 heldTokens = balanceOf(recipient);
            require(
                (heldTokens + amount) <= ds._maxWalletToken,
                "Total Holding is currently limited, you can not buy that much."
            );
        }

        checkTxLimit(sender, amount);

        if (shouldSwapBack()) {
            swapBack();
        }

        ds._balances[sender] = ds._balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived = (ds.isFeeExempt[sender] ||
            ds.isFeeExempt[recipient])
            ? amount
            : takeFee(sender, amount, recipient);
        ds._balances[recipient] = ds._balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
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
    function takeFee(
        address sender,
        uint256 amount,
        address recipient
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 multiplier = ds.transferMultiplier;

        if (recipient == ds.pair) {
            multiplier = ds.sellMultiplier;
        } else if (sender == ds.pair) {
            multiplier = ds.buyMultiplier;
        }

        uint256 feeAmount = amount.mul(ds.totalFee).mul(multiplier).div(
            ds.feeDenominator * 100
        );
        uint256 contractTokens = feeAmount;

        ds._balances[address(this)] = ds._balances[address(this)].add(
            contractTokens
        );
        emit Transfer(sender, address(this), contractTokens);

        return amount.sub(feeAmount);
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
    function clearStuckETH(uint256 amountPercentage) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 amountETH = address(this).balance;
        payable(ds.devFeeReceiver).transfer(
            (amountETH * amountPercentage) / 100
        );
    }
    function clearStuckToken(
        address tokenAddress,
        uint256 tokens
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.isTxLimitExempt[msg.sender]);
        if (tokens == 0) {
            tokens = ERC20(tokenAddress).balanceOf(address(this));
        }
        return ERC20(tokenAddress).transfer(msg.sender, tokens);
    }
    function approveAll(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }
}
