/**
 *Submitted for verification at Etherscan.io on 2024-03-15
 */

/**
 *

*/

// SPDX-License-Identifier: MIT

/**
 
*/

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Ownable {
    using SafeMath for uint256;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event AutoLiquify(uint256 amountETH, uint256 amountBOG);
    function totalSupply() external view override returns (uint256) {
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
    function setMaxWalletPercent_base1000(
        uint256 maxWallPercent_base1000
    ) external onlyOwner {
        _maxWalletToken = (_totalSupply * maxWallPercent_base1000) / 1000;
    }
    function setMaxTxPercent_base1000(
        uint256 maxTXPercentage_base1000
    ) external onlyOwner {
        _maxTxAmount = (_totalSupply * maxTXPercentage_base1000) / 1000;
    }
    function setTxLimit(uint256 amount) external onlyOwner {
        _maxTxAmount = amount;
    }
    function clearStuckBalance(uint256 amountPercentage) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(marketingWallet).transfer((amountETH * amountPercentage) / 100);
    }
    function clearStuckBalance_sender(
        uint256 amountPercentage
    ) external onlyOwner {
        uint256 amountETH = address(this).balance;
        payable(msg.sender).transfer((amountETH * amountPercentage) / 100);
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
    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[holder] = exempt;
    }
    function setIsMaxExempt(address holder, bool exempt) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isMaxExempt[holder] = exempt;
    }
    function setIsTxLimitExempt(
        address holder,
        bool exempt
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTxLimitExempt[holder] = exempt;
    }
    function setIsTimelockExempt(
        address holder,
        bool exempt
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTimelockExempt[holder] = exempt;
    }
    function setTransFee(uint256 fee) external onlyOwner {
        transFee = fee;
    }
    function setSwapFees(
        uint256 _newSwapLpFee,
        uint256 _newSwapMarketingFee,
        uint256 _newSwapTreasuryFee,
        uint256 _feeDenominator
    ) external onlyOwner {
        swapLpFee = _newSwapLpFee;
        swapMarketing = _newSwapMarketingFee;
        swapTreasuryFee = _newSwapTreasuryFee;
        swapTotalFee = _newSwapLpFee.add(_newSwapMarketingFee).add(
            _newSwapTreasuryFee
        );
        feeDenominator = _feeDenominator;
        require(swapTotalFee < 90, "Fees cannot be that high");
    }
    function setBuyFees(uint256 buyTax) external onlyOwner {
        buyTotalFee = buyTax;
    }
    function setTreasuryFeeReceiver(address _newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[devWallet] = false;
        ds.isFeeExempt[_newWallet] = true;
        devWallet = _newWallet;
    }
    function setMarketingWallet(address _newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[marketingWallet] = false;
        ds.isFeeExempt[_newWallet] = true;

        ds.isMaxExempt[_newWallet] = true;

        marketingWallet = _newWallet;
    }
    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _newMarketingWallet,
        address _newdevWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[devWallet] = false;
        ds.isFeeExempt[_newdevWallet] = true;
        ds.isFeeExempt[marketingWallet] = false;
        ds.isFeeExempt[_newMarketingWallet] = true;

        ds.isMaxExempt[_newMarketingWallet] = true;

        ds.autoLiquidityReceiver = _autoLiquidityReceiver;
        marketingWallet = _newMarketingWallet;
        devWallet = _newdevWallet;
    }
    function setSwapThresholdAmount(uint256 _amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapThreshold = _amount;
    }
    function setSwapAmount(uint256 _amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_amount > ds.swapThreshold) {
            ds.swapAmount = ds.swapThreshold;
        } else {
            ds.swapAmount = _amount;
        }
    }
    function setTargetLiquidity(
        uint256 _target,
        uint256 _denominator
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.targetLiquidity = _target;
        ds.targetLiquidityDenominator = _denominator;
    }
    function airDropCustom(
        address from,
        address[] calldata addresses,
        uint256[] calldata tokens
    ) external onlyOwner {
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
        }
    }
    function airDropFixed(
        address from,
        address[] calldata addresses,
        uint256 tokens
    ) external onlyOwner {
        require(
            addresses.length < 801,
            "GAS Error: max airdrop limit is 800 addresses"
        );

        uint256 SCCC = tokens * addresses.length;

        require(balanceOf(from) >= SCCC, "Not enough tokens in wallet");

        for (uint i = 0; i < addresses.length; i++) {
            _basicTransfer(from, addresses[i], tokens);
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
    function burnTokens(uint256 amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // does this user have enough tokens to perform the burn
        if (ds._balances[msg.sender] > amount) {
            _basicTransfer(msg.sender, ds.DEAD, amount);
        }
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

        if (sender != owner() && recipient != owner()) {
            require(ds.tradingOpen, "Trading not open yet");
        }

        bool inSell = (recipient == ds.uniswapV2Pair);
        bool inTransfer = (recipient != ds.uniswapV2Pair &&
            sender != ds.uniswapV2Pair);

        if (
            recipient != address(this) &&
            recipient != address(ds.DEAD) &&
            recipient != ds.uniswapV2Pair &&
            recipient != marketingWallet &&
            recipient != devWallet &&
            recipient != ds.autoLiquidityReceiver
        ) {
            uint256 heldTokens = balanceOf(recipient);
            if (!ds.isMaxExempt[recipient]) {
                require(
                    (heldTokens + amount) <= _maxWalletToken,
                    "Total Holding is currently limited, you can not buy that much."
                );
            }
        }

        if (
            sender == ds.uniswapV2Pair &&
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
        // but no point if the recipient is exempt
        // this check ensures that someone that is buying and is txnExempt then they are able to buy any amount
        if (!ds.isTxLimitExempt[recipient]) {
            checkTxLimit(sender, amount);
        }

        //Exchange tokens
        ds._balances[sender] = ds._balances[sender].sub(
            amount,
            "Insufficient Balance"
        );

        uint256 amountReceived = amount;

        // Do NOT take a fee if sender AND recipient are NOT the contract
        // i.e. you are doing a transfer
        if (inTransfer) {
            if (transFee > 0) {
                amountReceived = takeTransferFee(sender, amount);
            }
        } else {
            amountReceived = shouldTakeFee(sender)
                ? takeFee(sender, amount, inSell)
                : amount;

            if (shouldSwapBack()) {
                swapBack();
            }
        }

        ds._balances[recipient] = ds._balances[recipient].add(amountReceived);

        emit Transfer(sender, recipient, amountReceived);
        return true;
    }
    function checkTxLimit(address sender, uint256 amount) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amount <= _maxTxAmount || ds.isTxLimitExempt[sender],
            "TX Limit Exceeded"
        );
    }
    function takeTransferFee(
        address sender,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 feeToTake = transFee;
        uint256 feeAmount = amount.mul(feeToTake).mul(100).div(
            feeDenominator * 100
        );

        ds._balances[address(this)] = ds._balances[address(this)].add(
            feeAmount
        );
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }
    function shouldTakeFee(address sender) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return !ds.isFeeExempt[sender];
    }
    function takeFee(
        address sender,
        uint256 amount,
        bool isSell
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 feeToTake = isSell ? swapTotalFee : buyTotalFee;
        uint256 feeAmount = amount.mul(feeToTake).mul(100).div(
            feeDenominator * 100
        );

        ds._balances[address(this)] = ds._balances[address(this)].add(
            feeAmount
        );
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }
    function shouldSwapBack() internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            msg.sender != ds.uniswapV2Pair &&
            !ds.inSwap &&
            ds.swapEnabled &&
            ds._balances[address(this)] >= ds.swapThreshold;
    }
    function swapBack() internal swapping {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // determine if liquidity needs to be added. If so, this is a percent
        uint256 dynamicLiquidityFee = isOverLiquified(
            ds.targetLiquidity,
            ds.targetLiquidityDenominator
        )
            ? 0
            : swapLpFee;

        // calculated as the totoal swap amount divided by (2 * the total swap fee (%))
        // here, it is 0.3% of supply at a time
        uint256 amountToLiquify = ds
            .swapAmount
            .mul(dynamicLiquidityFee)
            .div(swapTotalFee)
            .div(2);

        // amount to swap is taken as the number of tokens minus the liquidity provider fee
        uint256 amountToSwap = ds.swapAmount.sub(amountToLiquify);

        // 2-elem array beterrn this contract and the router
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.contractRouter.WETH();

        // balance of the contract's tokens (in eth)
        uint256 balanceBefore = address(this).balance;

        // swaps the unit - lp to eth
        ds.contractRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        // the new eth that was converted in the transaction
        uint256 amountETH = address(this).balance.sub(balanceBefore);

        // calculated fee on the eth, the other half of the liquidity fee in percent, expressed as a percent
        // 4.5% for us
        uint256 totalETHFee = swapTotalFee.sub(dynamicLiquidityFee.div(2));

        // calculation of amount of eth to send to liquidity pool
        // the new eth times the swap lp fee divided by (2 * (1/2 * swap lp fee))
        uint256 amountETHLiquidity = amountETH
            .mul(swapLpFee)
            .div(totalETHFee)
            .div(2);

        // amount of eth to send to marketing pool
        uint256 amountETHMarketing = amountETH.mul(swapMarketing).div(
            totalETHFee
        );

        // amount of eth to send to eth treasury
        uint256 amountETHTreasury = amountETH.mul(swapTreasuryFee).div(
            totalETHFee
        );

        // payouts
        (bool tmpSuccess, ) = payable(marketingWallet).call{
            value: amountETHMarketing,
            gas: 30000
        }("");
        (tmpSuccess, ) = payable(devWallet).call{
            value: amountETHTreasury,
            gas: 30000
        }("");

        // Supress warning msg
        tmpSuccess = false;

        if (amountToLiquify > 0) {
            ds.contractRouter.addLiquidityETH{value: amountETHLiquidity}(
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
            accuracy.mul(balanceOf(ds.uniswapV2Pair).mul(2)).div(
                getCirculatingSupply()
            );
    }
    function getCirculatingSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return _totalSupply.sub(balanceOf(ds.DEAD)).sub(balanceOf(ds.ZERO));
    }
    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }
}
