// SPDX-License-Identifier: Unlicensed

/**
https://pepebtc.tech/
https://t.me/PepeBitcoinPortal
https://twitter.com/PepeBitcoin_
**/

pragma solidity ^0.8.18;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
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
                "the transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function setTrading(bool _tradingOpen) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingOpen = _tradingOpen;
    }
    function blockBots(address[] memory bots_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < bots_.length; i++) {
            ds.bots[bots_[i]] = true;
        }
    }
    function unblockBot(address notbot) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bots[notbot] = false;
    }
    function setFee(
        uint256 redisFeeOnBuy,
        uint256 redisFeeOnSell,
        uint256 taxFeeOnBuy,
        uint256 taxFeeOnSell
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            redisFeeOnBuy >= 0 && redisFeeOnBuy <= 4,
            "Buy rewards must be between 0% and 4%"
        );
        require(
            taxFeeOnBuy >= 0 && taxFeeOnBuy <= 95,
            "Buy tax must be between 0% and 95%"
        );
        require(
            redisFeeOnSell >= 0 && redisFeeOnSell <= 4,
            "Sell rewards must be between 0% and 4%"
        );
        require(
            taxFeeOnSell >= 0 && taxFeeOnSell <= 95,
            "Sell tax must be between 0% and 95%"
        );

        ds._redisFeeOnBuy = redisFeeOnBuy;
        ds._redisFeeOnSell = redisFeeOnSell;
        ds._taxFeeOnBuy = taxFeeOnBuy;
        ds._taxFeeOnSell = taxFeeOnSell;
    }
    function setMinSwapTokensThreshold(
        uint256 swapTokensAtAmount
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._swapTokensAtAmount = swapTokensAtAmount;
    }
    function toggleSwap(bool _swapEnabled) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = _swapEnabled;
    }
    function setMaxTxnAmount(
        uint256 maxTxAmount,
        bool maxTxn,
        bool maxTxnCan
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = maxTxAmount;
        ds._maxTxn = maxTxn;
        ds._maxTxnCan = maxTxnCan;
    }
    function setMaxWalletSize(
        uint256 maxWalletSize,
        bool maxWallet,
        bool maxWalletCan
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxWalletSize = maxWalletSize;
        ds._maxWallet = maxWallet;
        ds._maxWalletCan = maxWalletCan;
    }
    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds._isExcludedFromFee[accounts[i]] = excluded;
        }
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "Cant transfer from address zero");
        require(to != address(0), "Cant transfer to address zero");
        require(amount > 0, "Amount should be above zero");

        if (from != owner() && to != owner()) {
            //Trade start check
            if (!ds.tradingOpen) {
                require(
                    from == owner(),
                    "Only owner can trade before trading activation"
                );
            }

            require(
                amount <= ds._maxTxAmount,
                "Exceeded max transaction limit"
            );
            require(
                !ds.bots[from] && !ds.bots[to],
                "This account is on the blacklist"
            );

            if (to != ds.uniswapV2Pair) {
                require(
                    balanceOf(to) + amount < ds._maxWalletSize,
                    "Exceeds max wallet balance"
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= ds._swapTokensAtAmount;

            if (contractTokenBalance >= ds._maxTxAmount) {
                contractTokenBalance = ds._maxTxAmount;
            }

            if (
                canSwap &&
                !ds.inSwap &&
                from != ds.uniswapV2Pair &&
                ds.swapEnabled &&
                !ds._isExcludedFromFee[from] &&
                !ds._isExcludedFromFee[to]
            ) {
                swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        bool takeFee = true;

        //Transfer Tokens
        if (
            (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) ||
            (from != ds.uniswapV2Pair && to != ds.uniswapV2Pair)
        ) {
            takeFee = false;
        } else {
            //Set Fee for Buys
            if (from == ds.uniswapV2Pair && to != address(ds.uniswapV2Router)) {
                ds._redisFee = ds._redisFeeOnBuy;
                ds._taxFee = ds._taxFeeOnBuy;
            }

            //Set Fee for Sells
            if (to == ds.uniswapV2Pair && from != address(ds.uniswapV2Router)) {
                ds._redisFee = ds._redisFeeOnSell;
                ds._taxFee = ds._taxFeeOnSell;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "Can't approve from zero address");
        require(spender != address(0), "Can't approve to zero address");

        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function manualswap() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _msgSender() == ds._developmentAddress ||
                _msgSender() == ds._marketingAddress
        );
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketingAddress.transfer(amount);
    }
    function manualsend() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _msgSender() == ds._developmentAddress ||
                _msgSender() == ds._marketingAddress
        );
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreAllFee();
    }
    function removeAllFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._redisFee == 0 && ds._taxFee == 0) return;

        ds._previousredisFee = ds._redisFee;
        ds._previoustaxFee = ds._taxFee;

        ds._redisFee = 0;
        ds._taxFee = 0;
    }
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTeam
        ) = _getValues(tAmount);
        ds._rOwned[sender] = ds._rOwned[sender].sub(rAmount);
        ds._rOwned[recipient] = ds._rOwned[recipient].add(rTransferAmount);
        _takeTeam(tTeam);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _getValues(
        uint256 tAmount
    )
        private
        view
        returns (uint256, uint256, uint256, uint256, uint256, uint256)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (uint256 tTransferAmount, uint256 tFee, uint256 tTeam) = _getTValues(
            tAmount,
            ds._redisFee,
            ds._taxFee
        );
        uint256 currentRate = _getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tTeam,
            currentRate
        );
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
    }
    function _getTValues(
        uint256 tAmount,
        uint256 redisFee,
        uint256 taxFee
    ) private pure returns (uint256, uint256, uint256) {
        uint256 tFee = tAmount.mul(redisFee).div(100);
        uint256 tTeam = tAmount.mul(taxFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
        return (tTransferAmount, tFee, tTeam);
    }
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    function tokenFromReflection(
        uint256 rAmount
    ) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            rAmount <= ds._rTotal,
            "Amount has to be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
    function _takeTeam(uint256 tTeam) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 currentRate = _getRate();
        uint256 rTeam = tTeam.mul(currentRate);
        ds._rOwned[address(this)] = ds._rOwned[address(this)].add(rTeam);
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 rSupply = ds._rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < ds._rTotal.div(_tTotal)) return (ds._rTotal, _tTotal);
        return (rSupply, tSupply);
    }
    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTeam,
        uint256 currentRate
    ) private pure returns (uint256, uint256, uint256) {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTeam.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._rTotal = ds._rTotal.sub(rFee);
        ds._tFeeTotal = ds._tFeeTotal.add(tFee);
    }
    function restoreAllFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._redisFee = ds._previousredisFee;
        ds._taxFee = ds._previoustaxFee;
    }
}
