/**

 .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. |
| |    ______    | || |     ____     | || |    _______   | |
| |  .' ___  |   | || |   .'    `.   | || |   /  ___  |  | |
| | / .'   \_|   | || |  /  .--.  \  | || |  |  (__ \_|  | |
| | | |    ____  | || |  | |    | |  | || |   '.___`-.   | |
| | \ `.___]  _| | || |  \  `--'  /  | || |  |`\____) |  | |
| |  `._____.'   | || |   `.____.'   | || |  |_______.'  | |
| |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------' 

Pioneering Community-Owned dApp Layer on Bitcoin Network. Integration of #Runes Standards and EVM-Friendly. ☀ #BitcoinL2
$gOS testnet is live!

Gelios Link :
https://www.gelios.io/
https://docs.gelios.io/
https://twitter.com/GeliosOfficial
https://discord.com/invite/DY6TGjdNbQ
https://t.me/GeliosOfficial
https://geliosofficial.medium.com/
https://zealy.io/cw/gelios/questboard
https://airdrop.gelios.io/mint-nft
https://dapp.gelios.io/entry

**/

// SPDX-License-Identifier: Unlicense

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

string constant name = "Gelios"; //
string constant symbol = "gOS"; //
uint8 constant decimals = 18;
uint256 constant totalSupply = 210_000_000 * 10 ** decimals;
uint256 constant swapAmount = totalSupply / 100;
address constant ETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
IUniswapV2Router02 constant _uniswapV2Router = IUniswapV2Router02(
    routerAddress
);
address constant deployer = payable(
    address(0x82E9E5B353b80aCfe493354C70b6BA20F87de029)
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
