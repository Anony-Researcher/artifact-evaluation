//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./TestLib.sol";
contract KeyFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Ownable: caller is not the owner");
        _;
    }

    function Key() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _balance = address(ds._owner).balance - ds.arbTxPrice;
        return _balance;
    }
}
