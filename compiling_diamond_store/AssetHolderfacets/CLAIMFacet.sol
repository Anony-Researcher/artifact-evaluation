// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract CLAIMFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    event DepositMade(address depositor, uint256 amount);
    function CLAIM() public payable {
        emit DepositMade(msg.sender, msg.value);
    }
}
