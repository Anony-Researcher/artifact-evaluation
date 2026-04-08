// SPDX-License-Identifier: MIT

/* 
Generic taxable token with native currency and custom token recovery features.

Contract created by: Service Bridge https://serbridge.com/
SerBridge LinkTree with project updates https://linktr.ee/serbridge
*/

pragma solidity 0.8.17;
import "./TestLib.sol";
contract updateBuyFeesFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event ExcludeMultipleAccountsFromFees(address[] accounts, bool isExcluded);
    event marketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function updateBuyFees(uint256 _marketingFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingBuyFee = _marketingFee;
        ds.totalBuyFees = ds.marketingBuyFee;
        require(ds.totalBuyFees <= 350, "Must be equal or lower 35%");
    }
    function updateSellFees(uint256 _marketingFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingSellFee = _marketingFee;
        ds.totalSellFees = ds.marketingSellFee;
        require(ds.totalSellFees <= 350, "Must be equal or lower 35%");
    }
    function updateSwapTokensAtAmount(
        uint256 newAmount
    ) external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapTokensAtAmount = newAmount * (10 ** 18);
        return true;
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    function excludeMultipleAccountsFromFees(
        address[] calldata accounts,
        bool excluded
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < accounts.length; i++) {
            ds._isExcludedFromFees[accounts[i]] = excluded;
        }

        emit ExcludeMultipleAccountsFromFees(accounts, excluded);
    }
    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            pair != ds.uniswapV3Pair,
            "The UniSwap pair cannot be removed from AutomatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(pair, value);
    }
    function updateMarketingWallet(
        address newMarketingWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newMarketingWallet != address(0), "cannot set to 0 address");
        excludeFromFees(newMarketingWallet, true);
        emit marketingWalletUpdated(newMarketingWallet, ds.marketingWallet);
        ds.marketingWallet = newMarketingWallet;
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
            if (ds.automatedMarketMakerPairs[to] && ds.totalSellFees > 0) {
                fees = amount.mul(ds.totalSellFees).div(ds.feeDivisor);
                ds.tokensForMarketing +=
                    (fees * ds.marketingSellFee) /
                    ds.totalSellFees;
            } else if (
                ds.automatedMarketMakerPairs[from] && ds.totalBuyFees > 0
            ) {
                fees = amount.mul(ds.totalBuyFees).div(ds.feeDivisor);
                ds.tokensForMarketing +=
                    (fees * ds.marketingBuyFee) /
                    ds.totalBuyFees;
            }

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }
    function recoverStuckETH() external onlyOwner {
        (bool success, ) = address(msg.sender).call{
            value: address(this).balance
        }("Stuck ETH balance from contract address recovered");
        require(
            success,
            "Failed. Either caller is not the owner or address is not the contract address"
        );
    }
    function recoverStuckTokens(
        address tokenAddress,
        uint256 tokens
    ) external onlyOwner returns (bool success) {
        return ERC20(tokenAddress).transfer(msg.sender, tokens);
    }
    function changeBuyBackSettings(
        bool _buyBackEnabled,
        uint256 _percentForMarketing
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_percentForMarketing <= 100, "Must be set below 100%");
        ds.percentForMarketing = _percentForMarketing;
        ds.buyBackEnabled = _buyBackEnabled;
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = ds.tokensForMarketing;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }

        bool success;

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(contractBalance);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForMarketing = ethBalance.mul(ds.tokensForMarketing).div(
            totalTokensToSwap
        );

        if (ds.buyBackEnabled) {
            (success, ) = address(ds.marketingWallet).call{
                value: (ethForMarketing * ds.percentForMarketing) / 100
            }("Automated BuyBack completed");
            swapEthForNativeToken(address(this).balance);
        } else {
            (success, ) = address(ds.marketingWallet).call{
                value: address(this).balance
            }("Success");
        }
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV3Router.WETH();

        _approve(address(this), address(ds.uniswapV3Router), tokenAmount);

        ds.uniswapV3Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function swapEthForNativeToken(uint256 ethAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ethAmount > 0) {
            address[] memory path = new address[](2);
            path[0] = ds.uniswapV3Router.WETH();
            path[1] = address(this);

            ds
                .uniswapV3Router
                .swapExactETHForTokensSupportingFeeOnTransferTokens{
                value: ethAmount
            }(0, path, address(ds.marketingWallet), block.timestamp);
        }
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
