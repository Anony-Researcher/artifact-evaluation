// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getRewardForRefOfFacet is Ownable {
    using SafeMath for uint256;

    function getRewardForRefOf(uint256 dolar) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (dolar * ds.refPercent) / 1000;
    }
}
