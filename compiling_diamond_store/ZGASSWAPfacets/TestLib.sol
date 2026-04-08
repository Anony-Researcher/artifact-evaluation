// SPDX-License-Identifier: MIT
// Telegram: https://t.me/zerogastoken
pragma solidity ^0.8.25;

interface IERCZGAS {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event AddLiquidity(uint32 _timeTillUnlockLiquidity, uint256 value);
    event RemoveLiquidity(uint256 value);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out
    );
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        address owner;
        uint256 fee;
        IERCZGAS token;
        mapping(address => uint32) lastTX;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
