// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract acceptOwnershipFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Only ds.owner!");
        _;
    }

    function acceptOwnership() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.pendingOwner, "Only pending ds.owner!");
        ds.owner = ds.pendingOwner;
        delete ds.pendingOwner;
    }
}
