// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract checkETHBalanceFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    function checkETHBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
