// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./TestLib.sol";
contract depositStakeFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "This is not ds.owner.");
        _;
    }

    function depositStake(uint256 amount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tellorToken.approve(address(ds.tellorFlex), amount);
        ds.tellorFlex.depositStake(amount);
    }
}
