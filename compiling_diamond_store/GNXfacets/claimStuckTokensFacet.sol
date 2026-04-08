/*────────────────────────────┐
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
    event UpdateFees(uint256 feeOnBuy, uint256 feeOnSell);
    event FeeReceiverChanged(address feeReceiver);
    event TradingEnabled(bool tradingEnabled);
    event SwapTokensAtAmountUpdated(uint256 swapTokensAtAmount);
    event SwapAndSendFee(uint256 tokensSwapped, uint256 bnbSend);
    function claimStuckTokens(address token) external onlyOwner {
        require(
            token != address(this),
            "CSLT: Owner cannot claim contract's balance of its own tokens"
        );
        if (token == address(0x0)) {
            payable(msg.sender).sendValue(address(this).balance);
            return;
        }

        IERC20(token).transfer(
            msg.sender,
            IERC20(token).balanceOf(address(this))
        );
    }
    function excludeFromFees(
        address account,
        bool excluded
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    function updateFees(
        uint256 _feeOnSell,
        uint256 _feeOnBuy,
        uint256 _feeOnTransfer
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.feeOnBuy = _feeOnBuy;
        ds.feeOnSell = _feeOnSell;
        ds.feeOnTransfer = _feeOnTransfer;

        require(ds.feeOnBuy <= 3, "CSLT: Total Fees cannot exceed the maximum");
        require(
            ds.feeOnSell <= 3,
            "CSLT: Total Fees cannot exceed the maximum"
        );

        emit UpdateFees(ds.feeOnSell, ds.feeOnBuy);
    }
    function changeFeeReceiver(address _feeReceiver) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _feeReceiver != address(0),
            "CSLT: Fee receiver cannot be the zero address"
        );
        ds.feeReceiver = _feeReceiver;

        emit FeeReceiverChanged(ds.feeReceiver);
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingEnabled, "CSLT: Trading already enabled.");
        ds.tradingEnabled = true;
        ds.swapEnabled = true;

        emit TradingEnabled(ds.tradingEnabled);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "CSLT: transfer from the zero address");
        require(to != address(0), "CSLT: transfer to the zero address");
        require(
            ds.tradingEnabled ||
                ds._isExcludedFromFees[from] ||
                ds._isExcludedFromFees[to],
            "CSLT: Trading not yet enabled!"
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
            ds.feeOnBuy + ds.feeOnSell > 0 &&
            !ds._isExcludedFromFees[from] &&
            ds.swapEnabled
        ) {
            ds.swapping = true;

            swapAndSendFee(contractTokenBalance);

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
            _totalFees = ds.feeOnBuy;
        } else if (to == ds.uniswapV2Pair) {
            _totalFees = ds.feeOnSell;
        } else {
            _totalFees = 0;
        }

        if (_totalFees > 0) {
            uint256 fees = (amount * _totalFees) / 100;
            amount = amount - fees;
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);
    }
    function setSwapTokensAtAmount(
        uint256 newAmount,
        bool _swapEnabled
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newAmount > totalSupply() / 1_000_000,
            "CSLT: SwapTokensAtAmount must be greater than 0.0001% of total supply"
        );
        ds.swapTokensAtAmount = newAmount;
        ds.swapEnabled = _swapEnabled;

        emit SwapTokensAtAmountUpdated(ds.swapTokensAtAmount);
    }
    function swapAndSendFee(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();

        try
            ds
                .uniswapV2Router
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                )
        {} catch {
            return;
        }

        uint256 newBalance = address(this).balance - initialBalance;

        payable(ds.feeReceiver).sendValue(newBalance);

        emit SwapAndSendFee(tokenAmount, newBalance);
    }
}
