// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "./TestLib.sol";
contract withdrawTRBFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "This is not ds.owner.");
        _;
    }

    function withdrawTRB() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 balance = ds.tellorToken.balanceOf(address(this));
        ds.tellorToken.transfer(ds.owner, balance);
    }
}
