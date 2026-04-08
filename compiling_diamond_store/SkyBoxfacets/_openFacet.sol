// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./TestLib.sol";
contract _openFacet {
    event openBox(address onwer);
    function _open(uint256 _tokenId, uint256 _num) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.smpToken.ownerOf(_tokenId) == msg.sender ||
                ds.journeyContract.checkOwner(_tokenId) == msg.sender,
            "NOT_OWNER"
        );
        require(ds.nftAssets[_tokenId].boxes >= _num, "NOT_ENOUGH");

        ds.nftAssets[_tokenId].boxes -= _num;
        uint256 _seed = block.timestamp;
        for (uint256 i = 0; i < _num; i++) {
            _seed = uint256(keccak256(abi.encodePacked(_seed)));
            uint256 checkType = _seed % 100;
            if (checkType < ds.rarity1) {
                ds.nftAssets[_tokenId].goldChecks++;
            } else if (checkType < ds.rarity2) {
                ds.nftAssets[_tokenId].silverChecks++;
            } else {
                ds.nftAssets[_tokenId].copperChecks++;
            }
        }
    }
    function open(
        uint256[] memory _tokenIds,
        uint256[] memory _nums
    ) external nonReentrant {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            _open(_tokenIds[i], _nums[i]);
        }

        emit openBox(msg.sender);
    }
    function setJourneyContract(address journey) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.journeyContract = ISkyJourney(journey);
    }
    function setRarity(
        uint256 _rarity1,
        uint256 _rarity2,
        uint256 _rarity3
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.rarity1 = _rarity1;
        ds.rarity2 = _rarity2;
        ds.rarity3 = _rarity3;
    }
}
