// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./TestLib.sol";
contract approveTRBFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "This is not ds.owner.");
        _;
    }

    function approveTRB(address _to, uint256 _amount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tellorToken.approve(_to, _amount);
    }
}
