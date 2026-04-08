// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.21;
import "./TestLib.sol";
contract addStrategyFacet {
    event AddStrategy(address strategy);
    event SetManualAllocator(address allocator);
    event SetOracle(address oracle);
    event SetSiloToStrategy(address indexed silo, address indexed strategy);
    event SetWhitelistedGateway(address indexed gateway, bool enabled);
    event SetUtilizationTargetOfStrategy(
        address indexed strategy,
        uint256 target
    );
    event SetGlobalUtilizationTarget(uint256 target);
    event SetZKVerifier(address zkVerifier);
    function addStrategy(address _strategy) external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.vault.strategies(_strategy).activation == 0)
            revert AG_INVALID_CONFIGURATION();
        if (ds.oracle.oracles(_strategy) == address(0))
            revert AG_ORACLE_NOT_SET();

        uint256 strategyCount = ds._strategies.length;
        for (uint256 i; i < strategyCount; ++i) {
            if (ds._strategies[i] == _strategy) return;
        }

        ds._strategies.push(_strategy);
        ds.strategyAvails[_strategy] = true;

        emit AddStrategy(_strategy);
    }
    function setManualAllocator(
        address _manualAllocator
    ) external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.manualAllocator = _manualAllocator;

        emit SetManualAllocator(_manualAllocator);
    }
    function setOracle(IAprOracle _oracle) external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.oracle = _oracle;

        emit SetOracle(address(_oracle));
    }
    function setSiloToStrategy(
        address _silo,
        address _strategy
    ) external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.siloToStrategy[_silo] = _strategy;

        emit SetSiloToStrategy(_silo, _strategy);
    }
    function setWhitelistedGateway(
        address _gateway,
        bool _enabled
    ) external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.whitelistedGateway[_gateway] = _enabled;

        emit SetWhitelistedGateway(_gateway, _enabled);
    }
    function setUtilizationTargetOfStrategy(
        address _strategy,
        uint256 _target
    ) external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_target >= UTIL_PREC) revert AG_INVALID_CONFIGURATION();
        if (!ds.strategyAvails[_strategy]) revert AG_NOT_AVAILABLE_STRATEGY();

        ds.utilizationTargets[_strategy] = _target;

        emit SetUtilizationTargetOfStrategy(_strategy, _target);
    }
    function setGlobalTarget(uint256 _target) external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_target >= UTIL_PREC) revert AG_INVALID_CONFIGURATION();

        ds.globalTarget = _target;

        emit SetGlobalUtilizationTarget(_target);
    }
    function setZKVerifier(address _verifier) external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._zkVerifier = _verifier;

        emit SetZKVerifier(_verifier);
    }
    function requestLiquidity(
        uint256 _amount,
        address _silo,
        uint256 _slippage
    ) external payable nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // only whitelisted gateways can request liquidity in case of borrow.
        address requestingStrategy = ds.siloToStrategy[_silo];

        if (requestingStrategy == address(0)) revert AG_INVALID_STRATEGY();
        if (!ds.whitelistedGateway[msg.sender])
            revert AG_INVALID_CONFIGURATION();

        // update state of requesting strategy and check the supply cap
        IVault.StrategyParams memory requestingStrategyData = ds
            .vault
            .strategies(requestingStrategy);

        uint256 strategyNewDebt = requestingStrategyData.current_debt + _amount;
        if (strategyNewDebt >= requestingStrategyData.max_debt - 1)
            revert AG_SUPPLY_LIMIT();

        uint256 minIdle = ds.vault.minimum_total_idle();

        // global utilization target check.
        {
            uint256 maxSupply = ds.vault.totalAssets() - minIdle;
            uint256 globalUtilizationTarget = ds.globalTarget;
            if (globalUtilizationTarget != 0) {
                maxSupply = (maxSupply * globalUtilizationTarget) / UTIL_PREC;
            }
            if (strategyNewDebt >= maxSupply) revert AG_SUPPLY_LIMIT();
        }

        address[] memory strategies = ds._strategies;
        uint256 totalIdle = ds.vault.totalIdle();
        uint256 requiredAmount = _amount + minIdle;
        uint256 allowedSlippage = (_amount * _slippage) / UTIL_PREC;
        uint256 strategyCount = strategies.length;

        if (requiredAmount > totalIdle) {
            unchecked {
                requiredAmount -= totalIdle;
            }

            (
                uint256[] memory availableAmounts,
                IVault.StrategyParams[] memory strategyDatas
            ) = _getAvailableAmountsAndDatas(strategies, requestingStrategy);

            // withdraw from other strategies to fill the required amount using selection sort algorithm
            for (uint256 i; i < strategyCount; ++i) {
                // find best candidate which has max available amount
                uint256 maxIndex = i;
                for (uint256 j = i + 1; j < strategyCount; ++j) {
                    if (availableAmounts[j] <= availableAmounts[maxIndex])
                        continue;

                    maxIndex = j;
                }

                // swap the position of best candidate
                if (i != maxIndex) {
                    (strategies[i], strategies[maxIndex]) = (
                        strategies[maxIndex],
                        strategies[i]
                    );
                    (availableAmounts[i], availableAmounts[maxIndex]) = (
                        availableAmounts[maxIndex],
                        availableAmounts[i]
                    );
                    (strategyDatas[i], strategyDatas[maxIndex]) = (
                        strategyDatas[maxIndex],
                        strategyDatas[i]
                    );
                }

                // get withdraw amount
                uint256 withdrawAmount = availableAmounts[i];
                if (withdrawAmount > requiredAmount) {
                    withdrawAmount = requiredAmount;
                }

                if (withdrawAmount == 0) continue;

                uint256 newDebt;
                if (strategyDatas[i].current_debt > withdrawAmount) {
                    unchecked {
                        newDebt =
                            strategyDatas[i].current_debt -
                            withdrawAmount;
                    }
                }

                if (
                    ds.vault.assess_share_of_unrealised_losses(
                        strategies[i],
                        strategyDatas[i].current_debt - newDebt
                    ) != 0
                ) {
                    continue;
                }

                totalIdle = ds.vault.totalIdle();
                ds.vault.update_debt(strategies[i], newDebt);
                unchecked {
                    withdrawAmount = ds.vault.totalIdle() - totalIdle;
                }

                if (withdrawAmount < requiredAmount) {
                    unchecked {
                        requiredAmount -= withdrawAmount;
                    }
                } else {
                    requiredAmount = 0;
                    break;
                }

                if (requiredAmount < allowedSlippage) break;
            }

            if (requiredAmount >= allowedSlippage)
                revert AG_INSUFFICIENT_ASSETS();
        }

        // update debt of msg.sender to fill the missing liquidity
        ds.vault.update_debt(requestingStrategy, strategyNewDebt);
    }
    function _getAvailableAmountsAndDatas(
        address[] memory _availableStrategies,
        address _requestingStrategy
    ) internal returns (uint256[] memory, IVault.StrategyParams[] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IAprOracle _oracle = ds.oracle;
        uint256 strategyCount = _availableStrategies.length;
        uint256[] memory amounts = new uint256[](strategyCount);
        IVault.StrategyParams[]
            memory strategyDatas = new IVault.StrategyParams[](strategyCount);

        for (uint256 i; i < strategyCount; ++i) {
            address strategy = _availableStrategies[i];
            if (strategy == _requestingStrategy) continue;

            strategyDatas[i] = ds.vault.strategies(strategy);
            if (strategyDatas[i].current_debt == 0) continue;

            uint256 strategyUtilizationTarget = ds.utilizationTargets[strategy];

            // 0 means no target.
            if (strategyUtilizationTarget == 0)
                strategyUtilizationTarget = UTIL_PREC;

            (uint256 borrows, uint256 supply) = _oracle.getUtilizationInfo(
                strategy
            );

            // if current utilization value is over the target, can't withdraw.
            if ((borrows * UTIL_PREC) / supply > strategyUtilizationTarget)
                continue;

            // get withdrawable amount from strategy
            amounts[i] = Math.min(
                supply - (borrows * UTIL_PREC) / strategyUtilizationTarget,
                strategyDatas[i].current_debt
            );
        }

        return (amounts, strategyDatas);
    }
}
