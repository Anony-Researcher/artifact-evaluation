/**
$CHEERS to the Bull
Web: https://cheers-erc.xyz/
TG: https://t.me/cheersentry
X: https://x.com/pepechampagne
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
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
            ds._allowances[sender][_msgSender()] - amount
        );
        return true;
    }
    function includeOrExcludeFromFee(
        address account,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromFee[account] = value;
    }
    function includeOrExcludeFromMaxTxn(
        address account,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromMaxTxn[account] = value;
    }
    function includeOrExcludeFromMaxHolding(
        address account,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromMaxHolding[account] = value;
    }
    function setMinTokenToSwap(uint256 _amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minTokenToSwap = _amount * 1e18;
    }
    function setMaxHoldLimit(uint256 _amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxHoldLimit = _amount * 1e18;
    }
    function setMaxTxnLimit(uint256 _amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxTxnLimit = _amount * 1e18;
    }
    function setBuyFeePercent(uint256 _marketingFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingFeeOnBuying = _marketingFee;
    }
    function setSellFeePercent(uint256 _marketingFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingFeeOnSelling = _marketingFee;
    }
    function setDistributionStatus(bool _value) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.distributeAndLiquifyStatus = _value;
    }
    function enableOrDisableFees(bool _value) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.feesStatus = _value;
    }
    function updateAddresses(address _marketingWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingWallet = _marketingWallet;
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.trading, ": already enabled");

        ds.trading = true;
        ds.feesStatus = true;
        ds.distributeAndLiquifyStatus = true;
        ds.launchedAt = block.timestamp;
    }
    function removeStuckEth(address _receiver) public onlyOwner {
        payable(_receiver).transfer(address(this).balance);
    }
    function withdrawETH(uint256 _amount) external onlyOwner {
        require(address(this).balance >= _amount, "Invalid Amount");
        payable(msg.sender).transfer(_amount);
    }
    function withdrawToken(IERC20 _token, uint256 _amount) external onlyOwner {
        require(_token.balanceOf(address(this)) >= _amount, "Invalid Amount");
        _token.transfer(msg.sender, _amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(amount > 0, "Amount must be greater than zero");
        if (!ds.isExcludedFromMaxTxn[from] && !ds.isExcludedFromMaxTxn[to]) {
            require(amount <= ds.maxTxnLimit, " max txn limit exceeds");

            // ds.trading disable till launch
            if (!ds.trading) {
                require(
                    ds.dexPair != from && ds.dexPair != to,
                    ": ds.trading is disable"
                );
            }
        }

        if (!ds.isExcludedFromMaxHolding[to]) {
            require(
                (balanceOf(to) + amount) <= ds.maxHoldLimit,
                ": max hold limit exceeds"
            );
        }

        // swap and liquify
        distributeAndLiquify(from, to);

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to ds.isExcludedFromFee account then remove the fee
        if (
            ds.isExcludedFromFee[from] ||
            ds.isExcludedFromFee[to] ||
            !ds.feesStatus
        ) {
            takeFee = false;
        }

        //transfer amount, it will take tax, burn, liquidity fee
        _tokenTransfer(from, to, amount, takeFee);
    }
    function distributeAndLiquify(address from, address to) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractTokenBalance = balanceOf(address(this));

        bool shouldSell = contractTokenBalance >= ds.minTokenToSwap;

        if (
            shouldSell &&
            from != ds.dexPair &&
            ds.distributeAndLiquifyStatus &&
            !(from == address(this) && to == ds.dexPair) // swap 1 time
        ) {
            // approve contract
            _approve(address(this), address(ds.dexRouter), ds.minTokenToSwap);

            // now is to lock into liquidty pool
            Utils.swapTokensForEth(address(ds.dexRouter), ds.minTokenToSwap);
            uint256 ethForMarketing = address(this).balance;

            // sending Eth to Marketing wallet
            if (ethForMarketing > 0)
                payable(ds.marketingWallet).transfer(ethForMarketing);
        }
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), " approve from the zero address");
        require(spender != address(0), "approve to the zero address");

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
            ds._allowances[_msgSender()][spender] + (addedValue)
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
            ds._allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.dexPair == sender && takeFee) {
            uint256 allFee;
            uint256 tTransferAmount;
            allFee = totalBuyFeePerTx(amount);
            tTransferAmount = amount - allFee;

            ds._balances[sender] = ds._balances[sender] - amount;
            ds._balances[recipient] = ds._balances[recipient] + tTransferAmount;
            emit Transfer(sender, recipient, tTransferAmount);

            takeTokenFee(sender, allFee);
        } else if (ds.dexPair == recipient && takeFee) {
            uint256 allFee = totalSellFeePerTx(amount);
            uint256 tTransferAmount = amount - allFee;
            ds._balances[sender] = ds._balances[sender] - amount;
            ds._balances[recipient] = ds._balances[recipient] + tTransferAmount;
            emit Transfer(sender, recipient, tTransferAmount);

            takeTokenFee(sender, allFee);
        } else {
            ds._balances[sender] = ds._balances[sender] - amount;
            ds._balances[recipient] = ds._balances[recipient] + (amount);
            emit Transfer(sender, recipient, amount);
        }
    }
    function totalBuyFeePerTx(uint256 amount) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 fee = (amount * ds.marketingFeeOnBuying) / (ds.percentDivider);
        return fee;
    }
    function takeTokenFee(address sender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._balances[address(this)] = ds._balances[address(this)] + (amount);

        emit Transfer(sender, address(this), amount);
    }
    function totalSellFeePerTx(uint256 amount) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 fee = (amount * ds.marketingFeeOnSelling) / (ds.percentDivider);
        return fee;
    }
}
