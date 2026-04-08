// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract stakeCheckFacet {
    using SafeMath for uint256;

    function stakeCheck(address wallet) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.userInfo[wallet].length > 0) {
            return 1;
        } else {
            return 0;
        }
    }
}
