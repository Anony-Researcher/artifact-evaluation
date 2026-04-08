//// WE ARE NOT DEGENS!
/// WE ARE $PGENZ!

// PigeonPark.xyz
// http://t.me/PigeonPark
// twitter.com/pigeonparketh

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract openTradingFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function openTrading() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingOpen = true;
    }
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount = 0;
        if (from == ds.uniswapV2Pair && to != address(ds.uniswapV2Router)) {
            require(ds.tradingOpen == true, "Trading is not open");
            uint256 buyTaxAmount = amount.mul(ds.buyTax).div(1000);
            taxAmount += buyTaxAmount;

            if (ds.antiWhale) {
                require(balanceOf(to).add(amount) <= ds.maxBuy, "Max Bought");
            }
        } else if (to == ds.uniswapV2Pair && from != address(this)) {
            uint256 sellTaxAmount = amount.mul(ds.saleTax).div(1000);
            taxAmount += sellTaxAmount;
        }

        if (from == owner() || to == owner()) {
            taxAmount = 0;
        }

        if (taxAmount > 0) {
            super._update(from, ds.taxWallet, taxAmount);
            super._update(from, to, amount - taxAmount);
        } else {
            super._update(from, to, amount);
        }
    }
    function setbuyandselltax(
        uint256 _buyTax,
        uint256 _saleTax
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTax = _buyTax;
        ds.saleTax = _saleTax;
    }
    function disableMaxbuyLimit() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.antiWhale = !ds.antiWhale;
    }
    function setMaxBuy(uint256 _maxBuy) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxBuy = _maxBuy * 10 ** decimals();
    }
    function changePairAddress(address pair) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Pair = pair;
    }
    function changeRouterAddress(address router) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = IUniswapV2Router02(router);
    }
}
