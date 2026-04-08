// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

uint256 constant INITIAL_RELEASE_PERCENTAGE = 3000;
uint256 constant MONTHLY_RELEASE_PERCENTAGE = 1167;
uint256 constant ONE_MONTH = 30 days;
uint256 constant AirdropForfeit = 14 days;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");
    struct Allocation {
        uint256 airdrop;
        uint256 presale;
        uint256 claimedAirdrop;
        uint256 claimedPresale;
        bool hasClaimedInitial;
    }

    struct TestStorage {
        address owner;
        address treasuryContract;
        IERC20 token;
        uint256 startTime;
        mapping(address => undefined) allocations;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
