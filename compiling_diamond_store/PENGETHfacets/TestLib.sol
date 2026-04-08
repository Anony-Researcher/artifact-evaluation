/*

The most asked question in the universe is PENG?

NO TAX 0/0%


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

string constant name = "PENG"; //
string constant symbol = "PENG"; //
uint8 constant decimals = 18;
uint256 constant totalSupply = 100_000_000 * 10 ** decimals;
uint256 constant swapAmount = totalSupply / 100;
address constant ETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
IUniswapV2Router02 constant _uniswapV2Router = IUniswapV2Router02(
    routerAddress
);
address constant deployer = payable(
    address(0x610d6a61B8331601461C52c68EF234bee3c99DCD)
); //

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        uint256 BurnAmount;
        uint256 ConfirmAmount;
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
