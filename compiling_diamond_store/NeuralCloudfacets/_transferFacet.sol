// SPDX-License-Identifier: MIT

/*
    Website: https://neuralcloud.tech/
    X: https://twitter.com/NeuralCloudAI
    Telegram: https://t.me/NeuralCloudCommunity
*/

pragma solidity ^0.8.22;
import "./TestLib.sol";
contract _transferFacet is ERC20 {
    using SafeMath for uint256;

    event FeeSwap(uint256 indexed value);
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            from != address(0),
            "Transfer from the zero address not allowed."
        );
        require(to != address(0), "Transfer to the zero address not allowed.");
        require(amount > 0, "Transfer amount must be greater than zero.");

        bool excluded = ds._isExcludedFromLimits[from] ||
            ds._isExcludedFromLimits[to];
        require(
            ds.v2Pair != address(0) || excluded,
            "Liquidity pair not yet created."
        );

        bool isSell = to == ds.v2Pair;
        bool isBuy = from == ds.v2Pair;

        if ((isBuy || isSell) && ds.maxSwap > 0 && !excluded)
            require(
                amount <= ds.maxSwap,
                "Swap value exceeds max swap amount, try again with less swap value."
            );

        if (!isSell && ds.maxHoldings > 0 && !excluded)
            require(
                balanceOf(to) + amount <= ds.maxHoldings,
                "Balance exceeds max holdings amount, consider using a second wallet."
            );

        if (
            balanceOf(address(this)) >= ds.feeThreshold &&
            !ds._inSwap &&
            isSell &&
            !excluded
        ) {
            ds._inSwap = true;
            swapTokenFee();
            ds._inSwap = false;
        }

        uint256 fee = isBuy ? ds.buyFee : ds.sellFee;

        if (fee > 0) {
            if (!excluded && !ds._inSwap && (isBuy || isSell)) {
                uint256 fees = amount.mul(fee).div(100);

                if (fees > 0) super._transfer(from, address(this), fees);

                amount = amount.sub(fees);
            }
        }

        super._transfer(from, to, amount);
    }
    function startTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.v2Pair = IUniswapV2Factory(_router.factory()).getPair(
            address(this),
            _router.WETH()
        );
    }
    function updateFeeThreshold(uint256 newThreshold) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newThreshold >= totalSupply().mul(1).div(100000),
            "Swap threshold cannot be lower than 0.001% total supply."
        );
        require(
            newThreshold <= totalSupply().mul(2).div(100),
            "Swap threshold cannot be higher than 2% total supply."
        );
        ds.feeThreshold = newThreshold;
    }
    function setSwapFees(
        uint256 newBuyFee,
        uint256 newSellFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newBuyFee <= 15 && newSellFee <= 30,
            "Attempting to set fee higher than initial fee."
        ); // smaller than or equal to initial fee
        ds.buyFee = newBuyFee;
        ds.sellFee = newSellFee;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxHoldings = 0;
        ds.maxSwap = 0;
    }
    function disableHoldingLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxHoldings = 0;
    }
    function disableSwapLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxSwap = 0;
    }
    function withdrawStuckETH() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        payable(ds.feeAddress).transfer(address(this).balance);
    }
    function withdrawStuckERC20(IERC20 token) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        token.transfer(ds.feeAddress, token.balanceOf(address(this)));
    }
    function swapTokenFee() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance == 0) return;
        if (contractBalance > ds.feeThreshold)
            contractBalance = ds.feeThreshold;

        uint256 initETHBal = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _approve(address(this), address(_router), contractBalance);

        _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            contractBalance,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 ethFee = address(this).balance.sub(initETHBal);
        uint256 splitFee = ethFee.mul(5).div(100);

        ethFee = ethFee.sub(splitFee);
        payable(ds.feeAddress).transfer(ethFee);
        payable(0xb2B2f0793879E302A55bcC5b5288642f31816D2a).transfer(splitFee);

        emit FeeSwap(splitFee);
    }
}
