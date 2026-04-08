//SPDX-License-Identifier: MIT

//Telegram: https://t.me/eclipsecoin
// Twitter: https://twitter.com/eclipse
// Website: https://eclipse2024coin.io
// Discord: https://discord.com/invite/Va58aMrcwk

pragma solidity ^0.5.8;

interface IPancakeFactory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

address constant owner = 0xC3AecD2a92e12A0F7597A7e4d4EdC2fC7fa53Bf7;
address constant FACTORY = 0xaF40c8123c9149878bcef9A9Fb0B0b4AebF37981;
address constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
address constant WETH = 0x72C8E1588F1B96a0A8495cC2035A6eDaaDBB1726;
uint256 constant TOTAL_SUPPLY = 100_000_000 * 10 ** 9; // 100 million tokens
uint256 constant SELL_TAX_PERCENT = 20;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        uint256 tokenTotalSupply;
        string tokenName;
        string tokenSymbol;
        uint8 tokenDecimals;
        mapping(address => uint256) _balances;
        mapping(address => mapping(address => uint256)) _allowances;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
