//SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, ERC20Detailed, Ownable {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    function totalSupply() public view override returns (uint) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address account) public view override returns (uint) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function transfer(
        address recipient,
        uint amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address towner,
        address spender
    ) public view override returns (uint) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[towner][spender];
    }
    function approve(
        address spender,
        uint amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint amount
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
    function setMarketingAddress(address payable wallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingaddress = wallet;
    }
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    function changeNumTokensSellToAddToLiquidity(
        uint256 _numTokensSellToAddToLiquidity
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.numTokensSellToAddToLiquidity = _numTokensSellToAddToLiquidity;
    }
    function excludeFromFee(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = true;
    }
    function includeInFee(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = false;
    }
    function changeMaxTxLimit(uint256 _number) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxTxAmount = _number;
    }
    function setSellFee(
        uint256 _onSellliquidityFee,
        uint256 _onSellMarketingFee
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.SELLmarketingFee = _onSellMarketingFee;
        ds.SELLliquidityFee = _onSellliquidityFee;
        ds.SELLtotalFee = ds.SELLliquidityFee.add(ds.SELLmarketingFee);
        uint256 onSelltotalFees;
        onSelltotalFees = ds.SELLmarketingFee.add(ds.SELLliquidityFee);
        require(onSelltotalFees <= 5, "Sell Fee should be 5% or less");
    }
    function setBuyFee(
        uint256 _onBuyliquidityFee,
        uint256 _onBuyMarketingFee
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.BUYmarketingFee = _onBuyMarketingFee;
        ds.BUYliquidityFee = _onBuyliquidityFee;
        ds.BUYtotalFee = ds.BUYliquidityFee.add(ds.BUYmarketingFee);
        uint256 onBuytotalFees;
        onBuytotalFees = ds.BUYmarketingFee.add(ds.BUYliquidityFee);
        require(onBuytotalFees <= 5, "Buy Fee should be 5% or less");
    }
    function withdrawStuckETh() external onlyOwner {
        require(address(this).balance > 0, "Can't withdraw negative or zero");
        payable(owner()).transfer(address(this).balance);
    }
    function removeStuckToken(address _address) external onlyOwner {
        require(
            _address != address(this),
            "Can't withdraw tokens destined for liquidity"
        );
        require(
            IERC20(_address).balanceOf(address(this)) > 0,
            "Can't withdraw 0"
        );

        IERC20(_address).transfer(
            owner(),
            IERC20(_address).balanceOf(address(this))
        );
    }
    function _transfer(
        address sender,
        address recipient,
        uint amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if (sender != owner() && recipient != owner()) {
            require(amount <= ds.maxTxAmount, "Transaction size limit reached");
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool overMinTokenBalance = contractTokenBalance >=
            ds.numTokensSellToAddToLiquidity;
        if (
            overMinTokenBalance &&
            !ds.swapping &&
            sender != ds.uniswapV2Pair &&
            ds.swapAndLiquifyEnabled
        ) {
            ds.swapping = true;

            uint256 walletTokens = contractTokenBalance
                .mul(ds.SELLmarketingFee)
                .div(ds.SELLtotalFee);
            uint256 contractBalance = address(this).balance;
            swapTokensForEth(walletTokens);
            uint256 newBalance = address(this).balance.sub(contractBalance);
            uint256 marketingShare = newBalance.mul(ds.SELLmarketingFee).div(
                (ds.SELLmarketingFee)
            );
            //uint256 rewardShare = newBalance.sub(marketingShare);
            payable(ds.marketingaddress).transfer(marketingShare);

            uint256 swapTokens = contractTokenBalance
                .mul(ds.SELLliquidityFee)
                .div(ds.SELLtotalFee);
            swapAndLiquify(swapTokens);

            ds.swapping = false;
        }

        bool takeFee = !ds.swapping;

        if (ds._isExcludedFromFee[sender] || ds._isExcludedFromFee[recipient]) {
            takeFee = false;
        }

        if (sender != ds.uniswapV2Pair && recipient != ds.uniswapV2Pair) {
            takeFee = false;
        }
        if (takeFee) {
            if (sender == ds.uniswapV2Pair) {
                ds.marketingFee = ds.BUYmarketingFee;
                ds.liquidityFee = ds.BUYliquidityFee;
                ds.totalFee = ds.BUYtotalFee;
            }
            if (recipient == ds.uniswapV2Pair) {
                ds.marketingFee = ds.SELLmarketingFee;
                ds.liquidityFee = ds.SELLliquidityFee;
                ds.totalFee = ds.SELLtotalFee;
            }
        }

        if (takeFee) {
            uint256 taxAmount = amount.mul(ds.totalFee).div(100);
            uint256 TotalSent = amount.sub(taxAmount);
            ds._balances[sender] = ds._balances[sender].sub(
                amount,
                "ERC20: transfer amount exceeds balance"
            );
            ds._balances[recipient] = ds._balances[recipient].add(TotalSent);
            ds._balances[address(this)] = ds._balances[address(this)].add(
                taxAmount
            );
            emit Transfer(sender, recipient, TotalSent);
            emit Transfer(sender, address(this), taxAmount);
        } else {
            ds._balances[sender] = ds._balances[sender].sub(
                amount,
                "ERC20: transfer amount exceeds balance"
            );
            ds._balances[recipient] = ds._balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // make the swap
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // add the liquidity
        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }
    function _approve(address towner, address spender, uint amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(towner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ds._allowances[towner][spender] = amount;
        emit Approval(towner, spender, amount);
    }
    function increaseAllowance(
        address spender,
        uint addedValue
    ) public returns (bool) {
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
        uint subtractedValue
    ) public returns (bool) {
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
}
