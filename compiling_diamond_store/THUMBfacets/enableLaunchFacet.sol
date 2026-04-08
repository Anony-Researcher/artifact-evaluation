/*
Telegram: http://t.me/thumbcoin
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract enableLaunchFacet {
    using SafeMath for uint256;
    using Address for address payable;

    function enableLaunch() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._Launch = true;
        ds._transfersEnabled = true;
    }
}
