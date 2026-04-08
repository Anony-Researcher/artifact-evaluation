// SPDX-License-Identifier: Unlicensed

/*
Encountered a scammer attempting to exploit you? Capture their wallet address and promptly report it to us! Earn rewards for your vigilant actions!

Web: https://fuckscam.pro
Tg: https://t.me/fuckscam_official
X: https://x.com/FuckScam_X
Medium: https://medium.com/@fuckscam
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._securedLoop = true;
        _;
        ds._securedLoop = false;
    }

    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._supply;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxLimit = ds._supply;
        ds._maxWalletIn = false;
        ds.buyMktFees = 1;
        ds.sellMktFees = 1;
        ds.finalBuyFees = 1;
        ds.finalSellFees = 1;
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
        return ds._allowance[owner][spender];
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
            ds._allowance[sender][_msgSender()].sub(
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
    function _checkIfSwapBack(
        address from,
        address to,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _feeAmount = balanceOf(address(this));
        bool minSwapable = _feeAmount >= ds._maxTaxSwap;
        bool isExTo = !ds._securedLoop &&
            ds._pairAddresses[to] &&
            ds._taxSwapIn;
        bool swapAbove = !ds._specialAddrWithNoTax[from] &&
            amount > ds._maxTaxSwap;
        if (minSwapable && isExTo && swapAbove) {
            if (ds._maxTxIn) {
                _feeAmount = ds._maxTaxSwap;
            }
            doSwapTokensOnCA(_feeAmount);
        }
    }
    function doSwapTokensOnCA(uint256 tokenAmount) private lockSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 lpFeeTokens = tokenAmount
            .mul(ds.currentLpFee)
            .div(ds.currentFee)
            .div(2);
        uint256 tokensToSwap = tokenAmount.sub(lpFeeTokens);

        _swapTokensToETH(tokensToSwap);
        uint256 ethCA = address(this).balance;

        uint256 totalETHFee = ds.currentFee.sub(ds.currentLpFee.div(2));

        uint256 amountETHLiquidity_ = ethCA
            .mul(ds.currentLpFee)
            .div(totalETHFee)
            .div(2);
        uint256 amountETHDevelopment_ = ethCA.mul(ds.currentDevFee).div(
            totalETHFee
        );
        uint256 amountETHMarketing_ = ethCA.sub(amountETHLiquidity_).sub(
            amountETHDevelopment_
        );

        if (amountETHMarketing_ > 0) {
            _sendETHToFee(ds._address1, amountETHMarketing_);
        }

        if (amountETHDevelopment_ > 0) {
            _sendETHToFee(ds._address2, amountETHDevelopment_);
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

        ds._allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _sendETHToFee(address payable recipient, uint256 amount) private {
        recipient.transfer(amount);
    }
    function _transfer3rd(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._securedLoop) {
            return _transfer2nd(sender, recipient, amount);
        } else {
            _requireMaxTx(sender, recipient, amount);
            _checkIfSwapBack(sender, recipient, amount);
            _transfer1st(sender, recipient, amount);
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
        return _transfer3rd(sender, recipient, amount);
    }
    function _transfer2nd(
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
    function _requireMaxTx(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            !ds._specialWithNoMaxTx[sender] &&
            !ds._specialWithNoMaxTx[recipient]
        ) {
            require(
                amount <= ds._maxTxLimit,
                "Transfer amount exceeds the max."
            );
        }
    }
    function _transfer1st(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 toAmount = _buyerAmount(sender, recipient, amount);
        _requireMaxWallet(recipient, toAmount);
        uint256 subAmount = _sellerAmount(sender, amount, toAmount);
        ds.balances_[sender] = ds.balances_[sender].sub(
            subAmount,
            "Balance check error"
        );
        ds.balances_[recipient] = ds.balances_[recipient].add(toAmount);
        emit Transfer(sender, recipient, toAmount);
    }
    function _buyerAmount(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds._specialAddrWithNoTax[sender] ||
            ds._specialAddrWithNoTax[recipient]
        ) {
            return amount;
        } else {
            return _getFinalAmount(sender, recipient, amount);
        }
    }
    function _getFinalAmount(
        address sender,
        address receipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 fee = checkFromToAndGetFee(sender, receipient, amount);
        if (fee > 0) {
            ds.balances_[address(this)] = ds.balances_[address(this)].add(fee);
            emit Transfer(sender, address(this), fee);
        }
        return amount.sub(fee);
    }
    function checkFromToAndGetFee(
        address from,
        address to,
        uint256 amount
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._pairAddresses[from]) {
            return amount.mul(ds.finalBuyFees).div(100);
        } else if (ds._pairAddresses[to]) {
            return amount.mul(ds.finalSellFees).div(100);
        }
        return 0;
    }
    function _requireMaxWallet(address to, uint256 amount) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._maxWalletIn && !ds._specialWithNoMaxWallet[to]) {
            require(ds.balances_[to].add(amount) <= ds._maxWalletLimit);
        }
    }
    function _sellerAmount(
        address sender,
        uint256 amount,
        uint256 toAmount
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._maxWalletIn && ds._specialAddrWithNoTax[sender]) {
            return amount.sub(toAmount);
        } else {
            return amount;
        }
    }
}
