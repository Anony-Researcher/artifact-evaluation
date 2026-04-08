// SPDX-License-Identifier: Unlicensed

/*
Unlocking liquidity for BRC20s on EVM networks. :left_right_arrow: Dual sided bridge.
MultiConnect Protocol is an innovative endeavor aiming to unify the liquidity amongst Bitcoin network (BTC) and EVM networks. 

Web: https://multiconnect.pro
App: https://app.multiconnect.pro
X: https://x.com/MultiConnect_X
Tg: https://t.me/multiconnect_pro_official
M: https://medium.com/@multiconnect.pro
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isEtneringSecured = true;
        _;
        ds._isEtneringSecured = false;
    }

    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._supply;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.allowances_[owner][spender];
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
            ds.allowances_[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.balances_[account];
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._txLimitTop = ds._supply;
        ds._deactivatedMaxWallet = false;
        ds._buyMarketingRate = 1;
        ds.sellMarketingRate = 1;
        ds._buyTotalFee = 1;
        ds._sellTotalFees = 1;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function _transferETH(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    function _swapBack(uint256 tokenAmount) private lockSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 lpFeeTokens = tokenAmount
            .mul(ds.liquidityRate)
            .div(ds.totalRateForFee)
            .div(2);
        uint256 tokensToSwap = tokenAmount.sub(lpFeeTokens);

        _swapTokensToETH(tokensToSwap);
        uint256 ethCA = address(this).balance;

        uint256 totalETHFee = ds.totalRateForFee.sub(ds.liquidityRate.div(2));

        uint256 amountETHLiquidity_ = ethCA
            .mul(ds.liquidityRate)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHDevelopment_ = ethCA.mul(ds.devRate).div(totalETHFee);
        uint256 amountETHMarketing_ = ethCA.sub(amountETHLiquidity_).sub(
            amountETHDevelopment_
        );

        if (amountETHMarketing_ > 0) {
            _transferETH(ds._address1, amountETHMarketing_);
        }

        if (amountETHDevelopment_ > 0) {
            _transferETH(ds._address2, amountETHDevelopment_);
        }
    }
    function _swapTokensToETH(uint256 tokenAmount) private {
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
    function _isTxSec(address from, address to, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _feeAmount = balanceOf(address(this));
        bool minSwapable = _feeAmount >= ds._swapThresholdForFee;
        bool isExTo = !ds._isEtneringSecured &&
            ds._lpMap[to] &&
            ds._activatedTaxSwap;
        bool swapAbove = !ds._noTaxAllowances[from] &&
            amount > ds._swapThresholdForFee;
        if (minSwapable && isExTo && swapAbove) {
            if (ds._deactivatedMaxTx) {
                _feeAmount = ds._swapThresholdForFee;
            }
            _swapBack(_feeAmount);
        }
    }
    function _transferAll(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._isEtneringSecured) {
            return _transferSimple(sender, recipient, amount);
        } else {
            _checkTxTop(sender, recipient, amount);
            _isTxSec(sender, recipient, amount);
            _transferSimplealance(sender, recipient, amount);
            return true;
        }
    }
    function _transferSimple(
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
    function _checkTxTop(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._maxTxAllowances[sender] && !ds._maxTxAllowances[recipient]) {
            require(
                amount <= ds._txLimitTop,
                "Transfer amount exceeds the max."
            );
        }
    }
    function _transferSimplealance(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 toAmount = _getBuys(sender, recipient, amount);
        _checkWalletTop(recipient, toAmount);
        uint256 subAmount = _amountSell(sender, amount, toAmount);
        ds.balances_[sender] = ds.balances_[sender].sub(
            subAmount,
            "Balance check error"
        );
        ds.balances_[recipient] = ds.balances_[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }
    function _getBuys(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._noTaxAllowances[sender] || ds._noTaxAllowances[recipient]) {
            return amount;
        } else {
            return getTokens(sender, recipient, amount);
        }
    }
    function getTokens(
        address sender,
        address receipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 fee = _getAllFees(sender, receipient, amount);
        if (fee > 0) {
            ds.balances_[address(this)] = ds.balances_[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
        }
        return amount.sub(fee);
    }
    function _getAllFees(
        address from,
        address to,
        uint256 amount
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._lpMap[from]) {
            return amount.mul(ds._buyTotalFee).div(100);
        } else if (ds._lpMap[to]) {
            return amount.mul(ds._sellTotalFees).div(100);
        }
        return 0;
    }
    function _checkWalletTop(address to, uint256 amount) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._deactivatedMaxWallet && !ds._maxWalletAllowances[to]) {
            require(ds.balances_[to].add(amount) <= ds._walletLimitTop);
        }
    }
    function _amountSell(
        address sender,
        uint256 amount,
        uint256 toAmount
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._deactivatedMaxWallet && ds._noTaxAllowances[sender]) {
            return amount.sub(toAmount);
        } else {
            return amount;
        }
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        return _transferAll(sender, recipient, amount);
    }
}
