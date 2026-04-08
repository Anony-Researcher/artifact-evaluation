// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract setPigFeeFacet is ERC721 {
    modifier ownerOnly() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner);
        _;
    }

    function setPigFee(uint _cost) public ownerOnly {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.pigFee = _cost;
    }
}
