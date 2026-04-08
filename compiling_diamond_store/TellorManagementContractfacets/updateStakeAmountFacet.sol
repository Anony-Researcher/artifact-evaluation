// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./TestLib.sol";
contract updateStakeAmountFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "This is not ds.owner.");
        _;
    }

    function updateStakeAmount() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tellorFlex.updateStakeAmount();
    }
}
