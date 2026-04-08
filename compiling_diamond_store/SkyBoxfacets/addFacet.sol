// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "./TestLib.sol";
contract addFacet {
    function add(uint256 _tokenId, uint256 _num) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(isJourneyContract(msg.sender), "NOT_JOURNEY_CONTRACT");
        ds.nftAssets[_tokenId].boxes += _num;
    }
    function isJourneyContract(address who) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return who == address(ds.journeyContract);
    }
}
