// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract timeCheckFacet {
    using SafeMath for uint256;

    function timeCheck() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.startDate + LOCK_PERIOD <= block.timestamp) {
            return 1;
        } else {
            return 0;
        }
    }
}
