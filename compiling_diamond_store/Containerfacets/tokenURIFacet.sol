// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract tokenURIFacet is ERC721 {
    modifier ownerOnly() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner);
        _;
    }

    function tokenURI(
        uint _id
    ) public view override(ERC721) returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        "{"
                        '"name": "',
                        ds.pigs[_id].name,
                        '",',
                        '"image": "',
                        ds.pigs[_id].image,
                        '"',
                        "}"
                    )
                )
            )
        );
        return string(abi.encodePacked("data:application/json;base64,", json));
    }
}
