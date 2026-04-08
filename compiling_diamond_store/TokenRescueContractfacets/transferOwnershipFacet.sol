// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract transferOwnershipFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner,
            "This function is restricted to the contract's ds.owner."
        );
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newOwner != address(0), "New ds.owner is the zero address.");
        ds.owner = newOwner;
    }
}
