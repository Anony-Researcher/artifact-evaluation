// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

// contracts/Dependencies/AggregatorV3Interface.sol

// Code from https://github.com/smartcontractkit/chainlink/blob/master/evm-contracts/src/v0.6/interfaces/AggregatorV3Interface.sol

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// contracts/ChainlinkAdapter.sol

uint8 constant decimals = 18;
uint256 constant version = 1;
uint8 constant MAX_DECIMALS = 18;
uint80 constant CURRENT_ROUND = 2;
uint80 constant PREVIOUS_ROUND = 1;
int256 constant ADAPTER_PRECISION = int256(10 ** decimals);

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        AggregatorV3Interface BTC_USD_CL_FEED;
        AggregatorV3Interface ETH_USD_CL_FEED;
        int256 BTC_USD_PRECISION;
        int256 ETH_USD_PRECISION;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
