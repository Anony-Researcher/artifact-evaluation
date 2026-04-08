// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.21 ^0.8.20;
import "./TestLib.sol";
contract getPriceFacet is IOracle {
    using Math for uint256;

    function getPrice(
        AggregatorV3Interface feed
    ) internal view returns (uint256) {
        if (address(feed) == address(0)) return 1;

        (, int256 answer, , , ) = feed.latestRoundData();
        require(answer >= 0, "Negative Answer");

        return uint256(answer);
    }
    function price() external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            ds.SCALE_FACTOR.mulDiv(
                ds.CURVE_TRI_POOL.lp_price() *
                    getPrice(ds.BASE_FEED) *
                    getPrice(ds.LIDO_FEED),
                getPrice(ds.CRVUSD_FEED)
            );
    }
}
