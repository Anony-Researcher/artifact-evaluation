// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getNextStagePriceFacet is Ownable {
    using SafeMath for uint256;

    function getNextStagePrice() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Stage memory nextStage = ds.stages[ds.currentStage + 1];
        if (nextStage.priceInUSDStage == 0) {
            return ds.stages[ds.currentStage].priceInUSDStage;
        } else {
            return nextStage.priceInUSDStage;
        }
    }
}
