// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract setCustomStrategyBaseFeeFacet is Governance {
    event UpdatedCustomStrategyBaseFee(
        address indexed strategy,
        uint256 acceptableBaseFee
    );
    function setCustomStrategyBaseFee(
        address _strategy,
        uint256 _baseFee
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == IStrategy(_strategy).management(), "!authorized");
        ds.customStrategyBaseFee[_strategy] = _baseFee;

        emit UpdatedCustomStrategyBaseFee(_strategy, _baseFee);
    }
}
