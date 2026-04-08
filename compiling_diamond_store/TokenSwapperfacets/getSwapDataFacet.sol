// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.19;
import "./TestLib.sol";
contract getSwapDataFacet {
    function getSwapData(
        address originator,
        uint256 swapNumber
    ) external view returns (TestLib.Swap memory, uint256 swapState) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Swap memory swap = ds.allSwaps[originator][swapNumber];
        return (swap, uint256(swap.status));
    }
}
