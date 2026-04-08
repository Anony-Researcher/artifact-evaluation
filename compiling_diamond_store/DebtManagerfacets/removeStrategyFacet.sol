// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.21;
import "./TestLib.sol";
contract removeStrategyFacet is Ownable {
    event RemoveStrategy(address strategy);
    function removeStrategy(address _strategy) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.vault.strategies(_strategy).activation != 0) {
            if (msg.sender != owner()) revert AG_CALLER_NOT_ADMIN();
        }

        uint256 strategyCount = ds._strategies.length;
        for (uint256 i; i < strategyCount; ++i) {
            if (ds._strategies[i] == _strategy) {
                // if not last element
                if (i != strategyCount - 1) {
                    ds._strategies[i] = ds._strategies[strategyCount - 1];
                }

                ds._strategies.pop();
                delete ds.utilizationTargets[_strategy];
                delete ds.strategyAvails[_strategy];

                emit RemoveStrategy(_strategy);

                return;
            }
        }
    }
}
