/**
 */
// SPDX-License-Identifier: MIT
/*

https://t.me/BOOKOFTRUMP_ETH
https://twitter.com/BOOKOFTRUMP_ETH

*/

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract clearStuckBalanceInitiillaysFacet is ERC20 {
    using Address for address payable;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._interlock) {
            ds._interlock = true;
            _;
            ds._interlock = false;
        }
    }

    function clearStuckBalanceInitiillays() external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bontudu = 3;
    }
}
