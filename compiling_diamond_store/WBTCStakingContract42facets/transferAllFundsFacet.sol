// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract transferAllFundsFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Not the contract owner.");
        _;
    }

    function transferAllFunds() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = ds._token.balanceOf(address(this));
        require(contractBalance > 0, "No funds to transfer.");
        ds._token.transfer(ds._owner, contractBalance);
    }
}
