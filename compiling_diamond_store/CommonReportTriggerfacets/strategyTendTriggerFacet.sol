// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract strategyTendTriggerFacet is Governance {
    function strategyTendTrigger(
        address _strategy
    ) external view returns (bool, bytes memory) {
        // Return the status of the tend trigger.
        return IStrategy(_strategy).tendTrigger();
    }
}
