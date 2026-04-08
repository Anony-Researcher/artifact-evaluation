// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract vaultReportTriggerFacet is Governance {
    function vaultReportTrigger(
        address _vault,
        address _strategy
    ) external view returns (bool, bytes memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address _trigger = ds.customVaultTrigger[_vault][_strategy];

        // If a custom trigger contract is set use that.
        if (_trigger != address(0)) {
            return
                ICustomVaultTrigger(_trigger).reportTrigger(_vault, _strategy);
        }

        // return the default trigger.
        return defaultVaultReportTrigger(_vault, _strategy);
    }
    function defaultVaultReportTrigger(
        address _vault,
        address _strategy
    ) public view returns (bool, bytes memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Cache the vault instance.
        IVault vault = IVault(_vault);

        // Don't report if the vault is shutdown.
        if (vault.isShutdown()) return (false, bytes("Shutdown"));

        // Cache the strategy parameters.
        IVault.StrategyParams memory params = vault.strategies(_strategy);

        // Don't report if the strategy is not active or has no funds.
        if (params.activation == 0 || params.current_debt == 0)
            return (false, bytes("Not Active"));

        // Check if a `ds.baseFeeProvider` is set.
        address _baseFeeProvider = ds.baseFeeProvider;
        if (_baseFeeProvider != address(0)) {
            uint256 customAcceptableBaseFee = ds.customVaultBaseFee[_vault][
                _strategy
            ];
            // Use the custom base fee if set, otherwise use the default.
            uint256 _acceptableBaseFee = customAcceptableBaseFee != 0
                ? customAcceptableBaseFee
                : ds.acceptableBaseFee;

            // Don't report if the base fee is to high.
            if (
                IBaseFee(_baseFeeProvider).basefee_global() > _acceptableBaseFee
            ) return (false, bytes("Base Fee"));
        }

        return (
            // Return true is the full profit unlock time has passed since the last report.
            block.timestamp - params.last_report > vault.profitMaxUnlockTime(),
            // Return the function selector and the strategy as the parameter to use.
            abi.encodeCall(vault.process_report, _strategy)
        );
    }
}
