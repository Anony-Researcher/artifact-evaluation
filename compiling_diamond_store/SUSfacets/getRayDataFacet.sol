// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract getRayDataFacet {
    modifier nonReentrant() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.reentrancyLock, "Reentrancy Guard - Function is locked)");
        ds.reentrancyLock = true;
        _;
        ds.reentrancyLock = false;
    }

    function getRayData(
        uint256 index,
        uint256 from,
        uint256 to
    ) public view returns (TestLib.Ray[] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            from < ds.range[index].firstIndex ||
            from > ds.range[index].lastIndex
        ) {
            from = ds.range[index].firstIndex;
        }
        if (to < ds.range[index].firstIndex || to > ds.range[index].lastIndex) {
            to = ds.range[index].lastIndex;
        }

        TestLib.Ray[] memory result;
        // проверка на присутствие данных)
        if (from <= to) {
            result = new TestLib.Ray[](to - from + 1);
            for (uint256 i = from; i <= to; i++) {
                result[i - from] = ds.ray[index][i];
            }
        }

        return result;
    }
}
