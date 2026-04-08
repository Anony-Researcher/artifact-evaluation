// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract maxFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Not the contract owner.");
        _;
    }

    function max(int256 a, int256 b) private pure returns (int256) {
        return a >= b ? a : b;
    }
}
