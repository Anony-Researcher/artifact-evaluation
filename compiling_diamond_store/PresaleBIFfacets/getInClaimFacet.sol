// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getInClaimFacet is Ownable {
    using SafeMath for uint256;

    function getInClaim() public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.inClaim;
    }
}
