// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract isWhitelistFacet {
    using SafeMath for uint256;
    using Address for address payable;

    function isWhitelist(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isWhiteList[account];
    }
}
