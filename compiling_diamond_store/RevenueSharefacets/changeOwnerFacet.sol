// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract changeOwnerFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not ds.owner");
        _;
    }

    function changeOwner(address newOwner) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.owner = newOwner;
    }
}
