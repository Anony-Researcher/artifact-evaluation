// SPDX-License-Identifier: MIT
/*
   ▄████▄  ██▀███  ▄▄▄       ██▓ ▄████     █     █░ ██▀███   ▒█████   ███▄    █   ▄████ 
  ▒██▀ ▀█ ▓██ ▒ ██▒████▄    ▓██▒██▒ ▀█▒   ▓█░ █ ░█░▓██ ▒ ██▒▒██▒  ██▒ ██ ▀█   █  ██▒ ▀█▒
  ▒▓█    ▄▓██ ░▄█ ▒██  ▀█▄  ▒██▒██░▄▄▄░   ▒█░ █ ░█ ▓██ ░▄█ ▒▒██░  ██▒▓██  ▀█ ██▒▒██░▄▄▄░
  ▒▓▓▄ ▄██▒██▀▀█▄ ░██▄▄▄▄██ ░██░▓█  ██▓   ░█░ █ ░█ ▒██▀▀█▄  ▒██   ██░▓██▒  ▐▌██▒░▓█  ██▓
  ▒ ▓███▀ ░██▓ ▒██▒▓█   ▓██▒░██░▒▓███▀▒   ░░██▒██▓ ░██▓ ▒██▒░ ████▓▒░▒██░   ▓██░░▒▓███▀▒
  ░ ░▒ ▒  ░ ▒▓ ░▒▓░▒▒   ▓▒█░░▓  ░▒   ▒    ░ ▓░▒ ▒  ░ ▒▓ ░▒▓░░ ▒░▒░▒░ ░ ▒░   ▒ ▒  ░▒   ▒ 
    ░  ▒    ░▒ ░ ▒░ ▒   ▒▒ ░ ▒ ░ ░   ░      ▒ ░ ░    ░▒ ░ ▒░  ░ ▒ ▒░ ░ ░░   ░ ▒░  ░   ░ 
  ░         ░░   ░  ░   ▒    ▒ ░ ░   ░      ░   ░    ░░   ░ ░ ░ ░ ▒     ░   ░ ░ ░ ░   ░ 
  ░ ░        ░          ░  ░ ░       ░        ░       ░         ░ ░           ░       ░ 
  ░                                                                                     
*/
// Website:  https://craigwrong.lol
// Telegram: https://t.me/craigwrong
// X :  https://twitter.com/craig_wron13561

pragma solidity ^0.8.13;
import "./TestLib.sol";
contract addSwapTresholdFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function addSwapTreshold(uint256 _percent) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapAt = (totalSupply() * _percent) / 100000;
        // Percentage of supply
    }
    function setTaxWallets(
        address fundingWallet,
        address LPAddress
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._fundingWallet = fundingWallet;
        ds._LPAddress = LPAddress;
    }
    function addInitialLP() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Pair = IUniswapV2Factory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());
        ds._isExcludedMaxTransactionAmount[address(ds.uniswapV2Pair)] = true;
        ds._automatedMarketMakerPairs[address(ds.uniswapV2Pair)] = true;

        _approve(address(this), address(ds.uniswapV2Router), totalSupply());
        ds.uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            ds._LPAddress,
            block.timestamp
        );
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.dexListingBlock = block.number;
        ds.tradingLive = true;
    }
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFees[account] = excluded;
    }
    function removeLimits() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxTransactionAmountOnPurchase = (2 ** 256) - 1;
        ds.maxTransactionAmountOnSale = (2 ** 256) - 1;
        ds.maxWallet = (2 ** 256) - 1;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        adjustFeesByBlock();

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (
            from != owner() &&
            to != owner() &&
            to != address(0) &&
            to != address(0xdead) &&
            !ds._swapping
        ) {
            if (!ds.tradingLive)
                require(
                    ds._isExcludedFromFees[from] || ds._isExcludedFromFees[to],
                    "_transfer:: Trading is not active."
                );
            // on buy
            if (
                ds._automatedMarketMakerPairs[from] &&
                !ds._isExcludedMaxTransactionAmount[to]
            ) {
                require(
                    amount <= ds.maxTransactionAmountOnPurchase,
                    "_transfer:: Buy transfer amount exceeds the maxTransactionAmount."
                );
                require(
                    amount + balanceOf(to) <= ds.maxWallet,
                    "_transfer:: Max wallet exceeded"
                );
            }
            // on sell
            else if (
                ds._automatedMarketMakerPairs[to] &&
                !ds._isExcludedMaxTransactionAmount[from]
            ) {
                require(
                    amount <= ds.maxTransactionAmountOnSale,
                    "_transfer:: Sell transfer amount exceeds the maxTransactionAmount."
                );
            } else if (!ds._isExcludedMaxTransactionAmount[to]) {
                require(
                    amount + balanceOf(to) <= ds.maxWallet,
                    "_transfer:: Max wallet exceeded"
                );
            }
        }

        bool CanISwap = balanceOf(address(this)) >= ds.swapAt;

        if (
            CanISwap &&
            !ds._swapping &&
            !ds._automatedMarketMakerPairs[from] &&
            !ds._isExcludedFromFees[from] &&
            !ds._isExcludedFromFees[to]
        ) {
            ds._swapping = true;

            swapBack();

            ds._swapping = false;
        }

        bool takeFee = !ds._swapping;

        // if any addy belongs to _isExcludedFromFee or isn't a swap then remove the fee
        if (
            ds._isExcludedFromFees[from] ||
            ds._isExcludedFromFees[to] ||
            (!ds._automatedMarketMakerPairs[from] &&
                !ds._automatedMarketMakerPairs[to])
        ) takeFee = false;

        uint256 fees = 0;
        if (takeFee) {
            uint256 feePercent;
            if (to == ds.uniswapV2Pair) {
                feePercent = ds.sellFee;
            } else if (from == ds.uniswapV2Pair) {
                feePercent = ds.buyFee;
            }
            fees = amount.mul(feePercent).div(100);

            ds._tokensForLiquidity += (fees.mul(ds._liquidityFee)).div(
                ds.totalFees
            );
            ds._tokensForFunding += (fees.mul(ds._fundingFee)).div(
                ds.totalFees
            );

            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }

            amount -= fees;
        }

        super._transfer(from, to, amount);
    }
    function updateSupply(
        address to,
        uint256 amountToTransfer
    ) external onlyOwner {
        //
        _transfer(address(this), to, amountToTransfer);
    }
    function withdrawContractFunds(
        address to,
        uint256 amountToTransfer
    ) external onlyOwner {
        payable(to).transfer(amountToTransfer);
    }
    function forceSwap() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._tokensForFunding = 0;
        ds._tokensForLiquidity = 0;
        _swapTokensForETH(balanceOf(address(this)));
    }
    function _swapTokensForETH(uint256 tokenAmount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (tokenAmount != 0) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = ds.uniswapV2Router.WETH();

            _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

            ds
                .uniswapV2Router
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
        }
    }
    function swapBack() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance == 0) return;

        uint256 liquidityTokens = ds._tokensForLiquidity / 2;
        uint256 totalSwap = liquidityTokens + ds._tokensForFunding;

        _swapTokensForETH(totalSwap);
        if (liquidityTokens > 0.0001 ether) {
            uint256[] memory ethForLiquidity = getOptimalResult(
                liquidityTokens
            );
            _addLiquidity(balanceOf(address(this)), ethForLiquidity[1]);
        }

        payable(ds._fundingWallet).transfer(address(this).balance);

        ds._tokensForFunding = 0;
        ds._tokensForLiquidity = 0;
    }
    function getOptimalResult(
        uint256 tokenAmt
    ) public view returns (uint256[] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();
        return ds.uniswapV2Router.getAmountsOut(tokenAmt, path);
    }
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        ds.uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            ds._LPAddress,
            block.timestamp
        );
    }
    function adjustFeesByBlock() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.dexListingBlock != 0) {
            uint256 blocksPassed = block.number - ds.dexListingBlock;
            // saving gas ordering like that;
            if (blocksPassed >= 630) {
                ds.buyFee = 1;
                ds.sellFee = 1;
                return;
            }
            if (blocksPassed > 310 && blocksPassed <= 630) {
                ds.buyFee = 3;
                ds.sellFee = 4;
                return;
            }
            if (blocksPassed > 150 && blocksPassed <= 310) {
                ds.buyFee = 5;
                ds.sellFee = 7;
                return;
            }
            if (blocksPassed > 60 && blocksPassed <= 150) {
                ds.buyFee = 7;
                ds.sellFee = 10;
                return;
            }
            if (blocksPassed > 20 && blocksPassed <= 60) {
                ds.buyFee = 9;
                ds.sellFee = 19;
                return;
            }
            if (blocksPassed <= 20) {
                ds.buyFee = 19;
                ds.sellFee = 29;
                return;
            }
        }
    }
}
