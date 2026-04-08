// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawTokensFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not ds.owner");
        _;
    }

    function withdrawTokens(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "Amount must be greater than 0");
        uint256 contractBalance = ds.token.balanceOf(address(this));
        require(amount <= contractBalance, "Insufficient balance in contract");

        ds.token.transfer(ds.treasuryContract, amount);
    }
}
