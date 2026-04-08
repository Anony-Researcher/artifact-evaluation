// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getTotalRaiseStageFacet is Ownable {
    using SafeMath for uint256;

    function getTotalRaiseStage(uint256 stage) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.stages[stage].totalRaise;
    }
}
