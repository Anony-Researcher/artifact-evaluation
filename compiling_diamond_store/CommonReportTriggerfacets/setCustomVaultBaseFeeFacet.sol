// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract setCustomVaultBaseFeeFacet is Governance {
    event UpdatedCustomVaultBaseFee(
        address indexed vault,
        address indexed strategy,
        uint256 acceptableBaseFee
    );
    function setCustomVaultBaseFee(
        address _vault,
        address _strategy,
        uint256 _baseFee
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Check that the address has the ADD_STRATEGY_MANAGER role on
        // the vault. Just check their role has a 1 at the first position.
        uint256 mask = 1;
        require(
            (IVault(_vault).roles(msg.sender) & mask) == mask,
            "!authorized"
        );
        ds.customVaultBaseFee[_vault][_strategy] = _baseFee;

        emit UpdatedCustomVaultBaseFee(_vault, _strategy, _baseFee);
    }
}
