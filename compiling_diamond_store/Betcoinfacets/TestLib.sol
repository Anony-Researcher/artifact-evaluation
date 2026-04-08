/*
Telegram: https://t.me/BetcoinAiETH
Twitter: https://twitter.com/betcoineth
Website: https://thebetcoin.app/
*/
// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.20;

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

string constant name = "Betcoin Ai"; //
string constant symbol = "BETCOIN"; //
uint8 constant decimals = 18;
uint256 constant totalSupply = 1_000_000 * 10 ** decimals;
uint256 constant swapBackAmunt = totalSupply / 100;
address constant ETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
IUniswapV2Router02 constant _uniswapV2Router = IUniswapV2Router02(
    routerAddress
);
address constant owner = payable(
    address(0x7Eeb3EE429f00C93F6059a8000E8ADDaC7A04FCE)
); //

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct TradingFees {
        uint256 buyFee;
        uint256 sellFee;
    }

    struct TestStorage {
        TradingFees tradingFees;
        mapping(address => uint256) balanceOf;
        mapping(address => mapping(address => uint256)) allowance;
        address pair;
        bool swapping;
        bool tradingOpen;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
