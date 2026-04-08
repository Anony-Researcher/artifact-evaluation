// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./TestLib.sol";
contract updateOwnerFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "This is not ds.owner.");
        _;
    }

    function updateOwner(address _owner) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.owner = payable(_owner);
    }
}
