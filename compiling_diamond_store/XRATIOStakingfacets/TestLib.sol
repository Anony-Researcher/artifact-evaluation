// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(address from, address to, uint256 value) external;
}

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct Stake {
        uint256 plan;
        uint256 withdrawtime;
        uint256 staketime;
        uint256 amount;
        uint256 reward;
        uint256 persecondreward;
        bool withdrawan;
        bool unstaked;
    }
    struct User {
        uint256 totalStakedTokenUser;
        uint256 totalWithdrawanTokenUser;
        uint256 totalUnStakedTokenUser;
        uint256 totalClaimedRewardTokenUser;
        uint256 stakeCount;
        bool alreadyExists;
    }

    struct TestStorage {
        IERC20 stakeToken;
        address payable owner;
        uint256 totalStakedToken;
        uint256 totalUnStakedToken;
        uint256 totalWithdrawanToken;
        uint256 totalClaimedRewardToken;
        uint256 totalStakers;
        uint256 percentDivider;
        uint256 unstakePercent;
        uint256[3] Duration;
        uint256[3] Bonus;
        uint256[3] Penalty;
        uint256[3] totalStakedPerPlan;
        uint256[3] totalStakersPerPlan;
        mapping(address => undefined) Stakers;
        mapping(uint256 => address) StakersID;
        mapping(address => mapping(uint256 => undefined)) stakersRecord;
        mapping(address => mapping(uint256 => uint256)) userStakedPerPlan;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
