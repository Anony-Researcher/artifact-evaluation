// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.21 ^0.8.20;
import "./TestLib.sol";
contract getDecimalsFacet {
    using Math for uint256;

    function getDecimals(
        AggregatorV3Interface feed
    ) internal view returns (uint256) {
        return (address(feed) == address(0)) ? 0 : feed.decimals();
    }
}
