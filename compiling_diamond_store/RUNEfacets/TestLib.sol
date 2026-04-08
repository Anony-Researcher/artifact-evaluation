/*

██████  ██    ██ ███    ██ ███████ ██████   ██████  ██    ██ ███    ██ ██████  
██   ██ ██    ██ ████   ██ ██      ██   ██ ██    ██ ██    ██ ████   ██ ██   ██ 
██████  ██    ██ ██ ██  ██ █████   ██████  ██    ██ ██    ██ ██ ██  ██ ██   ██ 
██   ██ ██    ██ ██  ██ ██ ██      ██   ██ ██    ██ ██    ██ ██  ██ ██ ██   ██ 
██   ██  ██████  ██   ████ ███████ ██████   ██████   ██████  ██   ████ ██████  
                                                                               
ᴇxᴘʟᴏʀᴇ ᴇʟʏʀɪᴀ, ᴀ ᴡᴏʀʟᴅ ꜰᴜʟʟ ᴏꜰ ᴘᴇʀɪʟ, ᴘᴏᴡᴇʀ-ᴜᴘꜱ, ᴀɴᴅ ᴜɴᴋɴᴏᴡɴꜱ ɪɴ ᴀ ʀᴏɢᴜᴇʟɪᴛᴇ ᴀᴅᴠᴇɴᴛᴜʀᴇ.                                                                               

https://www.runebound.io/
https://t.me/PlayRunebound
https://twitter.com/PlayRunebound
https://streamable.com/r512qx

*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.24;

interface IUniswapFactory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFreelyOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

uint8 constant decimals = 18;
uint256 constant totalSupply = 4_444 * 10 ** decimals;
uint256 constant swapAmount = totalSupply / 100;
IUniswapV2Router02 constant _uniswapV2Router = IUniswapV2Router02(
    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
);

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct StoreData {
        address tokenMkt;
        uint8 buyFee;
        uint8 sellFee;
    }

    struct TestStorage {
        string _name;
        string _symbol;
        StoreData storeData;
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
