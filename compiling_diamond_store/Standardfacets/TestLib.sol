// SPDX-License-Identifier: MIT

/*

This contract is a safe utility token deployed by Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/standard

*/

pragma solidity 0.8.25;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(
        address account,
        address spender
    ) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed account,
        address indexed spender,
        uint256 amount
    );
}

interface IFactoryStandard {
    function getPair() external view returns (address);
}

interface IUniswapV2Router {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        address owner;
        address feeReceiver;
        address wETH;
        address router;
        address utilReceiver;
        address liquidityPair;
        string name;
        string symbol;
        string socials;
        uint8 decimals;
        uint256 buyFee;
        uint256 sellFee;
        uint256 maxWallet;
        uint256 transferFee;
        uint256 totalSupply;
        uint256 swapBackMin;
        mapping(address => bool) limitExempt;
        mapping(address => uint256) balanceOf;
        mapping(address => mapping(address => uint256)) allowance;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
