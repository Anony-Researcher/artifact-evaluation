/**

Website     : https://ai-mix.io/
Telegram    : https://t.me/aimixio
Twitter     : https://twitter.com/aimixio

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;
    using Address for address;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapTokensForETH(uint256 amountIn, address[] path);
    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
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
    function setMarketPairStatus(
        address account,
        bool newValue
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isMarketPair[account] = newValue;
    }
    function AimixExcludeMaxTx(address holder, bool exempt) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTxLimitExempt[holder] = exempt;
    }
    function AimixExcludedFromFee(
        address account,
        bool newValue
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromFee[account] = newValue;
    }
    function AimixSetFee(
        uint256 newBuyLiquidityTax,
        uint256 newBuyMarketingTax,
        uint256 newBuyOwnerTax,
        uint256 newSellLiquidityTax,
        uint256 newSellMarketingTax,
        uint256 newSellOwnerTax
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._buyLiquidityFee = newBuyLiquidityTax;
        ds._buyMarketingFee = newBuyMarketingTax;
        ds._buyDeployerFee = newBuyOwnerTax;

        ds._totalTaxIfBuying = ds._buyLiquidityFee.add(ds._buyMarketingFee).add(
            ds._buyDeployerFee
        );

        ds._sellLiquidityFee = newSellLiquidityTax;
        ds._sellMarketingFee = newSellMarketingTax;
        ds._sellDeployerFee = newSellOwnerTax;

        ds._totalTaxIfSelling = ds
            ._sellLiquidityFee
            .add(ds._sellMarketingFee)
            .add(ds._sellDeployerFee);
    }
    function setDistributionSettings(
        uint256 newLiquidityShare,
        uint256 newMarketingShare,
        uint256 newOwnerShare
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._liquidityShare = newLiquidityShare;
        ds._marketingShare = newMarketingShare;
        ds._deployerShare = newOwnerShare;

        ds._totalDistributionShares = ds
            ._liquidityShare
            .add(ds._marketingShare)
            .add(ds._deployerShare);
    }
    function AimixSetMax(
        uint256 maxTxAmount,
        uint256 MaxLimit
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = maxTxAmount;
        ds._walletMax = MaxLimit;
    }
    function enableDisableWalletLimit(bool newValue) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.checkWalletLimit = newValue;
    }
    function AimixExludeMaxWallet(
        address holder,
        bool exempt
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isWalletLimitExempt[holder] = exempt;
    }
    function setNumTokensBeforeSwap(uint256 newLimit) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minimumTokensBeforeSwap = newLimit;
    }
    function AimixMarketingWallet(address newAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingWalletAddress = payable(newAddress);
    }
    function AimixOwnerWallet(address newAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.DeployerWalletAddress = payable(newAddress);
    }
    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    function setSwapAndLiquifyByLimitOnly(bool newValue) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapAndLiquifyByLimitOnly = newValue;
    }
    function AimixTransferTokenBalance(
        address _token,
        address _to,
        uint _value
    ) external onlyOwner returns (bool _sent) {
        if (_value == 0) {
            _value = IERC20(_token).balanceOf(address(this));
        } else {
            _sent = IERC20(_token).transfer(_to, _value);
        }
    }
    function AimixSwapBalance() external onlyOwner {
        uint balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
    function changeRouterVersion(
        address newRouterAddress
    ) public onlyOwner returns (address newPairAddress) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            newRouterAddress
        );

        newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(
            address(this),
            _uniswapV2Router.WETH()
        );

        if (newPairAddress == address(0)) //Create If Doesnt exist
        {
            newPairAddress = IUniswapV2Factory(_uniswapV2Router.factory())
                .createPair(address(this), _uniswapV2Router.WETH());
        }

        ds.uniswapPair = newPairAddress; //Set new pair address
        ds.uniswapV2Router = _uniswapV2Router; //Set new router address

        ds.isWalletLimitExempt[address(ds.uniswapPair)] = true;
        ds.isMarketPair[address(ds.uniswapPair)] = true;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (ds.inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        } else {
            if (!ds.isTxLimitExempt[sender] && !ds.isTxLimitExempt[recipient]) {
                require(
                    amount <= ds._maxTxAmount,
                    "Transfer amount exceeds the maxTxAmount."
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >=
                ds.minimumTokensBeforeSwap;

            if (
                overMinimumTokenBalance &&
                !ds.inSwapAndLiquify &&
                !ds.isMarketPair[sender] &&
                ds.swapAndLiquifyEnabled
            ) {
                if (ds.swapAndLiquifyByLimitOnly)
                    contractTokenBalance = ds.minimumTokensBeforeSwap;
                swapAndLiquify(contractTokenBalance);
            }

            ds._balances[sender] = ds._balances[sender].sub(
                amount,
                "Insufficient Balance"
            );

            uint256 finalAmount = (ds.isExcludedFromFee[sender] ||
                ds.isExcludedFromFee[recipient])
                ? amount
                : takeFee(sender, recipient, amount);

            if (ds.checkWalletLimit && !ds.isWalletLimitExempt[recipient])
                require(balanceOf(recipient).add(finalAmount) <= ds._walletMax);

            ds._balances[recipient] = ds._balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;
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
    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokensForLP = tAmount
            .mul(ds._liquidityShare)
            .div(ds._totalDistributionShares)
            .div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalETHFee = ds._totalDistributionShares.sub(
            ds._liquidityShare.div(2)
        );

        uint256 amountETHLiquidity = amountReceived
            .mul(ds._liquidityShare)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHOwner = amountReceived.mul(ds._deployerShare).div(
            totalETHFee
        );
        uint256 amountETHMarketing = amountReceived.sub(amountETHLiquidity).sub(
            amountETHOwner
        );

        if (amountETHMarketing > 0)
            transferToAddressETH(ds.marketingWalletAddress, amountETHMarketing);

        if (amountETHOwner > 0)
            transferToAddressETH(ds.DeployerWalletAddress, amountETHOwner);

        if (amountETHLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountETHLiquidity);
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
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
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
    function transferToAddressETH(
        address payable recipient,
        uint256 amount
    ) private {
        recipient.transfer(amount);
    }
    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 feeAmount = 0;

        if (ds.isMarketPair[sender]) {
            feeAmount = amount.mul(ds._totalTaxIfBuying).div(100);
        } else if (ds.isMarketPair[recipient]) {
            feeAmount = amount.mul(ds._totalTaxIfSelling).div(100);
        }

        if (feeAmount > 0) {
            ds._balances[address(this)] = ds._balances[address(this)].add(
                feeAmount
            );
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }
    function getCirculatingSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply.sub(balanceOf(ds.deadAddress));
    }
}
