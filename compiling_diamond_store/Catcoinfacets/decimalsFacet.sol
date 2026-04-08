// SPDX-License-Identifier: MIT
/**
 * https://CatcoinEth.VIP
 * https://twitter.com/CatCoin_On_Eth
 * https://t.me/CatCoinOnEth
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is ERC20, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event TradingOpened();
    event FeeReceiverUpdated(address _taxWallet);
    event MaxTxAmountUpdated(uint _txAmountLimit);
    event MaxWalletAmountUpdated(uint _walletAmountLimit);
    event SwapbackUpdated(uint _swapbackMin, uint _swapbackMax);
    event MaxTxAmountUpdated(uint _txAmountLimit);
    event MaxWalletAmountUpdated(uint _walletAmountLimit);
    event FeesUpdated(uint _taxOnBuys, uint _taxOnSells);
    event ExcludedFromFee(address account, bool status);
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading is already open");
        ds.uniswapV2Router = IDexRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), totalSupply());
        ds.uniswapV2Pair = IDexFactory(ds.uniswapV2Router.factory()).createPair(
            address(this),
            ds.uniswapV2Router.WETH()
        );
        ds.uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(ds.uniswapV2Pair).approve(
            address(ds.uniswapV2Router),
            type(uint).max
        );
        ds.swapEnabled = true;
        ds.tradingOpen = true;
        ds.liveBlock = block.number;
        ds.lastLiquifyTime = uint64(block.number);
        ds._isExcludedFromFee[address(this)] = true;

        emit TradingOpened();
    }
    function setReceiverAddress(address payable taxWallet1) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._taxWallet = taxWallet1;

        emit FeeReceiverUpdated(taxWallet1);
    }
    function setMaxTxAmount(uint256 newValue) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newValue >= 1, "Max tx cant be lower than 0.1%");
        ds._txAmountLimit = (totalSupply() * newValue) / 1000;
        emit MaxTxAmountUpdated(ds._txAmountLimit);
    }
    function setMaxWalletAmount(uint256 newValue) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newValue >= 1, "Max wallet cant be lower than 0.1%");
        ds._walletAmountLimit = (totalSupply() * newValue) / 1000;
        emit MaxWalletAmountUpdated(ds._walletAmountLimit);
    }
    function setTaxSwapValue(
        uint256 taxSwapThreshold,
        uint256 maxTaxSwap
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._swapbackMin = (totalSupply() * taxSwapThreshold) / 10000;
        ds._swapbackMax = (totalSupply() * maxTaxSwap) / 10000;
        emit SwapbackUpdated(taxSwapThreshold, maxTaxSwap);
    }
    function removeLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._txAmountLimit = totalSupply();
        ds._walletAmountLimit = totalSupply();
        emit MaxTxAmountUpdated(totalSupply());
        emit MaxWalletAmountUpdated(totalSupply());
    }
    function setTradingFee(uint256 buyTax, uint256 sellTax) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(buyTax <= 99, "Invalid buy tax value");
        require(sellTax <= 99, "Invalid sell tax value");
        ds._taxOnBuys = buyTax;
        ds._taxOnSells = sellTax;
        emit FeesUpdated(buyTax, sellTax);
    }
    function excludeFromFee(address account, bool status) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = status;
        emit ExcludedFromFee(account, status);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != owner() && to != owner() && !ds.inSwap) {
            taxAmount = amount.mul(ds._taxOnBuys).div(100);

            if (
                from == ds.uniswapV2Pair &&
                to != address(ds.uniswapV2Router) &&
                !ds._isExcludedFromFee[to]
            ) {
                require(
                    amount <= ds._txAmountLimit,
                    "Exceeds the ds._txAmountLimit."
                );
                require(
                    balanceOf(to) + amount <= ds._walletAmountLimit,
                    "Exceeds the maxWalletSize."
                );

                if (ds.liveBlock + 3 > block.number) {
                    require(!isContract(to));
                }
                ds._buyCount++;
            }

            if (to != ds.uniswapV2Pair && !ds._isExcludedFromFee[to]) {
                require(
                    balanceOf(to) + amount <= ds._walletAmountLimit,
                    "Exceeds the maxWalletSize."
                );
            }

            if (to == ds.uniswapV2Pair && from != address(this)) {
                taxAmount = amount.mul(ds._taxOnSells).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !ds.inSwap &&
                to == ds.uniswapV2Pair &&
                ds.swapEnabled &&
                contractTokenBalance > ds._swapbackMin &&
                ds._buyCount > ds._preventSwapBefore &&
                ds.lastLiquifyTime != uint64(block.number)
            ) {
                swapTokensForEth(min(contractTokenBalance, ds._swapbackMax));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee();
                }
            }
        }

        if (taxAmount > 0) {
            super._transfer(from, address(this), taxAmount);
        }
        super._transfer(from, to, amount.sub(taxAmount));
    }
    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.lastLiquifyTime = uint64(block.number);
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
    function triggerSwap() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds._taxWallet || msg.sender == owner(),
            "Only fee receiver can trigger"
        );
        uint256 contractTokenBalance = balanceOf(address(this));

        swapTokensForEth(contractTokenBalance);
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            sendETHToFee();
        }
    }
    function sendETHToFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool success;
        (success, ) = address(ds._taxWallet).call{value: address(this).balance}(
            ""
        );
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
}
