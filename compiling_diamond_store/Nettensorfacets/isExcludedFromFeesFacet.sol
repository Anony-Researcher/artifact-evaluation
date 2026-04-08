/*
Website: https://nettensor.com/
Documentation: https://docs.nettensor.com/
Twitter: https://twitter.com/nettensor/
Telegram : https://t.me/nettensor/
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
