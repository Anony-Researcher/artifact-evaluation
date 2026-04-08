// File: @openzeppelin/contracts/utils/math/SafeCast.sol

/// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v5.0.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract setManagerFacet {
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

    event ManagerUpdated(address indexed addr);
    event SettlementsUpdated(address indexed addr, bool added);
    event SettlementsUpdated(address indexed addr, bool added);
    function setManager(address manager) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._manager = manager;
        emit ManagerUpdated(manager);
    }
    function addSettlement(address settlement) external onlyOwner {
        _addSettlement(settlement);
    }
    function removeSettlement(address settlement) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._settlements.remove(settlement))
            emit SettlementsUpdated(settlement, false);
    }
    function rescueFunds(IERC20 token) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (address(token) == address(ds._buyToken))
            revert OwnerCannotRescueFeeToken();
        _returnFunds(token, 0);
    }
    function rescueTokensExact(
        IERC20[] calldata tokens,
        uint256[] calldata amounts
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // NOTE: amounts in contract must be fetched and encoded off-chain
        for (uint256 i = 0; i < tokens.length; i++) {
            if (address(tokens[i]) == address(ds._buyToken))
                revert OwnerCannotRescueFeeToken();
            _returnFunds(tokens[i], amounts[i]);
        }
    }
    function _returnFunds(IERC20 token, uint256 amount) internal {
        if (address(token) == ETH_TOKEN) {
            if (amount == 0) amount = address(this).balance;
            payable(msg.sender).transfer(amount);
        } else {
            if (amount == 0) amount = token.balanceOf(address(this));
            token.safeTransfer(msg.sender, amount);
        }
    }
    function retrieveFees() external onlyManager {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _returnFunds(ds._buyToken, 0);
    }
    function _addSettlement(address settlement) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._settlements.add(settlement)) revert SettlementAlreadyAdded();
        emit SettlementsUpdated(settlement, true);
    }
}
