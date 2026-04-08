// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract setCustomVaultTriggerFacet is Governance {
    event UpdatedCustomVaultTrigger(
        address indexed vault,
        address indexed strategy,
        address indexed trigger
    );
    function setCustomVaultTrigger(
        address _vault,
        address _strategy,
        address _trigger
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Check that the address has the ADD_STRATEGY_MANAGER role on
        // the vault. Just check their role has a 1 at the first position.
        uint256 mask = 1;
        require(
            (IVault(_vault).roles(msg.sender) & mask) == mask,
            "!authorized"
        );
        ds.customVaultTrigger[_vault][_strategy] = _trigger;

        emit UpdatedCustomVaultTrigger(_vault, _strategy, _trigger);
    }
}
