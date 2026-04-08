//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract getExpectedCompoundOutputByEthAmountFacet is DividendTracker {
    function getExpectedCompoundOutputByEthAmount(
        uint256 rewardAmount
    ) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = ds.dexRouter.WETH();
        path[1] = address(ds.nsToken);
        uint256[] memory amounts = ds.dexRouter.getAmountsOut(
            rewardAmount,
            path
        );
        return amounts[1];
    }
}
