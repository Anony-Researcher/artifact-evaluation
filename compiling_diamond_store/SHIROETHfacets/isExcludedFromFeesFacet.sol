/*

    https://t.me/shiroeth

    https://shiro.bz

*/

// SPDX-License-Identifier: MIT

pragma solidity =0.8.16;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
