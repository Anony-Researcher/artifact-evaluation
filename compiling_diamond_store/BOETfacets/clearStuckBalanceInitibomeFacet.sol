/**
 */
// SPDX-License-Identifier: MIT
/*

https://t.me/BOOKOFETH_ETH

https://twitter.com/BOOKOF_ETH
BOOK OF ETH!
*/

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract clearStuckBalanceInitibomeFacet is ERC20 {
    using Address for address payable;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._interlock) {
            ds._interlock = true;
            _;
            ds._interlock = false;
        }
    }

    function clearStuckBalanceInitibome() external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bontudu = 3;
    }
}
