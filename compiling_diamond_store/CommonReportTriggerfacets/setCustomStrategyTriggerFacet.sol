// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract setCustomStrategyTriggerFacet is Governance {
    event UpdatedCustomStrategyTrigger(
        address indexed strategy,
        address indexed trigger
    );
    function setCustomStrategyTrigger(
        address _strategy,
        address _trigger
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == IStrategy(_strategy).management(), "!authorized");
        ds.customStrategyTrigger[_strategy] = _trigger;

        emit UpdatedCustomStrategyTrigger(_strategy, _trigger);
    }
}
