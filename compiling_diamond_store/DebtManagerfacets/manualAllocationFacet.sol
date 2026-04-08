// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.21;
import "./TestLib.sol";
contract manualAllocationFacet {
    function manualAllocation(
        TestLib.StrategyAllocation[] memory _newPositions
    ) external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (msg.sender != ds.manualAllocator) revert AG_NOT_MANUAL_ALLOCATOR();

        _manualAllocation(_newPositions);
    }
    function _manualAllocation(
        TestLib.StrategyAllocation[] memory _newPositions
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        unchecked {
            uint256 strategyLength = _newPositions.length;

            for (uint256 i; i < strategyLength; ++i) {
                TestLib.StrategyAllocation memory position = _newPositions[i];
                if (!ds.strategyAvails[position.strategy])
                    revert AG_NOT_AVAILABLE_STRATEGY();

                IVault.StrategyParams memory strategyData = ds.vault.strategies(
                    position.strategy
                );

                if (strategyData.activation == 0)
                    revert AG_NOT_AVAILABLE_STRATEGY();

                if (strategyData.current_debt == position.debt) continue;

                if (position.debt > strategyData.max_debt)
                    revert AG_HIGHER_DEBT();

                // deposit/increase not possible because minimum total idle reached
                if (
                    position.debt > strategyData.current_debt &&
                    ds.vault.totalIdle() <= ds.vault.minimum_total_idle()
                ) continue;

                if (
                    strategyData.current_debt > position.debt &&
                    ds.vault.assess_share_of_unrealised_losses(
                        position.strategy,
                        strategyData.current_debt - position.debt
                    ) !=
                    0
                ) {
                    ds.vault.process_report(position.strategy);
                }

                // update debt.
                ds.vault.update_debt(position.strategy, position.debt);
            }
        }
    }
    function zkAllocation(
        TestLib.StrategyAllocation[] memory _newPositions
    ) external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (msg.sender != ds._zkVerifier) revert AG_NOT_ZK_VERIFIER();
        if (ds._strategies.length != _newPositions.length)
            revert AG_INVALID_CONFIGURATION();

        _manualAllocation(_newPositions);
    }
}
