// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./TestLib.sol";
contract getBoxesFacet {
    function getBoxes(
        uint256[] memory _tokenIds
    ) public view returns (uint[] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint[] memory boxes = new uint[](_tokenIds.length);
        for (uint i = 0; i < _tokenIds.length; i++) {
            boxes[i] = ds.nftAssets[_tokenIds[i]].boxes;
        }
        return boxes;
    }
}
