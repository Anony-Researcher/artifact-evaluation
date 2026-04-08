// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface ITellorOracle {
    function depositStake(uint256 _amount) external;
    function submitValue(
        bytes32 _queryId,
        bytes calldata _value,
        uint256 _nonce,
        bytes calldata _queryData
    ) external;
    function requestStakingWithdraw(uint256 _amount) external;
    function withdrawStake() external;
    function getTimeOfLastNewValue() external view returns (uint256);
}

interface ITellorFlex {
    function mintToOracle() external;
    function approve(address _spender, uint256 _amount) external;
    function transfer(
        address _recipient,
        uint256 _amount
    ) external returns (bool);
    function balanceOf(address _account) external view returns (uint256);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

uint256 constant MULTIPLIER = 1e18;
uint256 constant MANAGEMENT_FEE_CAP = 3_000; // Management fee should not exceed 30%.

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct Stake {
        uint256 stakedAmount;
        uint256 rewards;
        uint256 lockedAmount;
        uint256 lockedTimestamp;
    }

    struct TestStorage {
        address owner;
        address marketingWallet;
        ITellorOracle tellorOracle;
        ITellorFlex tellorFlex;
        mapping(address => undefined) userStakes;
        mapping(address => uint256) rewardIndexOf;
        uint256 rewardIndex;
        uint256 totalStakedAmount;
        uint256 MIN_STAKE_AMOUNT;
        uint256 managementFee;
        bool stakePaused;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
