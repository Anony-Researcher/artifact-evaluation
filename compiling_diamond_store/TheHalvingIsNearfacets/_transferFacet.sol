// BTC Havling takes place on block # 840,000
// Official Links for The Halving is Near
// Telegram: https://t.me/TheHalvingIsNear
// X: https://x.com/THIN_crypto
// Website: https://www.thehalvingisnear.com

pragma solidity 0.8.19;
import "./TestLib.sol";
contract _transferFacet is ERC20, Ownable {
    event SetExemptFromFees(address _address, bool _isExempt);
    event SetExemptFromLimits(address _address, bool _isExempt);
    event UpdatedMaxTransaction(uint256 newMax);
    event UpdatedMaxWallet(uint256 newMax);
    event UpdatedBuyTax(uint256 newAmt);
    event UpdatedSellTax(uint256 newAmt);
    event RemovedLimits();
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.exemptFromFees[from] || ds.exemptFromFees[to]) {
            super._transfer(from, to, amount);
            return;
        }

        checkLimits(from, to, amount);

        amount -= handleTax(from, to, amount);

        super._transfer(from, to, amount);
    }
    function setExemptFromFees(
        address _address,
        bool _isExempt
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_address != address(0), "Zero Address");
        ds.exemptFromFees[_address] = _isExempt;
        emit SetExemptFromFees(_address, _isExempt);
    }
    function setExemptFromLimits(
        address _address,
        bool _isExempt
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_address != address(0), "Zero Address");
        if (!_isExempt) {
            require(_address != ds.lpPair, "Cannot remove pair");
        }
        ds.exemptFromLimits[_address] = _isExempt;
        emit SetExemptFromLimits(_address, _isExempt);
    }
    function updateMaxTransaction(uint256 newNumInTokens) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNumInTokens >= ((totalSupply() * 5) / 1000) / (10 ** decimals()),
            "Too low"
        );
        ds.maxTransaction = newNumInTokens * (10 ** decimals());
        emit UpdatedMaxTransaction(ds.maxTransaction);
    }
    function updateMaxWallet(uint256 newNumInTokens) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNumInTokens >=
                ((totalSupply() * 15) / 1000) / (10 ** decimals()),
            "Too low"
        );
        ds.maxWallet = newNumInTokens * (10 ** decimals());
        emit UpdatedMaxWallet(ds.maxWallet);
    }
    function updateBuyTax(uint256 _taxWithTwoDecimals) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTotalTax = _taxWithTwoDecimals;
        require(ds.buyTotalTax <= 1200, "Keep tax below 12%");
        emit UpdatedBuyTax(ds.buyTotalTax);
    }
    function updateSellTax(uint256 _taxWithTwoDecimals) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellTotalTax = _taxWithTwoDecimals;
        require(ds.sellTotalTax <= 1200, "Keep tax below 12%");
        emit UpdatedSellTax(ds.sellTotalTax);
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingActive = true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        ds.maxTransaction = totalSupply();
        ds.maxWallet = totalSupply();
        emit RemovedLimits();
    }
    function airdropToWallets(
        address[] calldata wallets,
        uint256[] calldata amountsInWei
    ) external onlyOwner {
        require(
            wallets.length == amountsInWei.length,
            "arrays length mismatch"
        );
        for (uint256 i = 0; i < wallets.length; i++) {
            super._transfer(msg.sender, wallets[i], amountsInWei[i]);
        }
    }
    function rescueTokens(address _token, address _to) external onlyOwner {
        require(_token != address(0), "_token address cannot be 0");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        SafeERC20.safeTransfer(IERC20(_token), _to, _contractBalance);
    }
    function updateTaxAddress(address _address) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_address != address(0), "zero address");
        ds.taxReceiverAddress = _address;
    }
    function checkLimits(
        address from,
        address to,
        uint256 amount
    ) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.tradingActive, "Trading not active");

        if (ds.limitsInEffect) {
            // buy
            if (ds.isAMMPair[from] && !ds.exemptFromLimits[to]) {
                require(
                    amount <= ds.maxTransaction,
                    "Buy transfer amount exceeded."
                );
                require(
                    amount + balanceOf(to) <= ds.maxWallet,
                    "Unable to exceed Max Wallet"
                );
            }
            // sell
            else if (ds.isAMMPair[to] && !ds.exemptFromLimits[from]) {
                require(
                    amount <= ds.maxTransaction,
                    "Sell transfer amount exceeds the maxTransactionAmt."
                );
            } else if (!ds.exemptFromLimits[to]) {
                require(
                    amount + balanceOf(to) <= ds.maxWallet,
                    "Unable to exceed Max Wallet"
                );
            }
        }
    }
    function handleTax(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            balanceOf(address(this)) >= ds.swapTokensAtAmt &&
            ds.swapEnabled &&
            !ds.swapping &&
            ds.isAMMPair[to]
        ) {
            ds.swapping = true;
            swapBack();
            ds.swapping = false;
        }

        uint256 tax = 0;

        // on sell
        if (ds.isAMMPair[to] && ds.sellTotalTax > 0) {
            tax = (amount * ds.sellTotalTax) / FEE_DIVISOR;
        }
        // on buy
        else if (ds.isAMMPair[from] && ds.buyTotalTax > 0) {
            tax = (amount * ds.buyTotalTax) / FEE_DIVISOR;
        }

        if (tax > 0) {
            super._transfer(from, address(this), tax);
        }

        return tax;
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance > ds.swapTokensAtAmt * 40) {
            contractBalance = ds.swapTokensAtAmt * 40;
        }

        swapTokensForETH(contractBalance);
    }
    function swapTokensForETH(uint256 tokenAmt) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(ds.dexRouter.WETH());

        ds.dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmt,
            0,
            path,
            address(ds.taxReceiverAddress),
            block.timestamp
        );
    }
}
