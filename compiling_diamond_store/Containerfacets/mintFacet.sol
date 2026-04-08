// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract mintFacet is ERC721 {
    modifier ownerOnly() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner);
        _;
    }

    function mint(string memory _name, string memory _image) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.isClosed);
        ds.totalSupply++;
        ds.pigs[ds.totalSupply] = TestLib.Pig(ds.totalSupply, _name, _image);
        _safeMint(msg.sender, ds.totalSupply);
    }
}
