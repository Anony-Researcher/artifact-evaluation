// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getAggregatorUSDTInterfaceFacet is Ownable {
    using SafeMath for uint256;

    function getAggregatorUSDTInterface()
        public
        view
        returns (AggregatorV3Interface)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.aggregatorUSDTInterface;
    }
}
