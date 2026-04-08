//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract setOwnerFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    function setOwner(address _owner) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.owner = _owner;
    }
}
