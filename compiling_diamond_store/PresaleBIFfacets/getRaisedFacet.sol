// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getRaisedFacet is Ownable {
    using SafeMath for uint256;

    function getRaised() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.stages[ds.currentStage].raised;
    }
}
