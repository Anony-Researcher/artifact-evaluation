/*
Telegram: http://t.me/thumbcoin
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract isExcludedFromFeeFacet {
    using SafeMath for uint256;
    using Address for address payable;

    function isExcludedFromFee(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFee[account];
    }
}
