//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract setFeeFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    function setFee(uint8 _fee) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.fee = _fee;
    }
}
