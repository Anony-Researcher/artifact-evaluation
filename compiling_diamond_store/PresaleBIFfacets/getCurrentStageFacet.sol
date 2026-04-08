// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getCurrentStageFacet is Ownable {
    using SafeMath for uint256;

    function getCurrentStage() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.currentStage;
    }
}
