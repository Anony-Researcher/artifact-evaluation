// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint balance);
    function transfer(
        address recipient,
        uint amount
    ) external returns (bool success);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint remaining);
    function approve(
        address spender,
        uint amount
    ) external returns (bool success);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

//Actual Token Contract

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        string symbol;
        string name;
        uint8 decimals;
        uint _totalSupply;
        mapping(address => uint) balances;
        mapping(address => mapping(address => uint)) allowed;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
