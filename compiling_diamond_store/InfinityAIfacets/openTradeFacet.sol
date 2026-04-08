// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract openTradeFacet {
    using SafeMath for uint256;
    using Address for address payable;

    function openTrade() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._Launch = true;
        ds._transfersEnabled = true;
    }
}
