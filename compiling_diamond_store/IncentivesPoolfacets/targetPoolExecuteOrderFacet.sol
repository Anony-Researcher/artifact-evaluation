// File: @openzeppelin/contracts/utils/math/SafeCast.sol

/// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract targetPoolExecuteOrderFacet {
    using SafeERC20 for IERC20;
    using AddressLib for Address;
    using AddressSet for AddressSet.Data;

    modifier onlyManager() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (msg.sender != ds._manager) revert OnlyManager();
        _;
    }
    modifier onlySolvers() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._solvers.contains(msg.sender)) revert OnlySolvers();
        _;
    }

    event OrderExecuted(uint256 netDy, uint256 solverFee);
    function targetPoolExecuteOrder(
        bytes calldata executeData
    ) external onlySolvers {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (
            int128 i,
            int128 j,
            uint256 dx,
            uint256 netDy,
            address settlement,
            address iToken,
            address jToken
        ) = abi.decode(
                executeData,
                (int128, int128, uint256, uint256, address, address, address)
            );

        if (!ds._settlements.contains(settlement)) revert OnlySettlements();

        if (iToken == address(0))
            iToken = ds._targetPool.coins(SafeCast.toUint256(int256(i)));
        if (jToken == address(0))
            jToken = ds._targetPool.coins(SafeCast.toUint256(int256(j)));
        if (jToken != address(ds._buyToken)) revert BuyTokenIncorrect(jToken);

        if (iToken == WETH_TOKEN && address(this).balance < dx)
            WETH9.withdraw(dx);

        // Note: curve pools before v0.3.0 (approx spring/summer 2021) do not include the additional
        //       ICurvePlainPool.exchange(i, j, dx, minDy, receiver) overload
        uint256 dy = ds._targetPool.exchange{value: dx}(i, j, dx, netDy);
        if (jToken == ETH_TOKEN) {
            payable(settlement).transfer(netDy);
        } else {
            IERC20(jToken).safeTransfer(settlement, netDy);
        }
        emit OrderExecuted(netDy, dy - netDy);
    }
}
