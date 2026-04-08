// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract strategyReportTriggerFacet is Governance {
    function strategyReportTrigger(
        address _strategy
    ) external view returns (bool, bytes memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address _trigger = ds.customStrategyTrigger[_strategy];

        // If a custom trigger contract is set use that one.
        if (_trigger != address(0)) {
            return ICustomStrategyTrigger(_trigger).reportTrigger(_strategy);
        }

        // Return the default trigger logic.
        return defaultStrategyReportTrigger(_strategy);
    }
    function defaultStrategyReportTrigger(
        address _strategy
    ) public view returns (bool, bytes memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Cache the strategy instance.
        IStrategy strategy = IStrategy(_strategy);

        // Don't report if the strategy is shutdown.
        if (strategy.isShutdown()) return (false, bytes("Shutdown"));

        // Don't report if the strategy has no assets.
        if (strategy.totalAssets() == 0) return (false, bytes("Zero Assets"));

        // Check if a `ds.baseFeeProvider` is set.
        address _baseFeeProvider = ds.baseFeeProvider;
        if (_baseFeeProvider != address(0)) {
            uint256 customAcceptableBaseFee = ds.customStrategyBaseFee[
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
            block.timestamp - strategy.lastReport() >
                strategy.profitMaxUnlockTime(),
            // Return the report function sig as the calldata.
            abi.encodeWithSelector(strategy.report.selector)
        );
    }
}
