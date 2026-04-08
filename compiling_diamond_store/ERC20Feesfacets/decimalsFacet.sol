/*
 * SPDX-License-Identifier: MIT
 * https://x.com/beeple/status/1765603381073052159?s=20
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event TradingEnabled(uint256 indexed timestamp);
    event LimitsRemoved(uint256 indexed timestamp);
    event DisabledTransferDelay(uint256 indexed timestamp);
    event SwapbackSettingsUpdated(
        bool enabled,
        uint256 swapBackValueMin,
        uint256 swapBackValueMax
    );
    event MaxTxUpdated(uint256 maxTx);
    event MaxWalletUpdated(uint256 maxWallet);
    event ExcludeFromLimits(address indexed account, bool isExcluded);
    event BuyFeeUpdated(uint256 totalbuy, uint256 mktbuy, uint256 devbuy);
    event SellFeeUpdated(uint256 totalsell, uint256 mktsell, uint256 devsell);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event mktfeereceiverUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event devfeereceiverUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }
    function enableLaunch() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.trading_enabled = true;
        ds.swapbackEnabled = true;
        emit TradingEnabled(block.timestamp);
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        emit LimitsRemoved(block.timestamp);
    }
    function dtransferdelay() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferDelayEnabled = false;
        emit DisabledTransferDelay(block.timestamp);
    }
    function setSwapBackSettings(
        bool _enabled,
        uint256 _min,
        uint256 _max
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _min >= 1,
            "Swap amount cannot be lower than 0.01% total supply."
        );
        require(_max >= _min, "maximum amount cant be higher than minimum");

        ds.swapbackEnabled = _enabled;
        ds.swapBackValueMin = (totalSupply() * _min) / 10000;
        ds.swapBackValueMax = (totalSupply() * _max) / 10000;
        emit SwapbackSettingsUpdated(_enabled, _min, _max);
    }
    function setTxLimit(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newNum >= 2, "Cannot set ds.maxTx lower than 0.2%");
        ds.maxTx = (newNum * totalSupply()) / 1000;
        emit MaxTxUpdated(ds.maxTx);
    }
    function setWalletlmt(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newNum >= 5, "Cannot set ds.maxWallet lower than 0.5%");
        ds.maxWallet = (newNum * totalSupply()) / 1000;
        emit MaxWalletUpdated(ds.maxWallet);
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isTxLimitExempt[updAds] = isEx;
        emit ExcludeFromLimits(updAds, isEx);
    }
    function setBuyFees(
        uint256 _marketingFee,
        uint256 _devFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.mktbuy = _marketingFee;
        ds.devbuy = _devFee;
        ds.totalbuy = ds.mktbuy + ds.devbuy;
        require(ds.totalbuy <= 100, "Total buy fee cannot be higher than 100%");
        emit BuyFeeUpdated(ds.totalbuy, ds.mktbuy, ds.devbuy);
    }
    function setSellFees(
        uint256 _marketingFee,
        uint256 _devFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.mktsell = _marketingFee;
        ds.devsell = _devFee;
        ds.totalsell = ds.mktsell + ds.devsell;
        require(
            ds.totalsell <= 100,
            "Total sell fee cannot be higher than 100%"
        );
        emit SellFeeUpdated(ds.totalsell, ds.mktsell, ds.devsell);
    }
    function excludeFromTaxes(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isFeeExempt[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            pair != ds.dexPair,
            "The pair cannot be removed from ds.automatedMarketMakerPairs"
        );

        _setAutomatedMarketMakerPair(pair, value);
    }
    function setMarketingWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit mktfeereceiverUpdated(newWallet, ds.mktfeereceiver);
        ds.mktfeereceiver = newWallet;
    }
    function setDevWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit devfeereceiverUpdated(newWallet, ds.devfeereceiver);
        ds.devfeereceiver = newWallet;
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
                if (!ds.trading_enabled) {
                    require(
                        ds.isFeeExempt[from] || ds.isFeeExempt[to],
                        "_transfer:: Trading is not active."
                    );
                }

                // at launch if the transfer delay is enabled, ensure the block timestamps for purchasers is set -- during launch.
                if (ds.transferDelayEnabled) {
                    if (
                        to != owner() &&
                        to != address(ds.dexRouter) &&
                        to != address(ds.dexPair)
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
                    !ds.isTxLimitExempt[to]
                ) {
                    require(
                        amount <= ds.maxTx,
                        "Buy transfer amount exceeds the ds.maxTx."
                    );
                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
                        "Max wallet exceeded"
                    );
                }
                //when sell
                else if (
                    ds.automatedMarketMakerPairs[to] &&
                    !ds.isTxLimitExempt[from]
                ) {
                    require(
                        amount <= ds.maxTx,
                        "Sell transfer amount exceeds the ds.maxTx."
                    );
                } else if (!ds.isTxLimitExempt[to]) {
                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= ds.swapBackValueMin;

        if (
            canSwap &&
            ds.swapbackEnabled &&
            !ds.swapping &&
            !ds.automatedMarketMakerPairs[from] &&
            !ds.isFeeExempt[from] &&
            !ds.isFeeExempt[to]
        ) {
            ds.swapping = true;

            swapBack();

            ds.swapping = false;
        }

        bool takeFee = !ds.swapping;

        // if any account belongs to _isExcludedFromFee account then remove the fee
        if (ds.isFeeExempt[from] || ds.isFeeExempt[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        // only take fees on buys/sells, do not take on wallet transfers
        if (takeFee) {
            // on sell
            if (ds.automatedMarketMakerPairs[to] && ds.totalsell > 0) {
                fees = amount.mul(ds.totalsell).div(100);
                ds.tokensForDev += (fees * ds.devsell) / ds.totalsell;
                ds.tokensForMarketing += (fees * ds.mktsell) / ds.totalsell;
            }
            // on buy
            else if (ds.automatedMarketMakerPairs[from] && ds.totalbuy > 0) {
                fees = amount.mul(ds.totalbuy).div(100);
                ds.tokensForDev += (fees * ds.devbuy) / ds.totalbuy;
                ds.tokensForMarketing += (fees * ds.mktbuy) / ds.totalbuy;
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
        uint256 totalTokensToSwap = contractBalance;
        bool success;

        if (contractBalance == 0) {
            return;
        }

        if (contractBalance > ds.swapBackValueMax) {
            contractBalance = ds.swapBackValueMax;
        }

        uint256 amountToSwapForETH = contractBalance;

        uint256 initialETHBalance = address(this).balance;

        swapTokensForEth(amountToSwapForETH);

        uint256 ethBalance = address(this).balance.sub(initialETHBalance);

        uint256 ethForDev = ethBalance.mul(ds.tokensForDev).div(
            totalTokensToSwap
        );

        ds.tokensForMarketing = 0;
        ds.tokensForDev = 0;

        (success, ) = address(ds.devfeereceiver).call{value: ethForDev}("");

        (success, ) = address(ds.mktfeereceiver).call{
            value: address(this).balance
        }("");
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.dexRouter.WETH();

        _approve(address(this), address(ds.dexRouter), tokenAmount);

        // make the swap
        ds.dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
