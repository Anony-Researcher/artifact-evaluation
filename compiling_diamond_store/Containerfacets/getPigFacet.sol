// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract getPigFacet is ERC721 {
    modifier ownerOnly() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner);
        _;
    }

    function getPig(uint _id) public view returns (TestLib.Pig memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.pigs[_id];
    }
}
