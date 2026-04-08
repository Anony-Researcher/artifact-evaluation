// Website: https://cashcab.io
// Twitter: https://twitter.com/CashCabETH
// TG: https://t.me/cashcab

// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.19;
import "./TestLib.sol";
contract enableTradingFacet is ERC20 {
    event TradingEnabled(bool enabled);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event LimitsRemoved();
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled, "Trade is already enabled");
        ds.tradingEnabled = true;
        emit TradingEnabled(true);
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "Transfer amount must be greater than zero");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (ds.exemptFee[sender] || ds.exemptFee[recipient]) {
            super._transfer(sender, recipient, amount);
        } else {
            require(ds.tradingEnabled, "Trading is not enabled");

            if (ds.limitsInEffect) {
                // wen buy
                if (
                    ds.automatedMarketMakerPairs[sender] &&
                    !ds._isExcludedMaxTransactionAmount[recipient]
                ) {
                    require(
                        amount < ds.maxWalletSize,
                        "Buy transfer amount exceeds the maxTransactionAmount."
                    );
                    require(
                        amount + balanceOf(recipient) < ds.maxWalletSize,
                        "Max wallet exceeded"
                    );
                }
                //wen sell
                else if (
                    ds.automatedMarketMakerPairs[recipient] &&
                    !ds._isExcludedMaxTransactionAmount[sender]
                ) {
                    require(
                        amount < ds.maxWalletSize,
                        "Sell transfer amount exceeds the maxTransactionAmount."
                    );
                } else if (!ds._isExcludedMaxTransactionAmount[recipient]) {
                    require(
                        amount + balanceOf(recipient) < ds.maxWalletSize,
                        "Max wallet exceeded"
                    );
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= ds.swapTokenAtAmount;
            if (
                canSwap &&
                !ds._isSwapping &&
                !ds.automatedMarketMakerPairs[sender]
            ) {
                ds._isSwapping = true;
                distributeTaxes(contractTokenBalance);
                ds._isSwapping = false;
            }
            if (ds.automatedMarketMakerPairs[sender] && ds.buyTaxRates > 0) {
                uint256 taxAmount = (amount * ds.buyTaxRates) /
                    ds.feeDenominator;
                uint256 transferAmount = amount - taxAmount;

                super._transfer(sender, address(this), taxAmount);
                super._transfer(sender, recipient, transferAmount);
            } else if (
                ds.automatedMarketMakerPairs[recipient] && ds.sellTaxRates > 0
            ) {
                uint256 taxAmount = (amount * ds.sellTaxRates) /
                    ds.feeDenominator;
                uint256 transferAmount = amount - taxAmount;

                super._transfer(sender, address(this), taxAmount);
                super._transfer(sender, recipient, transferAmount);
            } else {
                super._transfer(sender, recipient, amount);
            }
        }
    }
    function changeTaxWallets(
        address _marketing,
        address _development,
        address _cex
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_marketing != address(0), "Address Cant Be Zero");
        require(_development != address(0), "Address Cant Be Zero");
        require(_cex != address(0), "Address Cant Be Zero");

        ds.marketing = _marketing;
        ds.development = _development;
        ds.cex = _cex;
    }
    function sendETH(
        address _to,
        uint256 amount
    ) internal nonReentrant returns (bool) {
        if (address(this).balance < amount) return false;

        (bool success, ) = payable(_to).call{value: amount}("");

        return success;
    }
    function setAutomatedMarketMakerPair(
        address lpPair,
        bool value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[lpPair] = value;
        emit SetAutomatedMarketMakerPair(lpPair, value);
    }
    function addExemptFee(address _address) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.exemptFee[_address] = true;
    }
    function removeExemptFee(address _address) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.exemptFee[_address] = false;
    }
    function increaseMaxWalletByPercentage(
        uint256 percentage
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            percentage >= 100,
            "Percentage must be greater than or equal to 1%"
        );
        ds.maxWalletSize = (totalSupply() * percentage) / 10000; // percentage of the supply
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(updAds != address(this));
        ds._isExcludedMaxTransactionAmount[updAds] = isEx;
    }
    function changeBuyTax(uint256 _newRates) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_newRates <= 3000, "Tax need to be less than 30%");
        ds.buyTaxRates = _newRates;
    }
    function changeSellTax(uint256 _newRates) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_newRates <= 3000, "Tax need to be less than 30%");
        ds.sellTaxRates = _newRates;
    }
    function changeSwapTokenAtAmount(uint256 newAmount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newAmount > totalSupply() / 100_000 &&
                newAmount < (totalSupply() / 100),
            "Amount should be greater than 1 and less than 1% of total supply"
        );
        ds.swapTokenAtAmount = newAmount;
    }
    function removeLimits() external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        ds.maxWalletSize = totalSupply();
        emit LimitsRemoved();
        return true;
    }
    function distributeTaxes(uint256 contractTokenBalance) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _swapTokensForETH(contractTokenBalance);

        uint256 marketingFee = (address(this).balance * 20) / 100;
        uint256 developmentFee = (address(this).balance * 40) / 100;
        uint256 cexFee = (address(this).balance * 40) / 100;

        if (marketingFee > 0) {
            sendETH(ds.marketing, marketingFee);
        }
        if (developmentFee > 0) {
            sendETH(ds.development, developmentFee);
        }
        if (cexFee > 0) {
            sendETH(ds.cex, cexFee);
        }
    }
    function _swapTokensForETH(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.router), tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.router.WETH();
        try
            ds.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {}
    }
    function rescueETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address payable marketingAddress = payable(ds.marketing);
        marketingAddress.transfer(address(this).balance);
    }
}
