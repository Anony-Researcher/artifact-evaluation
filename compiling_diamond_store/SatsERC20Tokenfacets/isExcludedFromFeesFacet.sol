// https://sats.vision
// https://twitter.com/satslabs_
// https://t.me/satslabs

// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity >=0.7.5;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is Ownable {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
