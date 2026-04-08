// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawETHFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not ds.owner");
        _;
    }

    function withdrawETH() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        payable(ds.owner).transfer(address(this).balance);
    }
}
