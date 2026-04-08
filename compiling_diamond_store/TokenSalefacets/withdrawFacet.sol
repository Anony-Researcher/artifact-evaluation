// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawFacet {
    function withdraw() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "You are not the ds.owner.");
        require(address(this).balance > 0, "The balance is zero.");

        uint256 balance = address(this).balance;
        ds.owner.transfer(balance);
    }
}
