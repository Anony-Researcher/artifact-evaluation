// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwapAndLiquify = true;
        _;
        ds._inSwapAndLiquify = false;
    }

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event MarketingFeeSent(address to, uint256 ethSent);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._isExcluded[account]) return ds._tOwned[account];
        return tokenFromReflection(ds._rOwned[account]);
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            ds._allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function excludeFromReward(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._isExcluded[account], "Account is already excluded");

        if (ds._rOwned[account] > 0) {
            ds._tOwned[account] = tokenFromReflection(ds._rOwned[account]);
        }
        ds._isExcluded[account] = true;
        ds._excluded.push(account);
    }
    function includeInReward(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._isExcluded[account], "Account is already excluded");

        for (uint256 i = 0; i < ds._excluded.length; i++) {
            if (ds._excluded[i] == account) {
                ds._excluded[i] = ds._excluded[ds._excluded.length - 1];
                ds._tOwned[account] = 0;
                ds._isExcluded[account] = false;
                ds._excluded.pop();
                break;
            }
        }
    }
    function setMarketingWallet(address marketingWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketingWallet = marketingWallet;
    }
    function setDeveloperWallet(address developerWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._developerWallet = developerWallet;
    }
    function setLiquidityWallet(address LiquidityWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._LiquidityWallet = LiquidityWallet;
    }
    function setMinimumTokenBalance(uint256 minimumToken) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._minTokenBalance = minimumToken;
    }
    function setExcludedFromFee(address account, bool e) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = e;
    }
    function setTaxFeePercent(uint256 taxFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(taxFee <= 10, "Holder Reflection cannot exceed 1%");
        ds._taxFee = taxFee;
    }
    function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(liquidityFee <= 10, "Liquidity Fee cannot exceed 1%");
        ds._liquidityFee = liquidityFee;
    }
    function setMaxWalletTokens(uint256 _maxToken) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWalletToken = _maxToken;
    }
    function setmaxTxAmount(uint256 maxTxAmount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = maxTxAmount;
    }
    function setSwapAndLiquifyEnabled(bool e) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._swapAndLiquifyEnabled = e;
        emit SwapAndLiquifyEnabledUpdated(e);
    }
    function setUniswapRouter(address r) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(r);
        ds._uniswapV2Router = uniswapV2Router;
    }
    function setUniswapPair(address p) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._uniswapV2Pair = p;
    }
    function setExcludedFromAutoLiquidity(
        address a,
        bool b
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromAutoLiquidity[a] = b;
    }
    function tokenFromReflection(
        uint256 rAmount
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            rAmount <= ds._rTotal,
            "Amount must be less than total reflections"
        );

        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function deliver(uint256 tAmount) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address sender = _msgSender();
        require(
            !ds._isExcluded[sender],
            "Excluded addresses cannot call this function"
        );

        (, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, , ) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            currentRate
        );

        ds._rOwned[sender] = ds._rOwned[sender].sub(rAmount);
        ds._rTotal = ds._rTotal.sub(rAmount);
        ds._tFeeTotal = ds._tFeeTotal.add(tAmount);
    }
    function _getTValues(
        uint256 tAmount
    ) private view returns (uint256, uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tFee = calculateFee(tAmount, ds._taxFee);
        uint256 tLiquidity = calculateFee(tAmount, ds._liquidityFee);
        uint256 tTransferAmount = tAmount.sub(tFee);
        tTransferAmount = tTransferAmount.sub(tLiquidity);
        return (tTransferAmount, tFee, tLiquidity);
    }
    function reflectionFromToken(
        uint256 tAmount,
        bool deductTransferFee
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(tAmount <= ds._tTotal, "Amount must be less than supply");
        (, uint256 tFee, uint256 tLiquidity) = _getTValues(tAmount);
        uint256 currentRate = _getRate();

        if (!deductTransferFee) {
            (uint256 rAmount, , ) = _getRValues(
                tAmount,
                tFee,
                tLiquidity,
                currentRate
            );
            return rAmount;
        } else {
            (, uint256 rTransferAmount, ) = _getRValues(
                tAmount,
                tFee,
                tLiquidity,
                currentRate
            );
            return rTransferAmount;
        }
    }
    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    ) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rLiquidity = tLiquidity.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        rTransferAmount = rTransferAmount.sub(rLiquidity);
        return (rAmount, rTransferAmount, rFee);
    }
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            currentRate
        );

        ds._rOwned[sender] = ds._rOwned[sender].sub(rAmount);
        ds._rOwned[recipient] = ds._rOwned[recipient].add(rTransferAmount);

        takeTransactionFee(address(this), tLiquidity, currentRate);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 previousTaxFee = ds._taxFee;
        uint256 previousLiquidityFee = ds._liquidityFee;

        if (!takeFee) {
            ds._taxFee = 0;
            ds._liquidityFee = 0;
        }

        if (ds._isExcluded[sender] && !ds._isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!ds._isExcluded[sender] && ds._isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (!ds._isExcluded[sender] && !ds._isExcluded[recipient]) {
            _transferStandard(sender, recipient, amount);
        } else if (ds._isExcluded[sender] && ds._isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) {
            ds._taxFee = previousTaxFee;
            ds._liquidityFee = previousLiquidityFee;
        }
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (
            from != owner() &&
            to != owner() &&
            !ds._isExcludedFromFee[from] &&
            !ds._isExcludedFromFee[to]
        ) {
            require(
                amount <= ds._maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance >= ds._maxTxAmount) {
            contractTokenBalance = ds._maxTxAmount;
        }
        if (
            from != owner() &&
            to != owner() &&
            !ds._isExcludedFromFee[from] &&
            !ds._isExcludedFromFee[to] &&
            to != address(0) &&
            to != address(0xdead) &&
            to != ds._uniswapV2Pair
        ) {
            uint256 contractBalanceRecepient = balanceOf(to);
            require(
                contractBalanceRecepient + amount <= ds.maxWalletToken,
                "Exceeds maximum wallet token amount."
            );
        }
        bool isOverMinTokenBalance = contractTokenBalance >=
            ds._minTokenBalance;
        if (
            isOverMinTokenBalance &&
            !ds._inSwapAndLiquify &&
            !ds._isExcludedFromAutoLiquidity[from] &&
            ds._swapAndLiquifyEnabled
        ) {
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;
        if (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) {
            takeFee = false;
        }
        _tokenTransfer(from, to, amount, takeFee);
    }
    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // split contract balance into halves
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForETH(half);

        // this is the amount of ETH that we just swapped into
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // take marketing fee
        uint256 marketingFee = newBalance.mul(50).div(100);
        uint256 ethForLiquidity = newBalance.sub(marketingFee);
        if (marketingFee > 0) {
            payable(ds._developerWallet).transfer(marketingFee);
            emit MarketingFeeSent(ds._developerWallet, marketingFee);
        }

        // add liquidity to uniswap
        addLiquidity(otherHalf, ethForLiquidity);

        emit SwapAndLiquify(half, ethForLiquidity, otherHalf);
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds._uniswapV2Router.WETH();

        _approve(address(this), address(ds._uniswapV2Router), tokenAmount);

        // make the swap
        ds._uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(
            _msgSender(),
            spender,
            ds._allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(
            _msgSender(),
            spender,
            ds._allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds._uniswapV2Router), tokenAmount);

        // add the liquidity
        ds._uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            ds._developerWallet,
            block.timestamp
        );
    }
    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            currentRate
        );

        ds._tOwned[sender] = ds._tOwned[sender].sub(tAmount);
        ds._rOwned[sender] = ds._rOwned[sender].sub(rAmount);
        ds._rOwned[recipient] = ds._rOwned[recipient].add(rTransferAmount);

        takeTransactionFee(address(this), tLiquidity, currentRate);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function takeTransactionFee(
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (tAmount <= 0) {
            return;
        }

        uint256 rAmount = tAmount.mul(currentRate);
        ds._rOwned[to] = ds._rOwned[to].add(rAmount);
        if (ds._isExcluded[to]) {
            ds._tOwned[to] = ds._tOwned[to].add(tAmount);
        }
    }
    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            currentRate
        );

        ds._tOwned[sender] = ds._tOwned[sender].sub(tAmount);
        ds._rOwned[sender] = ds._rOwned[sender].sub(rAmount);
        ds._tOwned[recipient] = ds._tOwned[recipient].add(tTransferAmount);
        ds._rOwned[recipient] = ds._rOwned[recipient].add(rTransferAmount);

        takeTransactionFee(address(this), tLiquidity, currentRate);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._rTotal = ds._rTotal.sub(rFee);
        ds._tFeeTotal = ds._tFeeTotal.add(tFee);
    }
    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            currentRate
        );

        ds._rOwned[sender] = ds._rOwned[sender].sub(rAmount);
        ds._tOwned[recipient] = ds._tOwned[recipient].add(tTransferAmount);
        ds._rOwned[recipient] = ds._rOwned[recipient].add(rTransferAmount);

        takeTransactionFee(address(this), tLiquidity, currentRate);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function calculateFee(
        uint256 amount,
        uint256 fee
    ) private pure returns (uint256) {
        return amount.mul(fee).div(1000);
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 rSupply = ds._rTotal;
        uint256 tSupply = ds._tTotal;
        for (uint256 i = 0; i < ds._excluded.length; i++) {
            if (
                ds._rOwned[ds._excluded[i]] > rSupply ||
                ds._tOwned[ds._excluded[i]] > tSupply
            ) return (ds._rTotal, ds._tTotal);
            rSupply = rSupply.sub(ds._rOwned[ds._excluded[i]]);
            tSupply = tSupply.sub(ds._tOwned[ds._excluded[i]]);
        }
        if (rSupply < ds._rTotal.div(ds._tTotal))
            return (ds._rTotal, ds._tTotal);
        return (rSupply, tSupply);
    }
}
