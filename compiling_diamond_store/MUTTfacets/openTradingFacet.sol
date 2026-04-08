/**
Web: https://MUTTeth.com

TG : https://T.me/MUTTeth

X : https://twitter.com/MUTTeth
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;
import "./TestLib.sol";
contract openTradingFacet is ERC20, Ownable {
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function openTrading(
        uint256 openingFee,
        uint256 maxOpen,
        uint256 _blocksnipe
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "Trading is already open");
        ds.BuyFee = openingFee;
        ds.SellFee = openingFee;
        ds.maxTransactionAmount = ds.initialTotalSupply / maxOpen;
        ds.maxWallet = ds.initialTotalSupply / maxOpen;
        ds.blockSnipe = _blocksnipe;
        ds.blockStart = block.number;
        ds.swapEnabled = true;
        ds.tradingOpen = true;
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedMaxTransactionAmount[updAds] = isEx;
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
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
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

        uint256 blockNum = block.number;

        if (ds.limitsInEffect) {
            if (blockNum > (ds.blockStart + ds.blockSnipe)) {
                ds.BuyFee = 40;
                ds.SellFee = 40;

                ds.maxTransactionAmount = ds.initialTotalSupply / 200;
                ds.maxWallet = ds.initialTotalSupply / 100;
            }

            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !ds.swapping
            ) {
                if (!ds.tradingOpen) {
                    require(
                        ds._isExcludedFromFees[from] ||
                            ds._isExcludedFromFees[to],
                        "Trading is not active."
                    );
                }

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
                } else if (
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
            !ds._isExcludedFromFees[to] &&
            (ds.swapInBlock[blockNum] < 3)
        ) {
            ds.swapping = true;
            swapBack();
            ++ds.swapInBlock[blockNum];
            ds.swapping = false;
        }

        bool takeFee = !ds.swapping;

        if (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        if (takeFee) {
            if (ds.automatedMarketMakerPairs[to]) {
                fees = (amount * ds.SellFee) / 100;
            } else {
                fees = (amount * ds.BuyFee) / 100;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            amount -= fees;
        }
        super._transfer(from, to, amount);
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
    }
    function setFee(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_buyFee <= 30 && _sellFee <= 30, "Fees cannot exceed 30%");
        ds.BuyFee = _buyFee;
        ds.SellFee = _sellFee;
    }
    function updateMarketingWallet(
        address newMarketingWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingWallet = newMarketingWallet;
    }
    function setSwapTokensAtAmount(uint256 _amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapTokensAtAmount = _amount * (10 ** 18);
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        uint256 tokensToSwap;

        if (contractBalance == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount * 100) {
            contractBalance = ds.swapTokensAtAmount * 100;
        }

        tokensToSwap = contractBalance;
        swapTokensForEth(tokensToSwap);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds._uniswapV2Router.WETH();

        _approve(address(this), address(ds._uniswapV2Router), tokenAmount);

        ds._uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            ds.marketingWallet,
            block.timestamp
        );
    }
    function clearStuckTokens(uint256 amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds.marketingWallet);
        swapTokensForEth(amount * (10 ** 18));
    }
    function airdrop(
        address[] calldata addresses,
        uint256[] calldata amounts
    ) external {
        require(addresses.length > 0 && amounts.length == addresses.length);
        address from = msg.sender;

        for (uint i = 0; i < addresses.length; i++) {
            _transfer(from, addresses[i], amounts[i] * (10 ** 18));
        }
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
