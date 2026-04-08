// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract modifyPigFacet is ERC721 {
    modifier ownerOnly() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner);
        _;
    }

    function modifyPig(
        uint _id,
        string memory _name,
        string memory _image
    ) public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ERC721.ownerOf(_id) == msg.sender);
        require(msg.value >= ds.pigFee);
        ds.pigs[_id].name = _name;
        ds.pigs[_id].image = _image;
    }
}
