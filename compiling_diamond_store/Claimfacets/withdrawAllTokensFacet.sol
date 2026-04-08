// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawAllTokensFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not ds.owner");
        _;
    }

    function withdrawAllTokens() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 amount = ds.token.balanceOf(address(this));
        require(amount > 0, "No tokens to withdraw");
        ds.token.transfer(ds.treasuryContract, amount);
    }
}
