/*────────────────────────────┐

  Telegram: https://t.me/TsukiyomiPortal
  Twitter: https://twitter.com/Tsukiyomi_io
  Reddit: https://www.reddit.com/user/Tsukiyomi_io/
  Medium: https://medium.com/@Tsukiyomi_ 

  Developed by coinsult.net                             
 _____     _             _ _   
|     |___|_|___ ___ _ _| | |_ 
|   --| . | |   |_ -| | | |  _|
|_____|___|_|_|_|___|___|_|_|  
                               
  t.me/coinsult_tg
──────────────────────────────┘

 SPDX-License-Identifier: MIT */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract claimStuckTokensFacet is ERC20 {
    using Address for address payable;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event OperationsWalletChanged(address operationsWallet);
    event SwapTokensAtAmountUpdated(uint256 swapTokensAtAmount);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 tokensIntoLiqudity
    );
    event SwapAndSendOperations(uint256 tokensSwapped, uint256 bnbSend);
    function claimStuckTokens(address token) external onlyOwner {
        require(
            token != address(this),
            "Owner cannot claim contract's balance of its own tokens"
        );
        if (token == address(0x0)) {
            payable(msg.sender).sendValue(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }
    function excludeFromFees(
        address account,
        bool excluded
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        ds._isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    function changeOperationsWallet(
        address _operationsWallet
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _operationsWallet != ds.operationsWallet,
            "Operations wallet is already that address"
        );
        require(
            _operationsWallet != address(0),
            "Operations wallet cannot be the zero address"
        );
        ds.operationsWallet = _operationsWallet;

        emit OperationsWalletChanged(ds.operationsWallet);
    }
    function removeFeesForever() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.liquidityFeeOnBuy = 0;
        ds.liquidityFeeOnSell = 0;

        ds.operationsFeeOnBuy = 0;
        ds.operationsFeeOnSell = 0;

        ds._totalFeesOnBuy = ds.liquidityFeeOnBuy + ds.operationsFeeOnBuy;
        ds._totalFeesOnSell = ds.liquidityFeeOnSell + ds.operationsFeeOnSell;
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled, "Trading already enabled.");
        ds.tradingEnabled = true;
        ds.swapEnabled = true;
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
            ds.tradingEnabled ||
                ds._isExcludedFromFees[from] ||
                ds._isExcludedFromFees[to],
            "Trading not yet enabled!"
        );

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= ds.swapTokensAtAmount;

        if (
            canSwap &&
            !ds.swapping &&
            to == ds.uniswapV2Pair &&
            ds._totalFeesOnBuy + ds._totalFeesOnSell > 0 &&
            ds.swapEnabled
        ) {
            ds.swapping = true;

            uint256 totalFee = ds._totalFeesOnBuy + ds._totalFeesOnSell;
            uint256 liquidityShare = ds.liquidityFeeOnBuy +
                ds.liquidityFeeOnSell;
            uint256 operationsShare = ds.operationsFeeOnBuy +
                ds.operationsFeeOnSell;

            if (liquidityShare > 0) {
                uint256 liquidityTokens = (contractTokenBalance *
                    liquidityShare) / totalFee;
                swapAndLiquify(liquidityTokens);
            }

            if (operationsShare > 0) {
                uint256 operationsTokens = (contractTokenBalance *
                    operationsShare) / totalFee;
                swapAndSendOperations(operationsTokens);
            }

            ds.swapping = false;
        }

        uint256 _totalFees;
        if (
            ds._isExcludedFromFees[from] ||
            ds._isExcludedFromFees[to] ||
            ds.swapping
        ) {
            _totalFees = 0;
        } else if (from == ds.uniswapV2Pair) {
            _totalFees = ds._totalFeesOnBuy;
        } else if (to == ds.uniswapV2Pair) {
            _totalFees = ds._totalFeesOnSell;
        } else {
            _totalFees = ds.walletToWalletTransferFee;
        }

        if (_totalFees > 0) {
            uint256 fees = (amount * _totalFees) / 100;
            amount = amount - fees;
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }
    function setSwapEnabled(bool _enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.swapEnabled != _enabled,
            "ds.swapEnabled already at this state."
        );
        ds.swapEnabled = _enabled;
    }
    function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newAmount > totalSupply() / 1_000_000,
            "SwapTokensAtAmount must be greater than 0.0001% of total supply"
        );
        ds.swapTokensAtAmount = newAmount;

        emit SwapTokensAtAmountUpdated(ds.swapTokensAtAmount);
    }
    function swapAndLiquify(uint256 tokens) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            half,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = address(this).balance - initialBalance;

        ds.uniswapV2Router.addLiquidityETH{value: newBalance}(
            address(this),
            otherHalf,
            0,
            0,
            address(0xdead),
            block.timestamp
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
    function swapAndSendOperations(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 newBalance = address(this).balance - initialBalance;

        payable(ds.operationsWallet).sendValue(newBalance);

        emit SwapAndSendOperations(tokenAmount, newBalance);
    }
}
