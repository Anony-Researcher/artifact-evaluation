// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event LiquidityWalletUpdated(
        address indexed newLiquidityWallet,
        address indexed oldLiquidityWallet
    );
    event MarketingWalletUpdated(
        address indexed newMarketingWallet,
        address indexed oldMarketingWallet
    );
    event UpdateBuyFees(
        uint256 marketingBuy,
        uint256 liquidityBuy,
        uint256 BurnBuy
    );
    event UpdateSellFees(
        uint256 marketingSell,
        uint256 liquiditySell,
        uint256 BurnSell
    );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity,
        bool success
    );
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._isExcludedFromFees[account] != excluded);
        ds._isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds._isExcludedFromFees[accounts[i]] = excluded;

            emit ExcludeFromFees(accounts[i], excluded);
        }
    }
    function setTradingEnabled() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingIsPause = true;
    }
    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amount * (10 ** 18) >= totalSupply() / 1000,
            "SwapTokensAtAmount must be greater than or equal to 0.1% of total supply"
        );
        ds.swapTokensAtAmount = amount * (10 ** 18);
    }
    function setMaxTokenPerWallet(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amount * (10 ** 18) >= totalSupply() / 1000,
            "max token per wallet must be greater than or equal to 0.1% of total supply"
        );
        ds.maxTokenPerWallet = amount * (10 ** 18);
    }
    function setMaxTransactionAmount(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amount * (10 ** 18) >= totalSupply() / 1000,
            "max transaction amount must be greater than or equal to 0.1% of total supply"
        );
        ds.maxTransactionAmount = amount * (10 ** 18);
    }
    function updateLiquidityWallet(
        address newLiquidityWallet
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        excludeFromFees(newLiquidityWallet, true);
        emit LiquidityWalletUpdated(newLiquidityWallet, ds.liquidityWallet);
        ds.liquidityWallet = newLiquidityWallet;
    }
    function updateMarketingWallet(
        address newMarketingWallet
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        excludeFromFees(newMarketingWallet, true);
        emit MarketingWalletUpdated(newMarketingWallet, ds.marketingWallet);
        ds.marketingWallet = newMarketingWallet;
    }
    function updateBuyFees(
        uint256 newMarketingFee,
        uint256 newLiquidityFee,
        uint256 newBurnFee
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newMarketingFee.add(newLiquidityFee).add(newBurnFee) <= 40,
            "Max buy fees cannot be more than 40%"
        );

        ds.marketingBuyFees = newMarketingFee;
        ds.liquidityBuyFee = newLiquidityFee;
        ds.BurnBuyFee = newBurnFee;
        ds.totalBuyFees = ds.marketingBuyFees.add(ds.liquidityBuyFee).add(
            ds.BurnBuyFee
        );
        emit UpdateBuyFees(newMarketingFee, newLiquidityFee, newBurnFee);
    }
    function updateSellFees(
        uint256 newMarketingFee,
        uint256 newLiquidityFee,
        uint256 newBurnFee
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newMarketingFee.add(newLiquidityFee).add(newBurnFee) <= 40,
            "Max sell fees cannot be more than 40%"
        );

        ds.marketingSellFees = newMarketingFee;
        ds.liquiditySellFee = newLiquidityFee;
        ds.BurnSellFee = newBurnFee;
        ds.totalSellFees = ds.marketingSellFees.add(ds.liquiditySellFee).add(
            ds.BurnSellFee
        );
        emit UpdateSellFees(newMarketingFee, newLiquidityFee, newBurnFee);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(
            !ds.tradingIsPause ||
                (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]),
            "Trading is paused."
        );

        if (from != ds.uniswapV2Pair) {
            require(
                to != address(this),
                "You cannot send tokens to the contract address!"
            );
        }

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        } else if (
            !ds.swapping &&
            !ds._isExcludedFromFees[from] &&
            !ds._isExcludedFromFees[to]
        ) {
            bool isSelling = ds.automatedMarketMakerPairs[to];
            bool isBuying = ds.automatedMarketMakerPairs[from];

            if (
                isSelling && from != address(ds.uniswapV2Router) // sells only by detecting transfer to automated market maker pair //router -> pair is removing liquidity which shouldn't have max
            ) {
                require(
                    amount <= ds.maxTransactionAmount,
                    "maximum transaction amount exceed."
                );

                ds.marketingFeeActual = ds.marketingSellFees;
                ds.liquidityFeeActual = ds.liquiditySellFee;
                ds.BurnFeeActual = ds.BurnSellFee;
            } else if (isBuying && to != address(ds.uniswapV2Router)) {
                uint256 currentBalanceRecipient = balanceOf(to);
                require(
                    amount <= ds.maxTransactionAmount,
                    "maximum transaction amount exceed."
                );
                require(
                    currentBalanceRecipient + amount <= ds.maxTokenPerWallet,
                    "GUSTA: maximum token per wallet amount exceed"
                );

                ds.marketingFeeActual = ds.marketingBuyFees;
                ds.liquidityFeeActual = ds.liquidityBuyFee;
                ds.BurnFeeActual = ds.BurnBuyFee;
            } else {
                ds.marketingFeeActual = 0;
                ds.liquidityFeeActual = 0;
                ds.BurnFeeActual = 0;
            }

            uint256 contractTokenBalance = balanceOf(address(this));

            bool canSwap = contractTokenBalance >= ds.swapTokensAtAmount;

            if (canSwap && !ds.automatedMarketMakerPairs[from]) {
                ds.swapping = true;

                swapAndLiquify(ds.countLiquidityFees);

                letsBurn(ds.countBurnFee);

                swapAndSendMarketingETH();

                ds.swapping = false;
            }

            uint256 marketingFeeAmount = amount.mul(ds.marketingFeeActual).div(
                100
            );
            uint256 liquidityFeeAmount = amount.mul(ds.liquidityFeeActual).div(
                100
            );
            uint256 BurnFeeAmount = amount.mul(ds.BurnFeeActual).div(100);

            ds.countLiquidityFees += liquidityFeeAmount;
            ds.countBurnFee += BurnFeeAmount;

            uint256 fees = marketingFeeAmount +
                liquidityFeeAmount +
                BurnFeeAmount;
            amount = amount.sub(fees);
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }
    function swapAndLiquify(uint256 tokens) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (tokens <= 0) {
            return;
        }
        if (tokens > balanceOf(address(this))) {
            emit SwapAndLiquify(0, 0, 0, false);
            return;
        }

        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        if (half <= 0 || otherHalf <= 0) {
            return;
        }

        // capture the contract's current ETH balance.
        // this is so that we can capture exactly the amount of ETH that the
        // swap creates, and not make the liquidity event include any ETH that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForETH(half, payable(address(this)));

        ds.countLiquidityFees -= half;

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to rockswap
        addLiquidity(otherHalf, newBalance);

        ds.countLiquidityFees -= otherHalf;

        emit SwapAndLiquify(half, newBalance, otherHalf, true);
    }
    function swapTokensForETH(
        uint256 tokenAmount,
        address payable account
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (tokenAmount <= 0) {
            return;
        }
        if (balanceOf(address(this)) < tokenAmount) {
            tokenAmount = balanceOf(address(this));
        }

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
            account,
            block.timestamp
        );
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // add the liquidity
        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            ds.liquidityWallet,
            block.timestamp
        );
    }
    function letsBurn(uint256 tokens) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (tokens <= 0) {
            return;
        }
        if (tokens > balanceOf(address(this))) {
            return;
        }

        ds.countBurnFee -= tokens;
        _burn(address(this), tokens);
    }
    function swapAndSendMarketingETH() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 marketingTokens = balanceOf(address(this));

        //generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        _approve(address(this), address(ds.uniswapV2Router), marketingTokens);

        // make the swap
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            marketingTokens,
            0, // accept any amount of ETH
            path,
            ds.marketingWallet,
            block.timestamp
        );
    }
}
