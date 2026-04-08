//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract getExpectedCompoundOutputByWalletFacet is DividendTracker {
    function getExpectedCompoundOutputByWallet(
        address wallet
    ) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 rewardAmount = withdrawableDividendOf(wallet);
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
