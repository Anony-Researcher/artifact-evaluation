// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract gstartDateFacet {
    using SafeMath for uint256;

    function gstartDate() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.startDate;
    }
}
