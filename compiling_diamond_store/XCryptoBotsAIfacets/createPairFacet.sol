/*
 _ (_)(_)(_) _                                                 (_)                               (_)(_)(_)(_) _                  (_)                                   _(_)_     (_)(_)(_)      
   (_)         (_)_       _  _  _               _  _  _  _  _   _ (_) _  _      _  _  _              (_)        (_)    _  _  _    _ (_) _  _   _  _  _  _               _(_) (_)_      (_)         
   (_)           (_)_  _ (_)(_)(_)_           _(_)(_)(_)(_)(_)_(_)(_)(_)(_)  _ (_)(_)(_) _           (_) _  _  _(_) _ (_)(_)(_) _(_)(_)(_)(_)_(_)(_)(_)(_)            _(_)     (_)_    (_)         
   (_)             (_)(_)        (_)_       _(_)  (_)        (_)  (_)       (_)         (_)          (_)(_)(_)(_)_ (_)         (_)  (_)     (_)_  _  _  _            (_) _  _  _ (_)   (_)         
   (_)          _  (_)             (_)_   _(_)    (_)        (_)  (_)     _ (_)         (_)          (_)        (_)(_)         (_)  (_)     _ (_)(_)(_)(_)_          (_)(_)(_)(_)(_)   (_)         
   (_) _  _  _ (_) (_)               (_)_(_)      (_) _  _  _(_)  (_)_  _(_)(_) _  _  _ (_)          (_)_  _  _ (_)(_) _  _  _ (_)  (_)_  _(_) _  _  _  _(_)         (_)         (_) _ (_) _       
      (_)(_)(_)    (_)                _(_)        (_)(_)(_)(_)      (_)(_)     (_)(_)(_)            (_)(_)(_)(_)      (_)(_)(_)       (_)(_)  (_)(_)(_)(_)           (_)         (_)(_)(_)(_)      
                                 _  _(_)          (_)                                                                                                                                          

Revolutionizing the way crypto trading supported by AI

Twitter: https://twitter.com/CryptoBotAITech
Telegram: 
	Official: https://t.me/CryptoBotAIOfficial
    Alerts Bot: https://t.me/CryptoBotsAIAlerts
	Snipe & Shill & Referal Bots: https://t.me/CryptoBotsAIBot
Website: https://x-cryptobots.com
WhitePaper: https://cryptobotsai.gitbook.io/whitepaper/
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10 >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract createPairFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event marketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event developmentWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function createPair() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        ds.uniswapV2Router = _uniswapV2Router;
        ds.uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());
        excludeFromMaxTransaction(address(ds.uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(ds.uniswapV2Pair), true);
    }
    function enableTrade() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingActive = true;
        ds.swapEnabled = true;
    }
    function removeLimits() external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        return true;
    }
    function disableTransferDelay() external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferDelayEnabled = false;
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
    function updateBuyFees(
        uint256 _marketingFee,
        uint256 _revShareFee,
        uint256 _developmentFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyMarketingFee = _marketingFee;
        ds.buyRevShareFee = _revShareFee;
        ds.buyDevelopmentFee = _developmentFee;
        ds.buyTotalFees =
            ds.buyMarketingFee +
            ds.buyRevShareFee +
            ds.buyDevelopmentFee;
    }
    function updateSellFees(
        uint256 _marketingFee,
        uint256 _revShareFee,
        uint256 _developmentFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMarketingFee = _marketingFee;
        ds.sellRevShareFee = _revShareFee;
        ds.sellDevelopmentFee = _developmentFee;
        ds.sellTotalFees =
            ds.sellMarketingFee +
            ds.sellRevShareFee +
            ds.sellDevelopmentFee;
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
    function updateMarketingWalletInfo(
        address newMarketingWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit marketingWalletUpdated(newMarketingWallet, ds.marketingWallet);
        ds.marketingWallet = newMarketingWallet;
    }
    function updateDevelopmentWalletInfo(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit developmentWalletUpdated(newWallet, ds.developmentWallet);
        ds.developmentWallet = newWallet;
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

                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
                if (ds.transferDelayEnabled) {
                    if (
                        to != owner() &&
                        to != address(ds.uniswapV2Router) &&
                        to != address(ds.uniswapV2Pair)
                    ) {
                        require(
                            ds._holderLastTransferTimestamp[tx.origin] <
                                block.number,
                            "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                        );
                        ds._holderLastTransferTimestamp[tx.origin] = block
                            .number;
                    }
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
            swapBack(amount);
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
                ds.tokensForRevShare +=
                    (fees * ds.sellRevShareFee) /
                    ds.sellTotalFees;
                ds.tokensForDev +=
                    (fees * ds.sellDevelopmentFee) /
                    ds.sellTotalFees;
                ds.tokensForMarketing +=
                    (fees * ds.sellMarketingFee) /
                    ds.sellTotalFees;
            }
            // on buy
            else if (
                ds.automatedMarketMakerPairs[from] && ds.buyTotalFees > 0
            ) {
                fees = amount.mul(ds.buyTotalFees).div(100);
                ds.tokensForRevShare +=
                    (fees * ds.buyRevShareFee) /
                    ds.buyTotalFees;
                ds.tokensForDev +=
                    (fees * ds.buyDevelopmentFee) /
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

        super._transfer(from, to, amount);
    }
    function swapBack(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = ds.tokensForRevShare +
            ds.tokensForMarketing +
            ds.tokensForDev;
        bool success;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount * 20) {
            if (amount > ds.swapTokensAtAmount * 20) {
                contractBalance = ds.swapTokensAtAmount * 20;
            } else {
                contractBalance = amount;
            }
        }

        uint256 initialETHBalance = address(this).balance;
        swapTokensForEth(contractBalance);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        uint256 ethForMarketing = ethBalance.mul(ds.tokensForMarketing).div(
            totalTokensToSwap
        );
        uint256 ethForDev = ethBalance.mul(ds.tokensForDev).div(
            totalTokensToSwap
        );
        uint256 ethForRevShare = ethBalance - ethForMarketing - ethForDev;

        ds.tokensForRevShare = 0;
        ds.tokensForMarketing = 0;
        ds.tokensForDev = 0;

        (success, ) = address(ds.marketingWallet).call{value: ethForMarketing}(
            ""
        );
        (success, ) = address(ds.developmentWallet).call{value: ethForDev}("");
        (success, ) = address(ds.revShareWallet).call{value: ethForRevShare}(
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
    function manualswap() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _msgSender() == ds.developmentWallet ||
                _msgSender() == ds.marketingWallet
        );
        uint256 contractBalance = balanceOf(address(this));
        swapTokensForEth(contractBalance);
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
