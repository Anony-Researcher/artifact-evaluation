// https://sats.vision
// https://twitter.com/satslabs_
// https://t.me/satslabs

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity >=0.7.5;
import "./TestLib.sol";
contract removeLimitsFacet is Ownable {
    using SafeMath for uint256;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event marketingWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event treasuryWalletUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function removeLimits() external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        return true;
    }
    function updateMaxTxnAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 1) / 1000) / 1e9,
            "Cannot set ds.maxTransactionAmount lower than 0.1%"
        );
        ds.maxTransactionAmount = newNum * (10 ** 9);
    }
    function updateMaxWalletAmount(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNum >= ((totalSupply() * 5) / 1000) / 1e9,
            "Cannot set ds.maxWallet lower than 0.5%"
        );
        ds.maxWallet = newNum * (10 ** 9);
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedMaxTransactionAmount[updAds] = isEx;
    }
    function disableTransferDelay() external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferDelayEnabled = false;
        return true;
    }
    function enableSATS() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingActive = true;
        ds.swapEnabled = true;
        ds.enableBlock = block.number;
    }
    function pauseTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.limitsInEffect);
        ds.tradingActive = false;
    }
    function toggleLaunchMarketMaker(
        address _add,
        bool _isTrue
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.launchMarketMaker[_add] = _isTrue;
    }
    function resumeTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingActive = true;
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
    function updateSwapEnabled(bool enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnabled = enabled;
    }
    function updateBuyFees(
        uint256 _marketingFee,
        uint256 _liquidityFee,
        uint256 _burnFee,
        uint256 _treasuryFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyMarketingFee = _marketingFee;
        ds.buyLiquidityFee = _liquidityFee;
        ds.buyBurnFee = _burnFee;
        ds.buyTreasuryFee = _treasuryFee;
        ds.buyTotalFees =
            ds.buyMarketingFee +
            ds.buyLiquidityFee +
            ds.buyBurnFee +
            ds.buyTreasuryFee;
        require(ds.buyTotalFees <= 28, "Must keep fees at 28% or less");
    }
    function updateSellFees(
        uint256 _marketingFee,
        uint256 _liquidityFee,
        uint256 _burnFee,
        uint256 _treasuryFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellMarketingFee = _marketingFee;
        ds.sellLiquidityFee = _liquidityFee;
        ds.sellBurnFee = _burnFee;
        ds.sellTreasuryFee = _treasuryFee;
        ds.sellTotalFees =
            ds.sellMarketingFee +
            ds.sellLiquidityFee +
            ds.sellBurnFee +
            ds.sellTreasuryFee;
        require(ds.sellTotalFees <= 28, "Must keep fees at 28% or less");
    }
    function updateMarketingWallet(
        address newMarketingWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit marketingWalletUpdated(newMarketingWallet, ds.marketingWallet);
        ds.marketingWallet = newMarketingWallet;
    }
    function updatetreasuryWallet(
        address newtreasuryWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit treasuryWalletUpdated(newtreasuryWallet, ds.treasuryWallet);
        ds.treasuryWallet = newtreasuryWallet;
    }
    function withdrawEthPool() external onlyOwner {
        bool success;
        (success, ) = address(msg.sender).call{value: address(this).balance}(
            ""
        );
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
