// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getClaimedFacet is Ownable {
    using SafeMath for uint256;

    function getClaimed(address buyer) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.claimers[buyer];
    }
}
