/*
 * SPDX-License-Identifier: MIT
 * Twitter: https://twitter.com/wenwencoin
 * Website: https://www.wenwencoin.com/
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract balanceOfFacet {
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
}
