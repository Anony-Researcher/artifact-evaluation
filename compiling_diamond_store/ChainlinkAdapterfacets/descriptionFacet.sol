// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;
import "./TestLib.sol";
contract descriptionFacet is AggregatorV3Interface {
    function description() external view returns (string memory) {
        return "BTC/ETH Chainlink Adapter";
    }
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
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_roundId == CURRENT_ROUND || _roundId == PREVIOUS_ROUND);

        (int256 btcUsdPrice, uint256 btcUsdUpdatedAt) = _getRoundData(
            ds.BTC_USD_CL_FEED,
            _roundId
        );
        (int256 ethUsdPrice, uint256 ethUsdUpdatedAt) = _getRoundData(
            ds.ETH_USD_CL_FEED,
            _roundId
        );

        roundId = _roundId;
        updatedAt = _min(btcUsdUpdatedAt, ethUsdUpdatedAt);
        answer = _convertAnswer(ethUsdPrice, btcUsdPrice);
    }
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (int256 btcUsdPrice, uint256 btcUsdUpdatedAt) = _latestRoundData(
            ds.BTC_USD_CL_FEED
        );
        (int256 ethUsdPrice, uint256 ethUsdUpdatedAt) = _latestRoundData(
            ds.ETH_USD_CL_FEED
        );

        roundId = CURRENT_ROUND;
        updatedAt = _min(btcUsdUpdatedAt, ethUsdUpdatedAt);
        answer = _convertAnswer(ethUsdPrice, btcUsdPrice);
    }
    function _getRoundData(
        AggregatorV3Interface _feed,
        uint80 _roundId
    ) private view returns (int256 answer, uint256 updatedAt) {
        uint80 feedRoundId;
        if (_roundId == CURRENT_ROUND) {
            (feedRoundId, answer, , updatedAt, ) = _feed.latestRoundData();
        } else {
            (uint80 latestRoundId, , , , ) = _feed.latestRoundData();
            (feedRoundId, answer, , updatedAt, ) = _feed.getRoundData(
                latestRoundId - 1
            );
        }
        require(feedRoundId > 0);
        require(answer > 0);
    }
    function _latestRoundData(
        AggregatorV3Interface _feed
    ) private view returns (int256 answer, uint256 updatedAt) {
        uint80 feedRoundId;
        (feedRoundId, answer, , updatedAt, ) = _feed.latestRoundData();
        require(feedRoundId > 0);
        require(answer > 0);
    }
    function _min(uint256 _a, uint256 _b) private pure returns (uint256) {
        return _a < _b ? _a : _b;
    }
    function _convertAnswer(
        int256 ethUsdPrice,
        int256 btcUsdPrice
    ) private view returns (int256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            (ethUsdPrice * ds.BTC_USD_PRECISION * ADAPTER_PRECISION) /
            (ds.ETH_USD_PRECISION * btcUsdPrice);
    }
}
