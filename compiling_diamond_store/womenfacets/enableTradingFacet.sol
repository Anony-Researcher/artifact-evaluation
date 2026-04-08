/**
 *Submitted for verification at EtherScan.com on 2021-06-20
 */

/**
 *
 *
   https://WomensRights.xyz
   https://x.com/womensrightseth
   https://t.me/WomensRightsDAO
   

   Contract features:
   69,000,420 tokens
   3% buy tax in ETH sent to marketing, community & dev
   16% sell tax in ETH sent to marketing, community & dev
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "./TestLib.sol";
contract enableTradingFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event marketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event developmentWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event communityFundWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingActive, "Trading already active.");

        ds.uniswapV2Pair = IUniswapV2Factory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());
        _approve(address(this), address(ds.uniswapV2Pair), type(uint256).max);
        IERC20(ds.uniswapV2Pair).approve(
            address(ds.uniswapV2Router),
            type(uint256).max
        );

        _setAutomatedMarketMakerPair(address(ds.uniswapV2Pair), true);
        excludeFromMaxTransaction(address(ds.uniswapV2Pair), true);

        uint256 tokensInWallet = balanceOf(address(this));
        uint256 tokensToAdd = (tokensInWallet * 100) / 100; // 100% of tokens in wallet go to LP

        ds.uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            tokensToAdd,
            0,
            0,
            owner(),
            block.timestamp
        );

        ds.tradingActive = true;
        ds.swapEnabled = true;
    }
    function updateSwapTokensAtAmount(
        uint256 newAmount
    ) external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newAmount >= (totalSupply() * 1) / 100000,
            "ERC20: Swap amount cannot be lower than 0.001% total supply."
        );
        require(
            newAmount <= (totalSupply() * 5) / 1000,
            "ERC20: Swap amount cannot be higher than 0.5% total supply."
        );
        ds.swapTokensAtAmount = newAmount;
        return true;
    }
    function updateMaxWalletAndTxnAmount(
        uint256 newTxnNum,
        uint256 newMaxWalletNum
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newTxnNum >= ((totalSupply() * 5) / 1000),
            "ERC20: Cannot set maxTxn lower than 0.5%"
        );
        require(
            newMaxWalletNum >= ((totalSupply() * 5) / 1000),
            "ERC20: Cannot set ds.maxWallet lower than 0.5%"
        );
        ds.maxWallet = newMaxWalletNum;
        ds.maxTransactionAmount = newTxnNum;
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedMaxTransactionAmount[updAds] = isEx;
    }
    function updateBuyFees(
        uint256 _marketingFee,
        uint256 _developmentFee,
        uint256 _communityFundFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyMarketingFee = _marketingFee;
        ds.buyDevelopmentFee = _developmentFee;
        ds.buyCommunityFundFee = _communityFundFee;
        ds.buyTotalFees =
            ds.buyMarketingFee +
            ds.buyDevelopmentFee +
            ds.buyCommunityFundFee;
        require(ds.buyTotalFees <= 10, "ERC20: Must keep fees at 10% or less");
    }
    function updateSellFees(
        uint256 _marketingFee,
        uint256 _developmentFee,
        uint256 _communityFundFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMarketingFee = _marketingFee;
        ds.sellDevelopmentFee = _developmentFee;
        ds.sellCommunityFundFee = _communityFundFee;
        ds.sellTotalFees =
            ds.sellMarketingFee +
            ds.sellDevelopmentFee +
            ds.sellCommunityFundFee;
        ds.previousFee = ds.sellTotalFees;
        require(ds.sellTotalFees <= 10, "ERC20: Must keep fees at 10% or less");
    }
    function updateMarketingWallet(
        address _marketingWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_marketingWallet != address(0), "ERC20: Address 0");
        address oldWallet = ds.marketingWallet;
        ds.marketingWallet = _marketingWallet;
        emit marketingWalletUpdated(ds.marketingWallet, oldWallet);
    }
    function updateDevelopmentWallet(
        address _developmentWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_developmentWallet != address(0), "ERC20: Address 0");
        address oldWallet = ds.developmentWallet;
        ds.developmentWallet = _developmentWallet;
        emit developmentWalletUpdated(ds.developmentWallet, oldWallet);
    }
    function updateCommunityFundWallet(
        address _communityFundWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_communityFundWallet != address(0), "ERC20: Address 0");
        address oldWallet = ds.communityFundWallet;
        ds.communityFundWallet = _communityFundWallet;
        emit communityFundWalletUpdated(ds.communityFundWallet, oldWallet);
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    function withdrawStuckETH() public onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}(
            ""
        );
    }
    function withdrawStuckTokens(address tkn) public onlyOwner {
        require(IERC20(tkn).balanceOf(address(this)) > 0, "No tokens");
        uint256 amount = IERC20(tkn).balanceOf(address(this));
        IERC20(tkn).transfer(msg.sender, amount);
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

        if (
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != deadAddress &&
            !ds.swapping
        ) {
            if (!ds.tradingActive) {
                require(
                    ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to],
                    "ERC20: Trading is not active."
                );
            }

            //when buy
            if (
                ds.automatedMarketMakerPairs[from] &&
                !ds._isExcludedMaxTransactionAmount[to]
            ) {
                require(
                    amount <= ds.maxTransactionAmount,
                    "ERC20: Buy transfer amount exceeds the ds.maxTransactionAmount."
                );
                require(
                    amount + balanceOf(to) <= ds.maxWallet,
                    "ERC20: Max wallet exceeded"
                );
            }
            //when sell
            else if (
                ds.automatedMarketMakerPairs[to] &&
                !ds._isExcludedMaxTransactionAmount[from]
            ) {
                require(
                    amount <= ds.maxTransactionAmount,
                    "ERC20: Sell transfer amount exceeds the ds.maxTransactionAmount."
                );
            } else if (!ds._isExcludedMaxTransactionAmount[to]) {
                require(
                    amount + balanceOf(to) <= ds.maxWallet,
                    "ERC20: Max wallet exceeded"
                );
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

        if (ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        if (takeFee) {
            // on sell
            if (ds.automatedMarketMakerPairs[to] && ds.sellTotalFees > 0) {
                fees = amount.mul(ds.sellTotalFees).div(100);
                ds.tokensForCommunityFund +=
                    (fees * ds.sellCommunityFundFee) /
                    ds.sellTotalFees;
                ds.tokensForMarketing +=
                    (fees * ds.sellMarketingFee) /
                    ds.sellTotalFees;
                ds.tokensForDevelopment +=
                    (fees * ds.sellDevelopmentFee) /
                    ds.sellTotalFees;
            }
            // on buy
            else if (
                ds.automatedMarketMakerPairs[from] && ds.buyTotalFees > 0
            ) {
                fees = amount.mul(ds.buyTotalFees).div(100);
                ds.tokensForCommunityFund +=
                    (fees * ds.buyCommunityFundFee) /
                    ds.buyTotalFees;
                ds.tokensForMarketing +=
                    (fees * ds.buyMarketingFee) /
                    ds.buyTotalFees;
                ds.tokensForDevelopment +=
                    (fees * ds.buyDevelopmentFee) /
                    ds.buyTotalFees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
        ds.sellTotalFees = ds.previousFee;
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = ds.tokensForCommunityFund +
            ds.tokensForMarketing +
            ds.tokensForDevelopment;
        bool success;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmount * 20) {
            contractBalance = ds.swapTokensAtAmount * 20;
        }

        swapTokensForEth(contractBalance);

        uint256 ethBalance = address(this).balance;

        uint256 ethForDevelopment = ethBalance.mul(ds.tokensForDevelopment).div(
            totalTokensToSwap
        );

        uint256 ethForCommunityFund = ethBalance
            .mul(ds.tokensForCommunityFund)
            .div(totalTokensToSwap);

        ds.tokensForMarketing = 0;
        ds.tokensForDevelopment = 0;
        ds.tokensForCommunityFund = 0;

        (success, ) = address(ds.communityFundWallet).call{
            value: ethForCommunityFund
        }("");

        (success, ) = address(ds.developmentWallet).call{
            value: ethForDevelopment
        }("");

        (success, ) = address(ds.marketingWallet).call{
            value: address(this).balance
        }("");
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // make the swap
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
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
