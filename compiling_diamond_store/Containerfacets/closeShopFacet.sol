// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract closeShopFacet is ERC721 {
    modifier ownerOnly() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner);
        _;
    }

    function closeShop(bool _close) public ownerOnly {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isClosed = _close;
    }
}
