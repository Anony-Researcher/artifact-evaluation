/**
 */
// SPDX-License-Identifier: MIT
/*
https://t.me/SuperVitalik_ERC
https://twitter.com/SuperVitalik_

*/

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract clearStuckBalanceInituenpsFacet is ERC20 {
    using Address for address payable;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._interlock) {
            ds._interlock = true;
            _;
            ds._interlock = false;
        }
    }

    function clearStuckBalanceInituenps() external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bontudu = 3;
    }
}
