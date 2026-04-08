// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./TestLib.sol";
contract getAssetsFacet {
    function getAssets(
        uint256[] memory _tokenIds
    ) public view returns (TestLib.NFTAsset memory asset) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < _tokenIds.length; i++) {
            asset.boxes += ds.nftAssets[_tokenIds[i]].boxes;
            asset.goldChecks += ds.nftAssets[_tokenIds[i]].goldChecks;
            asset.silverChecks += ds.nftAssets[_tokenIds[i]].silverChecks;
            asset.copperChecks += ds.nftAssets[_tokenIds[i]].copperChecks;
        }
    }
}
