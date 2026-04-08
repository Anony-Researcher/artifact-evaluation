// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract ownerFacet is ERC721 {
    modifier ownerOnly() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner);
        _;
    }

    function owner() public view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._owner;
    }
}
