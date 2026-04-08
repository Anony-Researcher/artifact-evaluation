// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract changeOwnerFacet is ERC721 {
    modifier ownerOnly() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner);
        _;
    }

    function changeOwner(address newOwner) public ownerOnly {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._owner = newOwner;
    }
}
