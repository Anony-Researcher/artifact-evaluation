// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "./TestLib.sol";
contract setSwapTokensAtAmountFacet is ERC20 {
    using SafeMath for uint256;

    event SwapTokenAmountUpdated(uint256 indexed amount);
    event SwapStatusUpdated(bool indexed status);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function setSwapTokensAtAmount(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amount <= totalSupply(),
            "ERROR: Amount cannot be over the total supply."
        );

        ds.swapTokensAtAmount = amount;
        emit SwapTokenAmountUpdated(amount);
    }
    function setSwapEnable(bool _enabled) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapEnable = _enabled;
        emit SwapStatusUpdated(_enabled);
    }
    function setAutomatedMarketMakerPair(
        address pair,
        bool value
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            pair != ds.uniswapV2Pair,
            "ERROR: The Uniswap pair cannot be removed from ds.automatedMarketMakerPairs"
        );
        _setAutomatedMarketMakerPair(pair, value);
    }
    function transferTokens(
        address tokenAddress,
        address to,
        uint256 amount
    ) public onlyOwner {
        IERC20(tokenAddress).transfer(to, amount);
    }
    function migrateETH(address payable recipient) public onlyOwner {
        require(recipient != address(0), "ERROR: Zero address");
        recipient.transfer(address(this).balance);
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override(ERC20) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            sender != address(0),
            "ERROR: ERC20: transfer from the zero address"
        );
        require(
            recipient != address(0),
            "ERROR: ERC20: transfer to the zero address"
        );

        uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= ds.swapTokensAtAmount;

        if (
            !ds.swapping &&
            canSwap &&
            ds.swapEnable &&
            ds.automatedMarketMakerPairs[recipient]
        ) {
            ds.swapping = true;
            uint256 half = ds.swapTokensAtAmount.div(2);
            uint256 otherHalf = ds.swapTokensAtAmount.sub(half);

            swapTokensForETH(half);
            uint256 newBalance = address(this).balance;

            if (newBalance > 0) {
                addLiquidity(otherHalf, newBalance);
            }
            ds.swapping = false;
        }
        super._transfer(sender, recipient, amount);
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
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
    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);
        ds.uniswapV2Router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            address(this),
            block.timestamp.add(300)
        );
    }
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.automatedMarketMakerPairs[pair] != value,
            "ERROR: Automated market maker pair is already set to that value"
        );
        ds.automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
