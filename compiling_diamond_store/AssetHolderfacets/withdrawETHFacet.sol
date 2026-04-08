// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract withdrawETHFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    event WithdrawnETH(address to, uint256 amount);
    function withdrawETH() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH balance");
        emit WithdrawnETH(ds.owner, balance);
        payable(ds.owner).transfer(balance);
    }
}
