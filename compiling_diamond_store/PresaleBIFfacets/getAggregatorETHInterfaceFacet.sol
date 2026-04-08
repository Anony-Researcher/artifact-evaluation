// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getAggregatorETHInterfaceFacet is Ownable {
    using SafeMath for uint256;

    function getAggregatorETHInterface()
        public
        view
        returns (AggregatorV3Interface)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.aggregatorETHInterface;
    }
}
